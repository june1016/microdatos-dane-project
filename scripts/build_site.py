"""Genera notebooks/html/index.html desde el .ipynb YA EJECUTADO.

No re-ejecuta ni modifica la lógica del notebook: toma el markdown y los datos
de cada figura Plotly guardados en los outputs y los presenta con diseño propio.

Uso (desde la raíz del repo):  python scripts/build_site.py
Requiere: numpy y mistune (ambos ya vienen con pandas/nbconvert).
"""
import base64
import html
import json
import re
from datetime import date
from pathlib import Path

import mistune
import numpy as np

ROOT = Path(__file__).resolve().parents[1]
NB_PATH = ROOT / "notebooks" / "01_eda_visualization.ipynb"
TEMPLATE = Path(__file__).with_name("site_template.html")
OUT_PATH = ROOT / "notebooks" / "html" / "index.html"

NAV_LABELS = ["Formalización", "Crédito", "Crecimiento"]  # etiquetas cortas de la barra (en orden)
REPO_URL = ""  # p. ej. "https://github.com/<usuario>/microdatos-dane-project"
FACTS = [("Fuente", "DANE · EMICRON 2023"),
         ("Ponderación", "Factor de expansión fex_c"),
         ("Datos", "emicron_core.parquet")]

esc = html.escape
md = mistune.html


def fmt(v):
    return f"{v:.1f}".replace(".", ",") + " %"


def decode(o):
    """Convierte arrays binarios de Plotly 3 ({dtype, bdata}) en listas."""
    if isinstance(o, dict):
        if "bdata" in o:
            arr = np.frombuffer(base64.b64decode(o["bdata"]), dtype=o["dtype"])
            if "shape" in o:
                arr = arr.reshape(tuple(int(n) for n in str(o["shape"]).split(",")))
            return arr.tolist()
        return {k: decode(v) for k, v in o.items()}
    if isinstance(o, list):
        return [decode(v) for v in o]
    return o


def extract_plot(cell):
    """Devuelve (spec, src, integrity) si el cell tiene una figura Plotly."""
    for out in cell.get("outputs", []):
        h = "".join(out.get("data", {}).get("text/html", ""))
        if "Plotly.newPlot(" not in h:
            continue
        rest = h[h.index("Plotly.newPlot(") + len("Plotly.newPlot("):]
        dec, pos, parts = json.JSONDecoder(), 0, []
        for _ in range(3):  # id, data, layout
            pos += len(rest[pos:]) - len(rest[pos:].lstrip(" \n\t,"))
            val, pos = dec.raw_decode(rest, pos)
            parts.append(val)
        src = re.search(r'src="(https://cdn\.plot\.ly/[^"]+)"', h)
        sri = re.search(r'integrity="([^"]+)"', h)
        layout = decode(parts[2])
        layout.pop("template", None)
        return ({"id": parts[0], "data": decode(parts[1]), "layout": layout},
                src.group(1) if src else "https://cdn.plot.ly/plotly-3.7.0.min.js",
                sri.group(1) if sri else "")
    return None


def data_table(spec):
    ts, L = spec["data"], spec["layout"]
    horiz = ts[0].get("orientation") == "h"
    title = lambda k: (L[k].get("title") or {}).get("text", "") if isinstance(L[k].get("title"), dict) else L[k].get("title", "")
    cats = ts[0]["y" if horiz else "x"]
    val_axis = title("xaxis" if horiz else "yaxis")
    heads = [title("yaxis" if horiz else "xaxis")] + ([val_axis] if len(ts) == 1 else [t["name"] for t in ts])
    rows = "".join(
        "<tr><td>" + esc(str(c)) + "</td>"
        + "".join(f"<td>{fmt(t['x' if horiz else 'y'][i])}</td>" for t in ts) + "</tr>"
        for i, c in enumerate(cats))
    cap = f"<caption>{esc(val_axis)}</caption>" if len(ts) > 1 else ""
    return (f'<details class="data"><summary>Ver datos del gráfico</summary><div class="table-wrap"><table>{cap}<thead><tr>'
            + "".join(f"<th scope='col'>{esc(h)}</th>" for h in heads) + f"</tr></thead><tbody>{rows}</tbody></table></div></details>")


def finding(spec, anchor):
    ts, L = spec["data"], spec["layout"]
    horiz = ts[0].get("orientation") == "h"
    ax = L["xaxis" if horiz else "yaxis"].get("title", {})
    label = re.sub(r"\s*\(%\)", "", ax.get("text", "") if isinstance(ax, dict) else ax)
    if len(ts) == 1:  # ranking horizontal: primero y segundo
        cats, vals = ts[0]["y"], ts[0]["x"]
        a, b = sorted(range(len(vals)), key=lambda i: -vals[i])[:2]
        return dict(anchor=anchor, label=label, value=fmt(vals[a]),
                    detail=f"{cats[a]}. 2.º {cats[b]} {fmt(vals[b])}")
    gaps = [abs(x - y) for x, y in zip(ts[0]["y"], ts[1]["y"])]
    i = max(range(len(gaps)), key=gaps.__getitem__)
    return dict(anchor=anchor, label="Brecha por tamaño", value=f"{gaps[i]:.1f}".replace(".", ",") + " pp",
                detail=f"{ts[0]['x'][i]}: {fmt(ts[0]['y'][i])} {ts[0]['name'].lower()} vs {fmt(ts[1]['y'][i])} {ts[1]['name'].lower()}")


