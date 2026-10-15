-- ============================================================================
-- 03_business_own.sql — DANE EMICRON 2023
-- MÓDULO DIFERENCIADOR: INCLUSIÓN FINANCIERA
-- Pregunta de negocio: ¿Cuál es la brecha entre la solicitud y la aprobación
-- de crédito en los micronegocios, y cómo varía por sector y tamaño?
-- ============================================================================

WITH base_credito AS (
    SELECT
        i.grupos12,
        -- Enfoque 1: Tamaño basado en empleados remunerados
        CASE
            WHEN COALESCE(i.p3032_1, 0) > 0 THEN 'Con empleados'
            ELSE 'Unipersonal'
        END AS tamano,
        f.p1568, -- 1=Sí obtuvo, 2=No obtuvo
        f.fex_c
    FROM staging.inclusion_financiera AS f
    INNER JOIN staging.identificacion AS i
        ON  i.directorio = f.directorio
        AND i.secuencia_p = f.secuencia_p
        AND i.secuencia_encuesta = f.secuencia_encuesta
    -- Filtramos solo los que SÍ solicitaron crédito
    WHERE f.p1765 = 1
      AND f.fex_c IS NOT NULL
      AND f.fex_c > 0
      AND i.grupos12 IN ('01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12')
),
resumen_segmentos AS (
    SELECT
        grupos12,
        tamano,
        COUNT(*) AS solicitantes_muestra,
        SUM(fex_c) AS solicitantes_expandidos,
        SUM(CASE WHEN p1568 = 1 THEN fex_c ELSE 0 END) AS aprobados_expandidos,
        SUM(CASE WHEN p1568 = 2 THEN fex_c ELSE 0 END) AS negados_expandidos
    FROM base_credito
    GROUP BY grupos12, tamano
)
SELECT
    grupos12,
    tamano,
    solicitantes_muestra,
    ROUND(solicitantes_expandidos, 2) AS solicitantes_expandidos,
    ROUND(aprobados_expandidos, 2) AS aprobados_expandidos,
    ROUND(negados_expandidos, 2) AS negados_expandidos,
    -- Calculamos la tasa de aprobación (Brecha)
    ROUND((aprobados_expandidos / NULLIF(solicitantes_expandidos, 0)) * 100, 2) AS tasa_aprobacion_pct,
    ROUND((negados_expandidos / NULLIF(solicitantes_expandidos, 0)) * 100, 2) AS tasa_negacion_pct
FROM resumen_segmentos
-- Ordenamos por los que tienen la tasa de aprobación más baja (mayor brecha/rechazo)
ORDER BY tasa_aprobacion_pct ASC NULLS LAST;
