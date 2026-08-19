---
tags:
  - validacion
  - dane
  - calidad-datos
  - proyectos
type: validacion
status: activo
created: 2026-08-19
updated: 2026-08-19
---

# Validación de Calidad de Datos (Sanity Checks)

> [!info] Contexto
> Resultados de la ejecución del script `sql/01_sanity_checks.sql` sobre la base de datos `emicron_db` (schema `staging`). Estos validan que el ETL se ejecutó correctamente y que los microdatos tienen la calidad estadística necesaria para inferencia poblacional.

---

## 1. Integridad Referencial

- **Status:** ✅ OK
- **Validación:** Cruce mediante `LEFT JOIN` entre `staging.ventas` y `staging.identificacion` utilizando la llave compuesta `(directorio, secuencia_p, secuencia_encuesta)`.
- **Resultado:** 0 filas huérfanas. Todos los registros de ingresos tienen su contraparte en el módulo de identificación.

## 2. Validación de Población (Factor de Expansión)

- **Status:** ✅ OK
- **Población Calculada (Suma de `fex_c`):** 5,169,983.09
- **Población Oficial DANE (Boletín EMICRON 2023):** 5,188,402
- **Diferencia Absoluta:** 18,418.91 micronegocios
- **Diferencia Porcentual:** 0.3550%
- **Justificación:** La diferencia es mínima y se encuentra muy por debajo del umbral de tolerancia del 5%. Esta variación es un comportamiento esperado en encuestas de hogares. Se debe a los ajustes post-estratificación y validaciones de no respuesta que el DANE aplica a nivel nacional para la publicación de boletines, los cuales no se reflejan totalmente en el factor `fex_c` del microdato crudo.

## 3. Calidad del Factor de Expansión

- **Status:** ✅ OK
- **Validación:** Conteo de registros en `staging.identificacion` donde `fex_c` es `NULL` o `0`.
- **Resultado:** 0 registros. Todos los casos tienen un factor de expansión válido, lo que garantiza que las agregaciones ponderadas funcionarán correctamente.

## 4. Rangos Lógicos (Ingresos Negativos)

- **Status:** ⚠️ Hallazgo Esperado
- **Validación:** Búsqueda de valores menores a 0 en 48 columnas monetarias de `staging.ventas` (ej. `p3057`, `ventas_mes_anterior`, `valor_agregado`).
- **Resultado:** 8,725 valores negativos detectados.
- **Justificación:** No representa un error en el ETL ni corruptela de datos. En encuestas económicas, variables como el `valor_agregado` o el `ingreso_mixto` pueden ser negativas. Esto ocurre cuando el micronegocio reporta que sus costos y gastos operativos superaron sus ingresos brutos en el mes de referencia, resultando en una pérdida neta. Se preservan los datos tal cual vienen de la fuente original del DANE para no alterar la realidad financiera de los unidades encuestadas.