def main():
    nb = json.loads(NB_PATH.read_text(encoding="utf-8"))
    intro, sections, plotly = None, [], ("https://cdn.plot.ly/plotly-3.7.0.min.js", "")
    for cell in nb["cells"]:
        src = "".join(cell["source"])
        if cell["cell_type"] == "markdown":
            if src.startswith("# "):
                intro = src
            elif src.startswith("## "):
                sections.append({"md": src, "plot": None})
        elif sections:
            got = extract_plot(cell)
            if got:
                sections[-1]["plot"] = got[0]
                plotly = (got[1], got[2])
    if intro is None or not sections:
        raise SystemExit("El notebook no tiene la estructura esperada (# título y ## secciones).")

    # Intro: título, párrafo principal y el resto (definiciones)
    blocks = intro.split("\n\n")
    full_title = re.sub(r"^#\s+[^\w]*", "", blocks[0]).strip()
    kicker, _, tail = full_title.partition(":")
    h1 = tail.strip() or kicker
    lede = re.sub(r"</?p>", "", md(blocks[1]).strip())
    defs = md("\n\n".join(blocks[2:]))
    defs = defs.replace(":</strong>", "</strong>")
    defs = defs.replace("<p>", '<p class="note">') if "<ul>" in defs else defs

    toc, secs, specs, finds = [], [], [], []
    for n, s in enumerate(sections, 1):
        head, _, body = s["md"].partition("\n")
        title = re.sub(r"^##\s+(\d+\.\s*)?", "", head).strip()
        sid = f"s{n}"
        short = NAV_LABELS[n - 1] if n <= len(NAV_LABELS) else title
        toc.append(f'<li><a class="nav tone-{(n - 1) % 3 + 1}" href="#{sid}">{esc(short)}</a></li>')
        fig = ""
        if s["plot"]:
            spec = s["plot"]
            horiz = spec["data"][0].get("orientation") == "h"
            specs.append({**spec, "h": 440 if horiz else 520, "tone": n})
            fig_title = spec["layout"].get("title", {})
            fig_title = fig_title.get("text", "") if isinstance(fig_title, dict) else fig_title
            height, minw = (440, "") if horiz else (520, "min-width:760px;")
            fig = (f'<figure><figcaption><h3>{esc(fig_title)}</h3></figcaption>'
                   f'<div class="plot-scroll"><div id="{spec["id"]}" class="plot" role="img" '
                   f'aria-label="{esc(fig_title)}. Los valores están en la tabla inferior." style="{minw}height:{height}px"></div></div>'
                   f'{data_table(spec)}</figure>')
            try:
                finds.append(finding(spec, sid))
            except Exception:
                pass
        wide = " wide" if s["plot"] and s["plot"]["data"][0].get("orientation") != "h" else ""
        secs.append(f'<section class="sec tone-{(n - 1) % 3 + 1}{wide}" id="{sid}" aria-labelledby="{sid}-t">'
                    f'<div class="sec-text"><h2 id="{sid}-t">{esc(title)}</h2><div class="prose">{md(body.strip())}</div></div>{fig}</section>')

    facts = "".join(f"<div><dt>{esc(k)}</dt><dd>{esc(v)}</dd></div>" for k, v in FACTS)
    repo = f'<a href="{esc(REPO_URL)}">Código y ETL en GitHub</a> · ' if REPO_URL else ""
    footer = (f"{repo}Fuente: DANE, Encuesta de Micronegocios (EMICRON) 2023. "
              f"Cifras ponderadas con fex_c. Actualizado el {date.today().isoformat()}.")
    tirilla = "".join(
        f'<li><a class="t-row" href="#{f["anchor"]}"><span class="t-top"><span>{esc(f["label"])}</span><i></i>'
        f'<b>{esc(f["value"])}</b></span><span class="t-det">{esc(f["detail"])}</span></a></li>' for f in finds)

    rep = {"TITLE": esc(h1), "DESCRIPTION": esc(re.sub(r"<[^>]+>", "", lede)), "KICKER": esc(kicker),
           "H1": esc(h1), "LEDE": lede, "FACTS": facts, "TIRILLA": tirilla, "DEFS": defs,
           "NAV": "".join(toc), "SECTIONS": "".join(secs), "FOOTER": footer,
           "PLOTLY_SRC": plotly[0], "PLOTLY_SRI": f' integrity="{plotly[1]}"' if plotly[1] else "",
           "SPECS": json.dumps(specs, ensure_ascii=False).replace("</", "<\\/")}
    page = TEMPLATE.read_text(encoding="utf-8")
    for k, v in rep.items():
        page = page.replace("{{" + k + "}}", v)
    OUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    OUT_PATH.write_text(page, encoding="utf-8")
    print(f"OK -> {OUT_PATH} ({len(page) / 1024:.0f} KB, {len(specs)} gráficos)")


if __name__ == "__main__":
    main()
