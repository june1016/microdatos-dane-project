-- ============================================================================
-- 02_business_core.sql — DANE EMICRON 2023
-- FASE 4: análisis SQL de las cuatro preguntas comunes de negocio
--
-- Este archivo es de solo lectura: contiene únicamente consultas SELECT.
-- Todas las agregaciones poblacionales usan staging.*.fex_c, el factor de
-- expansión oficial replicado por el ETL.
-- ============================================================================


-- ============================================================================
-- 1. SECTORES POR INGRESOS (NIVEL NACIONAL Y DEPARTAMENTAL)
-- Ingreso promedio ponderado por fex_c, agrupado por GRUPOS12, a nivel
-- nacional y por departamento. Solo se consideran los 12 códigos oficiales.
-- ============================================================================

WITH base_ingresos AS (
    SELECT
        i.cod_depto,
        i.grupos12,
        v.ventas_mes_anterior,
        v.fex_c
    FROM staging.identificacion AS i
    INNER JOIN staging.ventas AS v
        ON  v.directorio = i.directorio
        AND v.secuencia_p = i.secuencia_p
        AND v.secuencia_encuesta = i.secuencia_encuesta
    WHERE v.ventas_mes_anterior IS NOT NULL
      AND v.fex_c IS NOT NULL
      AND v.fex_c > 0
      AND i.grupos12 IN ('01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12')
),
ingresos_agregados AS (
    SELECT
        'Nacional' AS nivel,
        NULL AS cod_depto,
        grupos12,
        COUNT(*) AS micronegocios_muestra,
        SUM(fex_c) AS micronegocios_expandidos,
        SUM(ventas_mes_anterior * fex_c) / NULLIF(SUM(fex_c), 0) AS ingreso_promedio_ponderado
    FROM base_ingresos
    GROUP BY grupos12

    UNION ALL

    SELECT
        'Departamental' AS nivel,
        cod_depto,
        grupos12,
        COUNT(*) AS micronegocios_muestra,
        SUM(fex_c) AS micronegocios_expandidos,
        SUM(ventas_mes_anterior * fex_c) / NULLIF(SUM(fex_c), 0) AS ingreso_promedio_ponderado
    FROM base_ingresos
    GROUP BY cod_depto, grupos12
)
SELECT
    nivel,
    cod_depto,
    grupos12,
    micronegocios_muestra,
    ROUND(micronegocios_expandidos, 2) AS micronegocios_expandidos,
    ROUND(ingreso_promedio_ponderado, 2) AS ingreso_promedio_ponderado
FROM ingresos_agregados
ORDER BY nivel, cod_depto NULLS FIRST, ingreso_promedio_ponderado DESC NULLS LAST;


-- ============================================================================
-- 2. CIUDADES CON MAYOR FORMALIZACIÓN
-- Índice compuesto de cuatro componentes binarios: RUT, Cámara de Comercio,
-- registro contable formal, y declaración de al menos un impuesto.
-- ============================================================================

WITH indicadores_formalizacion AS (
    SELECT
        i.area,
        i.fex_c,
        CASE WHEN c.p1633 = 1 THEN 1 ELSE 0 END AS tiene_rut,
        CASE WHEN c.p1055 = 1 THEN 1 ELSE 0 END AS tiene_camara,
        CASE WHEN c.p640 IN (1, 2, 4) THEN 1 ELSE 0 END AS tiene_registro_contable_formal,
        CASE WHEN c.p2991 = 1 OR c.p2992 = 1 OR c.p2993 = 1 THEN 1 ELSE 0 END AS declaro_impuestos
    FROM staging.identificacion AS i
    INNER JOIN staging.caracteristicas AS c
        ON  c.directorio = i.directorio
        AND c.secuencia_p = i.secuencia_p
        AND c.secuencia_encuesta = i.secuencia_encuesta
    WHERE i.area IS NOT NULL
      AND i.fex_c IS NOT NULL
      AND i.fex_c > 0
),
indice_por_ciudad AS (
    SELECT
        area,
        COUNT(*) AS micronegocios_muestra,
        SUM(fex_c) AS micronegocios_expandidos,
        SUM((tiene_rut + tiene_camara + tiene_registro_contable_formal + declaro_impuestos) * fex_c)
            / NULLIF(4 * SUM(fex_c), 0) * 100 AS indice_formalizacion_pct,
        SUM(CASE WHEN tiene_rut = 1 AND tiene_camara = 1 AND tiene_registro_contable_formal = 1 AND declaro_impuestos = 1 THEN fex_c ELSE 0 END)
            / NULLIF(SUM(fex_c), 0) * 100 AS formalizacion_completa_pct
    FROM indicadores_formalizacion
    GROUP BY area
)
SELECT
    area,
    micronegocios_muestra,
    ROUND(micronegocios_expandidos, 2) AS micronegocios_expandidos,
    ROUND(indice_formalizacion_pct, 2) AS indice_formalizacion_pct,
    ROUND(formalizacion_completa_pct, 2) AS formalizacion_completa_pct
FROM indice_por_ciudad
ORDER BY indice_formalizacion_pct DESC NULLS LAST,
         formalizacion_completa_pct DESC NULLS LAST;


-- ============================================================================
-- 3. SEGMENTOS CON MENOR FORMALIZACIÓN
-- Cruza el índice compuesto por GRUPOS12, CLASE_TE y Tamaño (Enfoque 1).
-- ============================================================================

WITH indicadores_formalizacion AS (
    SELECT
        i.grupos4,
        i.grupos12,
        i.clase_te,
        CASE WHEN COALESCE(i.p3032_1, 0) > 0 THEN 'Con empleados' ELSE 'Unipersonal' END AS tamano,
        i.fex_c,
        CASE WHEN c.p1633 = 1 THEN 1 ELSE 0 END AS tiene_rut,
        CASE WHEN c.p1055 = 1 THEN 1 ELSE 0 END AS tiene_camara,
        CASE WHEN c.p640 IN (1, 2, 4) THEN 1 ELSE 0 END AS tiene_registro_contable_formal,
        CASE WHEN c.p2991 = 1 OR c.p2992 = 1 OR c.p2993 = 1 THEN 1 ELSE 0 END AS declaro_impuestos
    FROM staging.identificacion AS i
    INNER JOIN staging.caracteristicas AS c
        ON  c.directorio = i.directorio
        AND c.secuencia_p = i.secuencia_p
        AND c.secuencia_encuesta = i.secuencia_encuesta
    WHERE i.grupos12 IS NOT NULL
      AND i.clase_te IS NOT NULL
      AND i.fex_c IS NOT NULL
      AND i.fex_c > 0
      AND i.grupos12 IN ('01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12')
      AND i.grupos4 IN ('01', '02', '03', '04')
),
segmentos AS (
    SELECT
        grupos4,
        grupos12,
        clase_te,
        tamano,
        COUNT(*) AS micronegocios_muestra,
        SUM(fex_c) AS micronegocios_expandidos,
        SUM((tiene_rut + tiene_camara + tiene_registro_contable_formal + declaro_impuestos) * fex_c)
            / NULLIF(4 * SUM(fex_c), 0) * 100 AS indice_formalizacion_pct,
        SUM(CASE WHEN tiene_rut = 1 AND tiene_camara = 1 AND tiene_registro_contable_formal = 1 AND declaro_impuestos = 1 THEN fex_c ELSE 0 END)
            / NULLIF(SUM(fex_c), 0) * 100 AS formalizacion_completa_pct
    FROM indicadores_formalizacion
    GROUP BY grupos4, grupos12, clase_te, tamano
)
SELECT
    grupos4,
    grupos12,
    clase_te,
    tamano,
    micronegocios_muestra,
    ROUND(micronegocios_expandidos, 2) AS micronegocios_expandidos,
    ROUND(indice_formalizacion_pct, 2) AS indice_formalizacion_pct,
    ROUND(formalizacion_completa_pct, 2) AS formalizacion_completa_pct
FROM segmentos
ORDER BY indice_formalizacion_pct ASC NULLS LAST,
         formalizacion_completa_pct ASC NULLS LAST;


-- ============================================================================
-- 4. RANKING TOP 10 DEPARTAMENTOS POR CRECIMIENTO INTERANUAL
-- Compara el ingreso mensual de 2023 anualizado (mes × 12) vs el ingreso total
-- oficial de 2022. La variación se calcula sobre totales ponderados por fex_c.
-- ============================================================================

WITH crecimiento_departamento AS (
    SELECT
        v.cod_depto,
        COUNT(*) AS micronegocios_muestra,
        SUM(v.fex_c) AS micronegocios_expandidos,
        SUM(v.ventas_mes_anterior * v.fex_c) * 12 AS ingresos_2023_anualizados,
        SUM(v.ventas_anio_anterior * v.fex_c) AS ingresos_2022_anual,
        (
            (SUM(v.ventas_mes_anterior * v.fex_c) * 12)
            - SUM(v.ventas_anio_anterior * v.fex_c)
        ) / NULLIF(SUM(v.ventas_anio_anterior * v.fex_c), 0) * 100 AS variacion_interanual_pct
    FROM staging.ventas AS v
    WHERE v.cod_depto IS NOT NULL
      AND v.fex_c IS NOT NULL
      AND v.fex_c > 0
      AND v.ventas_mes_anterior IS NOT NULL
      AND v.ventas_anio_anterior IS NOT NULL
      AND v.ventas_anio_anterior > 0
    GROUP BY v.cod_depto
),
ranking AS (
    SELECT
        *,
        RANK() OVER (ORDER BY variacion_interanual_pct DESC NULLS LAST) AS ranking_departamento
    FROM crecimiento_departamento
)
SELECT
    cod_depto,
    ranking_departamento,
    micronegocios_muestra,
    ROUND(micronegocios_expandidos, 2) AS micronegocios_expandidos,
    ROUND(ingresos_2023_anualizados, 2) AS ingresos_2023_anualizados,
    ROUND(ingresos_2022_anual, 2) AS ingresos_2022_anual,
    ROUND(variacion_interanual_pct, 2) AS variacion_interanual_pct
FROM ranking
WHERE ranking_departamento <= 10
ORDER BY ranking_departamento;
