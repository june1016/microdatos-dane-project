-- ============================================================================
-- schema.sql — DANE EMICRON 2023
-- Define los esquemas RAW (carga cruda) y STAGING (tipado y documentado),
-- sus tablas, comentarios e índices para los 6 módulos de la encuesta:
-- identificación, características, ubicación, ventas, factores de expansión
-- e inclusión financiera.
--
-- PASO 0 (solo la primera vez, conectado a la BD 'postgres'):
--   CREATE DATABASE emicron_db;
--   Luego conectarse a 'emicron_db' y ejecutar este script completo.
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS staging;

-- ============================================================================
-- 1. ESQUEMA RAW
-- Nombres de columna en MAYÚSCULAS, idénticos al CSV fuente. Todo TEXT para
-- permitir la carga sin fricción (sin errores de tipo en el COPY/INSERT).
-- ============================================================================

-- 1.1 Identificación — llaves, propietario y clasificación CIIU
DROP TABLE IF EXISTS raw.identificacion CASCADE;
CREATE TABLE raw.identificacion (
    "DIRECTORIO" TEXT,
    "SECUENCIA_P" TEXT,
    "SECUENCIA_ENCUESTA" TEXT,
    "COD_DEPTO" TEXT,
    "AREA" TEXT,
    "CLASE_TE" TEXT,
    "P35" TEXT,
    "P241" TEXT,
    "MES_REF" TEXT,
    "P3031" TEXT,
    "P3032_1" TEXT,
    "P3032_2" TEXT,
    "P3032_3" TEXT,
    "P3033" TEXT,
    "P3034" TEXT,
    "P3035" TEXT,
    "P3000" TEXT,
    "GRUPOS4" TEXT,
    "GRUPOS12" TEXT,
    "F_EXP" TEXT,
    CONSTRAINT pk_raw_identificacion PRIMARY KEY ("DIRECTORIO", "SECUENCIA_P", "SECUENCIA_ENCUESTA")
);

-- 1.2 Características — formalización, registros y declaraciones de impuestos
DROP TABLE IF EXISTS raw.caracteristicas CASCADE;
CREATE TABLE raw.caracteristicas (
    "DIRECTORIO" TEXT,
    "SECUENCIA_P" TEXT,
    "SECUENCIA_ENCUESTA" TEXT,
    "P1633" TEXT,
    "P986" TEXT,
    "P640" TEXT,
    "P4000" TEXT,
    "P1055" TEXT,
    "P1056" TEXT,
    "P661" TEXT,
    "P1057" TEXT,
    "P4004" TEXT,
    "P2991" TEXT,
    "P2992" TEXT,
    "P2993" TEXT,
    "CLASE_TE" TEXT,
    "COD_DEPTO" TEXT,
    "AREA" TEXT,
    "F_EXP" TEXT,
    CONSTRAINT pk_raw_caracteristicas PRIMARY KEY ("DIRECTORIO", "SECUENCIA_P", "SECUENCIA_ENCUESTA")
);

-- 1.3 Ubicación — tipo de local, visibilidad y geografía
DROP TABLE IF EXISTS raw.ubicacion CASCADE;
CREATE TABLE raw.ubicacion (
    "DIRECTORIO" TEXT,
    "SECUENCIA_P" TEXT,
    "SECUENCIA_ENCUESTA" TEXT,
    "P3053" TEXT,
    "P3095" TEXT,
    "P3096" TEXT,
    "P3097" TEXT,
    "P3098" TEXT,
    "P3054" TEXT,
    "P3055" TEXT,
    "P469" TEXT,
    "CLASE_TE" TEXT,
    "COD_DEPTO" TEXT,
    "AREA" TEXT,
    "F_EXP" TEXT,
    CONSTRAINT pk_raw_ubicacion PRIMARY KEY ("DIRECTORIO", "SECUENCIA_P", "SECUENCIA_ENCUESTA")
);

-- 1.4 Ventas — ingresos por fuente, meses de operación y agregados económicos
DROP TABLE IF EXISTS raw.ventas CASCADE;
CREATE TABLE raw.ventas (
    "DIRECTORIO" TEXT,
    "SECUENCIA_P" TEXT,
    "SECUENCIA_ENCUESTA" TEXT,
    "P3057" TEXT,
    "P3058" TEXT,
    "P3059" TEXT,
    "P3060" TEXT,
    "P3061" TEXT,
    "P3062" TEXT,
    "P4002" TEXT,
    "P3063" TEXT,
    "P3064" TEXT,
    "P3065" TEXT,
    "P3066" TEXT,
    "P3067" TEXT,
    "P3092" TEXT,
    "P3093" TEXT,
    "P4036" TEXT,
    "P4005" TEXT,
    "P4006" TEXT,
    "P4007" TEXT,
    "P4008" TEXT,
    "P4009" TEXT,
    "P4010" TEXT,
    "P4011" TEXT,
    "P4012" TEXT,
    "P4013" TEXT,
    "P4014" TEXT,
    "P4015" TEXT,
    "P4016" TEXT,
    "P4017" TEXT,
    "P4018" TEXT,
    "P4037" TEXT,
    "P3068_ENE" TEXT,
    "P3068_FEB" TEXT,
    "P3068_MAR" TEXT,
    "P3068_ABR" TEXT,
    "P3068_MAY" TEXT,
    "P3068_JUN" TEXT,
    "P3068_JUL" TEXT,
    "P3068_AGO" TEXT,
    "P3068_SEP" TEXT,
    "P3068_OCT" TEXT,
    "P3068_NOV" TEXT,
    "P3068_DIC" TEXT,
    "P3068_TOD" TEXT,
    "P3068_NIN" TEXT,
    "P4019" TEXT,
    "P4020" TEXT,
    "P4021" TEXT,
    "P4022" TEXT,
    "P4023" TEXT,
    "P4024" TEXT,
    "P4025" TEXT,
    "P4026" TEXT,
    "P4027" TEXT,
    "P4028" TEXT,
    "P4029" TEXT,
    "P4030" TEXT,
    "P4031" TEXT,
    "P4032" TEXT,
    "P4038" TEXT,
    "P3072" TEXT,
    "VENTAS_MES_ANTERIOR" TEXT,
    "VENTAS_MES_ANIO_ANTERIOR" TEXT,
    "VENTAS_ANIO_ANTERIOR" TEXT,
    "VALOR_AGREGADO" TEXT,
    "INGRESO_MIXTO" TEXT,
    "CLASE_TE" TEXT,
    "COD_DEPTO" TEXT,
    "AREA" TEXT,
    "F_EXP" TEXT,
    CONSTRAINT pk_raw_ventas PRIMARY KEY ("DIRECTORIO", "SECUENCIA_P", "SECUENCIA_ENCUESTA")
);

-- 1.5 Factores de expansión — fuente oficial de fex_c
DROP TABLE IF EXISTS raw.factores_exp CASCADE;
CREATE TABLE raw.factores_exp (
    "DIRECTORIO" TEXT,
    "SECUENCIA_P" TEXT,
    "SECUENCIA_ENCUESTA" TEXT,
    "FEX_C" TEXT,
    CONSTRAINT pk_raw_factores_exp PRIMARY KEY ("DIRECTORIO", "SECUENCIA_P", "SECUENCIA_ENCUESTA")
);

-- 1.6 Inclusión financiera — crédito, medios de pago y ahorro (módulo diferenciador)
DROP TABLE IF EXISTS raw.inclusion_financiera CASCADE;
CREATE TABLE raw.inclusion_financiera (
    "DIRECTORIO" TEXT,
    "SECUENCIA_P" TEXT,
    "SECUENCIA_ENCUESTA" TEXT,
    "P1764_1" TEXT,
    "P1764_2" TEXT,
    "P1764_3" TEXT,
    "P1764_4" TEXT,
    "P1764_5" TEXT,
    "P1764_6" TEXT,
    "P1764_7" TEXT,
    "P1765" TEXT,
    "P1567" TEXT,
    "P1569" TEXT,
    "P1568" TEXT,
    "P1571_1" TEXT,
    "P1571_2" TEXT,
    "P1571_3" TEXT,
    "P1571_4" TEXT,
    "P1571_5" TEXT,
    "P1571_6" TEXT,
    "P1570" TEXT,
    "P1570_1" TEXT,
    "P1570_2" TEXT,
    "P1572_1" TEXT,
    "P1572_2" TEXT,
    "P1572_3" TEXT,
    "P1572_4" TEXT,
    "P1572_5" TEXT,
    "P1572_6" TEXT,
    "P3014" TEXT,
    "P1573_1" TEXT,
    "P1573_2" TEXT,
    "P1573_3" TEXT,
    "P1573_4" TEXT,
    "P1573_5" TEXT,
    "P1573_6" TEXT,
    "P1574" TEXT,
    "P1771" TEXT,
    "CLASE_TE" TEXT,
    "COD_DEPTO" TEXT,
    "AREA" TEXT,
    "F_EXP" TEXT,
    CONSTRAINT pk_raw_inclusion_financiera
        PRIMARY KEY ("DIRECTORIO", "SECUENCIA_P", "SECUENCIA_ENCUESTA")
);

-- ----------------------------------------------------------------------------
-- Nota — PKs en RAW: se definen inline en cada CREATE TABLE y garantizan la
-- unicidad de la llave compuesta desde el momento de la carga. Si algún CSV
-- trae duplicados de llave, el INSERT falla aquí (bodega inmutable) y no en
-- staging: es el punto correcto para detectarlo (fail-fast).
-- ----------------------------------------------------------------------------

-- ============================================================================
-- 2. ESQUEMA STAGING
-- Nombres en snake_case y tipado exacto. fex_c se replica en todas las
-- tablas como factor de expansión oficial para agregaciones ponderadas.
--
-- Convenciones de tipo:
--   NUMERIC(15,2)  -> valores monetarios
--   NUMERIC(20,10) -> factores de expansión
--   VARCHAR        -> códigos que deben preservar ceros a la izquierda
--   INTEGER        -> conteos y variables categóricas
-- ============================================================================

-- 2.1 Identificación
DROP TABLE IF EXISTS staging.identificacion CASCADE;
CREATE TABLE staging.identificacion (
    directorio          INTEGER NOT NULL,
    secuencia_p         INTEGER NOT NULL,
    secuencia_encuesta  INTEGER NOT NULL,
    cod_depto           VARCHAR(2),
    area                VARCHAR(2),
    clase_te            INTEGER,
    p35                 INTEGER,
    p241                INTEGER,
    mes_ref             VARCHAR(15),
    p3031               INTEGER,
    p3032_1             INTEGER,
    p3032_2             INTEGER,
    p3032_3             INTEGER,
    p3033               INTEGER,
    p3034               INTEGER,
    p3035               INTEGER,
    p3000               INTEGER,
    grupos4             VARCHAR(2),
    grupos12            VARCHAR(2),
    f_exp               NUMERIC(20,10),
    fex_c               NUMERIC(20,10),
    CONSTRAINT pk_identificacion PRIMARY KEY (directorio, secuencia_p, secuencia_encuesta)
);

COMMENT ON TABLE staging.identificacion IS 'Módulo de identificación: llaves, datos del propietario y clasificación CIIU';
COMMENT ON COLUMN staging.identificacion.directorio IS 'Directorio (identificador del hogar)';
COMMENT ON COLUMN staging.identificacion.secuencia_p IS 'Secuencia P (persona dentro del hogar)';
COMMENT ON COLUMN staging.identificacion.secuencia_encuesta IS 'Secuencia Encuesta (negocio de la persona)';
COMMENT ON COLUMN staging.identificacion.cod_depto IS 'Departamento (código DANE, preserva cero a la izquierda)';
COMMENT ON COLUMN staging.identificacion.area IS 'Ciudades principales y áreas metropolitanas';
COMMENT ON COLUMN staging.identificacion.clase_te IS 'Clase (cabecera / centros poblados y rural disperso)';
COMMENT ON COLUMN staging.identificacion.p35 IS 'Sexo del propietario del micronegocio';
COMMENT ON COLUMN staging.identificacion.p241 IS 'Edad del propietario del micronegocio';
COMMENT ON COLUMN staging.identificacion.mes_ref IS 'Mes de referencia';
COMMENT ON COLUMN staging.identificacion.p3031 IS 'En su actividad o negocio, ¿tiene personas que le ayudan?';
COMMENT ON COLUMN staging.identificacion.p3032_1 IS '¿Trabajadores(as) que reciben un pago?';
COMMENT ON COLUMN staging.identificacion.p3032_2 IS '¿Socios(as)?';
COMMENT ON COLUMN staging.identificacion.p3032_3 IS '¿Trabajadores(as) o familiares sin remuneración?';
COMMENT ON COLUMN staging.identificacion.p3033 IS 'En su negocio o actividad, usted es:';
COMMENT ON COLUMN staging.identificacion.p3034 IS '¿Cuántos meses lleva trabajando en su negocio o su actividad?';
COMMENT ON COLUMN staging.identificacion.p3035 IS 'El negocio ¿tiene nombre comercial?';
COMMENT ON COLUMN staging.identificacion.p3000 IS '¿Tiene correo electrónico?';
COMMENT ON COLUMN staging.identificacion.grupos4 IS 'Rama de actividad CIIU Rev. 4 agrupada en 4 grupos';
COMMENT ON COLUMN staging.identificacion.grupos12 IS 'Rama de actividad CIIU Rev. 4 agrupada en 12 grupos';
COMMENT ON COLUMN staging.identificacion.f_exp IS 'Factor de expansión del módulo (referencia, NO usar en agregaciones)';
COMMENT ON COLUMN staging.identificacion.fex_c IS 'Factor de expansión departamental oficial 2023 (usar en TODA agregación poblacional)';

-- 2.2 Características
DROP TABLE IF EXISTS staging.caracteristicas CASCADE;
CREATE TABLE staging.caracteristicas (
    directorio          INTEGER NOT NULL,
    secuencia_p         INTEGER NOT NULL,
    secuencia_encuesta  INTEGER NOT NULL,
    p1633               INTEGER,
    p986                INTEGER,
    p640                INTEGER,
    p4000               INTEGER,
    p1055               INTEGER,
    p1056               INTEGER,
    p661                INTEGER,
    p1057               INTEGER,
    p4004               INTEGER,
    p2991               INTEGER,
    p2992               INTEGER,
    p2993               INTEGER,
    clase_te            INTEGER,
    cod_depto           VARCHAR(2),
    area                VARCHAR(2),
    f_exp               NUMERIC(20,10),
    fex_c               NUMERIC(20,10),
    CONSTRAINT pk_caracteristicas PRIMARY KEY (directorio, secuencia_p, secuencia_encuesta)
);

COMMENT ON TABLE staging.caracteristicas IS 'Módulo de características: formalización, registros y declaraciones de impuestos';
COMMENT ON COLUMN staging.caracteristicas.directorio IS 'Directorio (identificador del hogar)';
COMMENT ON COLUMN staging.caracteristicas.secuencia_p IS 'Secuencia P (persona dentro del hogar)';
COMMENT ON COLUMN staging.caracteristicas.secuencia_encuesta IS 'Secuencia Encuesta (negocio de la persona)';
COMMENT ON COLUMN staging.caracteristicas.p1633 IS '¿El negocio o actividad tiene Registro Único Tributario (RUT)?';
COMMENT ON COLUMN staging.caracteristicas.p986 IS '¿A qué régimen pertenece?';
COMMENT ON COLUMN staging.caracteristicas.p640 IS '¿Cuál es el principal registro que utiliza para llevar sus cuentas?';
COMMENT ON COLUMN staging.caracteristicas.p4000 IS '¿Cuál es la razón principal por la cual no lleva algún tipo de registro?';
COMMENT ON COLUMN staging.caracteristicas.p1055 IS '¿El negocio o actividad se encuentra registrado en alguna Cámara de Comercio?';
COMMENT ON COLUMN staging.caracteristicas.p1056 IS '¿Cómo está registrado?';
COMMENT ON COLUMN staging.caracteristicas.p661 IS '¿Obtuvo o renovó ese registro este año?';
COMMENT ON COLUMN staging.caracteristicas.p1057 IS '¿Ha registrado el negocio ante alguna autoridad o entidad (alcaldía, ministerios u otros)?';
COMMENT ON COLUMN staging.caracteristicas.p4004 IS '¿Cuál autoridad o entidad?';
COMMENT ON COLUMN staging.caracteristicas.p2991 IS 'En el último año, ¿realizó declaración(es) de impuesto sobre la renta?';
COMMENT ON COLUMN staging.caracteristicas.p2992 IS 'En el último año, ¿realizó declaración(es) de IVA?';
COMMENT ON COLUMN staging.caracteristicas.p2993 IS 'En el último año, ¿realizó declaración(es) de ICA?';
COMMENT ON COLUMN staging.caracteristicas.clase_te IS 'Clase (cabecera / centros poblados y rural disperso)';
COMMENT ON COLUMN staging.caracteristicas.cod_depto IS 'Departamento (código DANE)';
COMMENT ON COLUMN staging.caracteristicas.area IS 'Ciudades principales y áreas metropolitanas';
COMMENT ON COLUMN staging.caracteristicas.f_exp IS 'Factor de expansión del módulo (referencia, NO usar en agregaciones)';
COMMENT ON COLUMN staging.caracteristicas.fex_c IS 'Factor de expansión departamental oficial 2023';

-- 2.3 Ubicación
DROP TABLE IF EXISTS staging.ubicacion CASCADE;
CREATE TABLE staging.ubicacion (
    directorio          INTEGER NOT NULL,
    secuencia_p         INTEGER NOT NULL,
    secuencia_encuesta  INTEGER NOT NULL,
    p3053               INTEGER,
    p3095               INTEGER,
    p3096               INTEGER,
    p3097               INTEGER,
    p3098               INTEGER,
    p3054               INTEGER,
    p3055               INTEGER,
    p469                INTEGER,
    clase_te            INTEGER,
    cod_depto           VARCHAR(2),
    area                VARCHAR(2),
    f_exp               NUMERIC(20,10),
    fex_c               NUMERIC(20,10),
    CONSTRAINT pk_ubicacion PRIMARY KEY (directorio, secuencia_p, secuencia_encuesta)
);

COMMENT ON TABLE staging.ubicacion IS 'Módulo de sitio o ubicación: tipo de local, visibilidad y geografía';
COMMENT ON COLUMN staging.ubicacion.directorio IS 'Directorio (identificador del hogar)';
COMMENT ON COLUMN staging.ubicacion.secuencia_p IS 'Secuencia P (persona dentro del hogar)';
COMMENT ON COLUMN staging.ubicacion.secuencia_encuesta IS 'Secuencia Encuesta (negocio de la persona)';
COMMENT ON COLUMN staging.ubicacion.p3053 IS '¿El negocio o actividad se encuentra principalmente:';
COMMENT ON COLUMN staging.ubicacion.p3095 IS 'La vivienda ¿';
COMMENT ON COLUMN staging.ubicacion.p3096 IS 'Especifique cuál ¿';
COMMENT ON COLUMN staging.ubicacion.p3097 IS 'La actividad la desarrolla principalmente …';
COMMENT ON COLUMN staging.ubicacion.p3098 IS 'La actividad es ¿';
COMMENT ON COLUMN staging.ubicacion.p3054 IS '¿Cuántos puestos, establecimientos, oficinas, talleres, vehículos tiene el negocio?';
COMMENT ON COLUMN staging.ubicacion.p3055 IS 'El puesto, local, oficina o lugar donde desarrolla su negocio es:';
COMMENT ON COLUMN staging.ubicacion.p469 IS '¿El negocio o actividad económica es visible al público?';
COMMENT ON COLUMN staging.ubicacion.clase_te IS 'Clase (cabecera / centros poblados y rural disperso)';
COMMENT ON COLUMN staging.ubicacion.cod_depto IS 'Departamento (código DANE)';
COMMENT ON COLUMN staging.ubicacion.area IS 'Ciudades principales y áreas metropolitanas';
COMMENT ON COLUMN staging.ubicacion.f_exp IS 'Factor de expansión del módulo (referencia, NO usar en agregaciones)';
COMMENT ON COLUMN staging.ubicacion.fex_c IS 'Factor de expansión departamental oficial 2023';

-- 2.4 Ventas
DROP TABLE IF EXISTS staging.ventas CASCADE;
CREATE TABLE staging.ventas (
    directorio                  INTEGER NOT NULL,
    secuencia_p                 INTEGER NOT NULL,
    secuencia_encuesta          INTEGER NOT NULL,
    p3057                       NUMERIC(15,2),
    p3058                       NUMERIC(15,2),
    p3059                       NUMERIC(15,2),
    p3060                       NUMERIC(15,2),
    p3061                       NUMERIC(15,2),
    p3062                       NUMERIC(15,2),
    p4002                       NUMERIC(15,2),
    p3063                       NUMERIC(15,2),
    p3064                       NUMERIC(15,2),
    p3065                       NUMERIC(15,2),
    p3066                       NUMERIC(15,2),
    p3067                       NUMERIC(15,2),
    p3092                       NUMERIC(15,2),
    p3093                       NUMERIC(15,2),
    p4036                       NUMERIC(15,2),
    p4005                       NUMERIC(15,2),
    p4006                       NUMERIC(15,2),
    p4007                       NUMERIC(15,2),
    p4008                       NUMERIC(15,2),
    p4009                       NUMERIC(15,2),
    p4010                       NUMERIC(15,2),
    p4011                       NUMERIC(15,2),
    p4012                       NUMERIC(15,2),
    p4013                       NUMERIC(15,2),
    p4014                       NUMERIC(15,2),
    p4015                       NUMERIC(15,2),
    p4016                       NUMERIC(15,2),
    p4017                       NUMERIC(15,2),
    p4018                       NUMERIC(15,2),
    p4037                       NUMERIC(15,2),
    p3068_ene                   INTEGER,
    p3068_feb                   INTEGER,
    p3068_mar                   INTEGER,
    p3068_abr                   INTEGER,
    p3068_may                   INTEGER,
    p3068_jun                   INTEGER,
    p3068_jul                   INTEGER,
    p3068_ago                   INTEGER,
    p3068_sep                   INTEGER,
    p3068_oct                   INTEGER,
    p3068_nov                   INTEGER,
    p3068_dic                   INTEGER,
    p3068_tod                   INTEGER,
    p3068_nin                   INTEGER,
    p4019                       NUMERIC(15,2),
    p4020                       NUMERIC(15,2),
    p4021                       NUMERIC(15,2),
    p4022                       NUMERIC(15,2),
    p4023                       NUMERIC(15,2),
    p4024                       NUMERIC(15,2),
    p4025                       NUMERIC(15,2),
    p4026                       NUMERIC(15,2),
    p4027                       NUMERIC(15,2),
    p4028                       NUMERIC(15,2),
    p4029                       NUMERIC(15,2),
    p4030                       NUMERIC(15,2),
    p4031                       NUMERIC(15,2),
    p4032                       NUMERIC(15,2),
    p4038                       NUMERIC(15,2),
    p3072                       NUMERIC(15,2),
    ventas_mes_anterior         NUMERIC(15,2),
    ventas_mes_anio_anterior    NUMERIC(15,2),
    ventas_anio_anterior        NUMERIC(15,2),
    valor_agregado              NUMERIC(15,2),
    ingreso_mixto               NUMERIC(15,2),
    clase_te                    INTEGER,
    cod_depto                   VARCHAR(2),
    area                        VARCHAR(2),
    f_exp                       NUMERIC(20,10),
    fex_c                       NUMERIC(20,10),
    CONSTRAINT pk_ventas PRIMARY KEY (directorio, secuencia_p, secuencia_encuesta)
);

COMMENT ON TABLE staging.ventas IS 'Módulo de ventas o ingresos: ingresos por fuente, meses de operación y agregados económicos';
COMMENT ON COLUMN staging.ventas.directorio IS 'Directorio (identificador del hogar)';
COMMENT ON COLUMN staging.ventas.secuencia_p IS 'Secuencia P (persona dentro del hogar)';
COMMENT ON COLUMN staging.ventas.secuencia_encuesta IS 'Secuencia Encuesta (negocio de la persona)';
COMMENT ON COLUMN staging.ventas.p3057 IS 'Ventas de productos elaborados (mes anterior)';
COMMENT ON COLUMN staging.ventas.p3058 IS 'Servicio de maquila (mes anterior)';
COMMENT ON COLUMN staging.ventas.p3059 IS 'Servicios de reparación y mantenimiento (mes anterior)';
COMMENT ON COLUMN staging.ventas.p3060 IS 'Otros ingresos (mes anterior)';
COMMENT ON COLUMN staging.ventas.p3061 IS 'Venta de mercancía (mes anterior)';
COMMENT ON COLUMN staging.ventas.p3062 IS 'Por consignación o comisión (mes anterior)';
COMMENT ON COLUMN staging.ventas.p4002 IS 'Servicios de reparación y mantenimiento (mes anterior)';
COMMENT ON COLUMN staging.ventas.p3063 IS 'Otros ingresos (mes anterior)';
COMMENT ON COLUMN staging.ventas.p3064 IS 'Ingresos por los servicios ofrecidos (mes anterior)';
COMMENT ON COLUMN staging.ventas.p3065 IS 'Ingresos por mantenimiento y reparación (mes anterior)';
COMMENT ON COLUMN staging.ventas.p3066 IS 'Por ventas de mercancías (mes anterior)';
COMMENT ON COLUMN staging.ventas.p3067 IS 'Otros ingresos (mes anterior)';
COMMENT ON COLUMN staging.ventas.p3092 IS 'Ingresos por venta de productos agrícolas, ganaderos, pesqueros o mineros (mes anterior)';
COMMENT ON COLUMN staging.ventas.p3093 IS 'Otros ingresos (mes anterior)';
COMMENT ON COLUMN staging.ventas.p4036 IS 'Variable de control interno del módulo de ventas (sin descripción semántica en el diccionario DANE)';
COMMENT ON COLUMN staging.ventas.p4005 IS 'Ventas de productos elaborados (mismo mes año anterior)';
COMMENT ON COLUMN staging.ventas.p4006 IS 'Servicio de maquila (mismo mes año anterior)';
COMMENT ON COLUMN staging.ventas.p4007 IS 'Servicios de reparación y mantenimiento (mismo mes año anterior)';
COMMENT ON COLUMN staging.ventas.p4008 IS 'Otros ingresos (mismo mes año anterior)';
COMMENT ON COLUMN staging.ventas.p4009 IS 'Venta de mercancía (mismo mes año anterior)';
COMMENT ON COLUMN staging.ventas.p4010 IS 'Por consignación o comisión (mismo mes año anterior)';
COMMENT ON COLUMN staging.ventas.p4011 IS 'Servicios de reparación y mantenimiento (mismo mes año anterior)';
COMMENT ON COLUMN staging.ventas.p4012 IS 'Otros ingresos (mismo mes año anterior)';
COMMENT ON COLUMN staging.ventas.p4013 IS 'Ingresos por los servicios ofrecidos (mismo mes año anterior)';
COMMENT ON COLUMN staging.ventas.p4014 IS 'Ingresos por mantenimiento y reparación (mismo mes año anterior)';
COMMENT ON COLUMN staging.ventas.p4015 IS 'Por ventas de mercancías (mismo mes año anterior)';
COMMENT ON COLUMN staging.ventas.p4016 IS 'Otros ingresos (mismo mes año anterior)';
COMMENT ON COLUMN staging.ventas.p4017 IS 'Ingresos por venta de productos agrícolas, ganaderos, pesqueros o mineros (mismo mes año anterior)';
COMMENT ON COLUMN staging.ventas.p4018 IS 'Otros ingresos (mismo mes año anterior)';
COMMENT ON COLUMN staging.ventas.p4037 IS 'Variable de control interno del módulo de ventas (sin descripción semántica en el diccionario DANE)';
COMMENT ON COLUMN staging.ventas.p3068_ene IS 'Meses de funcionamiento año anterior: enero';
COMMENT ON COLUMN staging.ventas.p3068_feb IS 'Meses de funcionamiento año anterior: febrero';
COMMENT ON COLUMN staging.ventas.p3068_mar IS 'Meses de funcionamiento año anterior: marzo';
COMMENT ON COLUMN staging.ventas.p3068_abr IS 'Meses de funcionamiento año anterior: abril';
COMMENT ON COLUMN staging.ventas.p3068_may IS 'Meses de funcionamiento año anterior: mayo';
COMMENT ON COLUMN staging.ventas.p3068_jun IS 'Meses de funcionamiento año anterior: junio';
COMMENT ON COLUMN staging.ventas.p3068_jul IS 'Meses de funcionamiento año anterior: julio';
COMMENT ON COLUMN staging.ventas.p3068_ago IS 'Meses de funcionamiento año anterior: agosto';
COMMENT ON COLUMN staging.ventas.p3068_sep IS 'Meses de funcionamiento año anterior: septiembre';
COMMENT ON COLUMN staging.ventas.p3068_oct IS 'Meses de funcionamiento año anterior: octubre';
COMMENT ON COLUMN staging.ventas.p3068_nov IS 'Meses de funcionamiento año anterior: noviembre';
COMMENT ON COLUMN staging.ventas.p3068_dic IS 'Meses de funcionamiento año anterior: diciembre';
COMMENT ON COLUMN staging.ventas.p3068_tod IS 'Meses de funcionamiento año anterior: todos';
COMMENT ON COLUMN staging.ventas.p3068_nin IS 'Meses de funcionamiento año anterior: ninguno';
COMMENT ON COLUMN staging.ventas.p4019 IS 'Ventas de productos elaborados (año anterior)';
COMMENT ON COLUMN staging.ventas.p4020 IS 'Servicio de maquila (año anterior)';
COMMENT ON COLUMN staging.ventas.p4021 IS 'Servicios de reparación y mantenimiento (año anterior)';
COMMENT ON COLUMN staging.ventas.p4022 IS 'Otros ingresos (año anterior)';
COMMENT ON COLUMN staging.ventas.p4023 IS 'Venta de mercancía (año anterior)';
COMMENT ON COLUMN staging.ventas.p4024 IS 'Por consignación o comisión (año anterior)';
COMMENT ON COLUMN staging.ventas.p4025 IS 'Servicios de reparación y mantenimiento (año anterior)';
COMMENT ON COLUMN staging.ventas.p4026 IS 'Otros ingresos (año anterior)';
COMMENT ON COLUMN staging.ventas.p4027 IS 'Ingresos por los servicios ofrecidos (año anterior)';
COMMENT ON COLUMN staging.ventas.p4028 IS 'Ingresos por mantenimiento y reparación (año anterior)';
COMMENT ON COLUMN staging.ventas.p4029 IS 'Por ventas de mercancías (año anterior)';
COMMENT ON COLUMN staging.ventas.p4030 IS 'Otros ingresos (año anterior)';
COMMENT ON COLUMN staging.ventas.p4031 IS 'Ingresos por venta de productos agrícolas, ganaderos, pesqueros o mineros (año anterior)';
COMMENT ON COLUMN staging.ventas.p4032 IS 'Otros ingresos (año anterior)';
COMMENT ON COLUMN staging.ventas.p4038 IS 'Ventas o ingresos totales (año anterior)';
COMMENT ON COLUMN staging.ventas.p3072 IS 'En promedio ¿cuánto le deja su negocio o actividad al mes?';
COMMENT ON COLUMN staging.ventas.ventas_mes_anterior IS 'Ventas o ingresos mensuales (calculada DANE)';
COMMENT ON COLUMN staging.ventas.ventas_mes_anio_anterior IS 'Ventas o ingresos del mismo mes del año anterior (calculada DANE)';
COMMENT ON COLUMN staging.ventas.ventas_anio_anterior IS 'Ventas o ingresos del año anterior (calculada DANE)';
COMMENT ON COLUMN staging.ventas.valor_agregado IS 'Valor agregado mensual (calculada DANE)';
COMMENT ON COLUMN staging.ventas.ingreso_mixto IS 'Ingreso mixto mensual (calculada DANE)';
COMMENT ON COLUMN staging.ventas.clase_te IS 'Clase (cabecera / centros poblados y rural disperso)';
COMMENT ON COLUMN staging.ventas.cod_depto IS 'Departamento (código DANE)';
COMMENT ON COLUMN staging.ventas.area IS 'Ciudades principales y áreas metropolitanas';
COMMENT ON COLUMN staging.ventas.f_exp IS 'Factor de expansión del módulo (referencia, NO usar en agregaciones)';
COMMENT ON COLUMN staging.ventas.fex_c IS 'Factor de expansión departamental oficial 2023';

-- 2.5 Factores de expansión
DROP TABLE IF EXISTS staging.factores_exp CASCADE;
CREATE TABLE staging.factores_exp (
    directorio          INTEGER NOT NULL,
    secuencia_p         INTEGER NOT NULL,
    secuencia_encuesta  INTEGER NOT NULL,
    fex_c               NUMERIC(20,10),
    CONSTRAINT pk_factores_exp PRIMARY KEY (directorio, secuencia_p, secuencia_encuesta)
);

COMMENT ON TABLE staging.factores_exp IS 'Factores de expansión departamentales 2023 (fuente oficial de fex_c)';
COMMENT ON COLUMN staging.factores_exp.directorio IS 'Directorio (identificador del hogar)';
COMMENT ON COLUMN staging.factores_exp.secuencia_p IS 'Secuencia P (persona dentro del hogar)';
COMMENT ON COLUMN staging.factores_exp.secuencia_encuesta IS 'Secuencia Encuesta (negocio de la persona)';
COMMENT ON COLUMN staging.factores_exp.fex_c IS 'Factor de expansión departamental oficial 2023 (usar en TODA agregación poblacional)';

-- 2.6 Inclusión financiera (módulo diferenciador)
DROP TABLE IF EXISTS staging.inclusion_financiera CASCADE;
CREATE TABLE staging.inclusion_financiera (
    directorio          INTEGER NOT NULL,
    secuencia_p         INTEGER NOT NULL,
    secuencia_encuesta  INTEGER NOT NULL,
    p1764_1             INTEGER,
    p1764_2             INTEGER,
    p1764_3             INTEGER,
    p1764_4             INTEGER,
    p1764_5             INTEGER,
    p1764_6             INTEGER,
    p1764_7             INTEGER,
    p1765               INTEGER,
    p1567               INTEGER,
    p1569               INTEGER,
    p1568               INTEGER,
    p1571_1             INTEGER,
    p1571_2             INTEGER,
    p1571_3             INTEGER,
    p1571_4             INTEGER,
    p1571_5             INTEGER,
    p1571_6             INTEGER,
    p1570               INTEGER,
    p1570_1             NUMERIC(15,2),
    p1570_2             NUMERIC(15,2),
    p1572_1             INTEGER,
    p1572_2             INTEGER,
    p1572_3             INTEGER,
    p1572_4             INTEGER,
    p1572_5             INTEGER,
    p1572_6             INTEGER,
    p3014               INTEGER,
    p1573_1             INTEGER,
    p1573_2             INTEGER,
    p1573_3             INTEGER,
    p1573_4             INTEGER,
    p1573_5             INTEGER,
    p1573_6             INTEGER,
    p1574               INTEGER,
    p1771               INTEGER,
    clase_te            INTEGER,
    cod_depto           VARCHAR(2),
    area                VARCHAR(2),
    f_exp               NUMERIC(20,10),
    fex_c               NUMERIC(20,10),
    CONSTRAINT pk_inclusion_financiera
        PRIMARY KEY (directorio, secuencia_p, secuencia_encuesta)
);

COMMENT ON TABLE staging.inclusion_financiera IS 'Módulo de inclusión financiera: crédito, medios de pago y ahorro';
COMMENT ON COLUMN staging.inclusion_financiera.directorio IS 'Directorio (identificador del hogar)';
COMMENT ON COLUMN staging.inclusion_financiera.secuencia_p IS 'Secuencia P (persona dentro del hogar)';
COMMENT ON COLUMN staging.inclusion_financiera.secuencia_encuesta IS 'Secuencia Encuesta (negocio de la persona)';
COMMENT ON COLUMN staging.inclusion_financiera.p1764_1 IS '¿Cuáles formas de pago acepta en su negocio? (opción 1 de respuesta múltiple)';
COMMENT ON COLUMN staging.inclusion_financiera.p1764_2 IS '¿Cuáles formas de pago acepta en su negocio? (opción 2 de respuesta múltiple)';
COMMENT ON COLUMN staging.inclusion_financiera.p1764_3 IS '¿Cuáles formas de pago acepta en su negocio? (opción 3 de respuesta múltiple)';
COMMENT ON COLUMN staging.inclusion_financiera.p1764_4 IS '¿Cuáles formas de pago acepta en su negocio? (opción 4 de respuesta múltiple)';
COMMENT ON COLUMN staging.inclusion_financiera.p1764_5 IS '¿Cuáles formas de pago acepta en su negocio? (opción 5 de respuesta múltiple)';
COMMENT ON COLUMN staging.inclusion_financiera.p1764_6 IS '¿Cuáles formas de pago acepta en su negocio? (opción 6 de respuesta múltiple)';
COMMENT ON COLUMN staging.inclusion_financiera.p1764_7 IS '¿Cuáles formas de pago acepta en su negocio? (opción 7 de respuesta múltiple)';
COMMENT ON COLUMN staging.inclusion_financiera.p1765 IS 'En el año anterior ¿solicitó algún crédito o préstamo para la gestión de su negocio o actividad económica?';
COMMENT ON COLUMN staging.inclusion_financiera.p1567 IS '¿Por qué no ha solicitado algún crédito o préstamo?';
COMMENT ON COLUMN staging.inclusion_financiera.p1569 IS '¿A quién solicitó el préstamo?';
COMMENT ON COLUMN staging.inclusion_financiera.p1568 IS '¿Obtuvo el crédito o préstamo solicitado?';
COMMENT ON COLUMN staging.inclusion_financiera.p1571_1 IS '¿Por qué no obtuvo el crédito o préstamo solicitado? (opción 1 de respuesta múltiple)';
COMMENT ON COLUMN staging.inclusion_financiera.p1571_2 IS '¿Por qué no obtuvo el crédito o préstamo solicitado? (opción 2 de respuesta múltiple)';
COMMENT ON COLUMN staging.inclusion_financiera.p1571_3 IS '¿Por qué no obtuvo el crédito o préstamo solicitado? (opción 3 de respuesta múltiple)';
COMMENT ON COLUMN staging.inclusion_financiera.p1571_4 IS '¿Por qué no obtuvo el crédito o préstamo solicitado? (opción 4 de respuesta múltiple)';
COMMENT ON COLUMN staging.inclusion_financiera.p1571_5 IS '¿Por qué no obtuvo el crédito o préstamo solicitado? (opción 5 de respuesta múltiple)';
COMMENT ON COLUMN staging.inclusion_financiera.p1571_6 IS '¿Por qué no obtuvo el crédito o préstamo solicitado? (opción 6 de respuesta múltiple)';
COMMENT ON COLUMN staging.inclusion_financiera.p1570 IS '¿Para qué utilizó (o va utilizar) el crédito que solicitó?';
COMMENT ON COLUMN staging.inclusion_financiera.p1570_1 IS 'Porcentaje invertido en el negocio';
COMMENT ON COLUMN staging.inclusion_financiera.p1570_2 IS 'Porcentaje para cubrir gastos personales u otros';
COMMENT ON COLUMN staging.inclusion_financiera.p1572_1 IS '¿El dinero destinado al negocio lo gastó en? (opción 1 de respuesta múltiple)';
COMMENT ON COLUMN staging.inclusion_financiera.p1572_2 IS '¿El dinero destinado al negocio lo gastó en? (opción 2 de respuesta múltiple)';
COMMENT ON COLUMN staging.inclusion_financiera.p1572_3 IS '¿El dinero destinado al negocio lo gastó en? (opción 3 de respuesta múltiple)';
COMMENT ON COLUMN staging.inclusion_financiera.p1572_4 IS '¿El dinero destinado al negocio lo gastó en? (opción 4 de respuesta múltiple)';
COMMENT ON COLUMN staging.inclusion_financiera.p1572_5 IS '¿El dinero destinado al negocio lo gastó en? (opción 5 de respuesta múltiple)';
COMMENT ON COLUMN staging.inclusion_financiera.p1572_6 IS '¿El dinero destinado al negocio lo gastó en? (opción 6 de respuesta múltiple)';
COMMENT ON COLUMN staging.inclusion_financiera.p3014 IS 'En el año anterior ¿Ahorró dinero de su negocio o actividad?';
COMMENT ON COLUMN staging.inclusion_financiera.p1573_1 IS '¿En qué va a usar o usó el dinero que ahorró? (opción 1 de respuesta múltiple)';
COMMENT ON COLUMN staging.inclusion_financiera.p1573_2 IS '¿En qué va a usar o usó el dinero que ahorró? (opción 2 de respuesta múltiple)';
COMMENT ON COLUMN staging.inclusion_financiera.p1573_3 IS '¿En qué va a usar o usó el dinero que ahorró? (opción 3 de respuesta múltiple)';
COMMENT ON COLUMN staging.inclusion_financiera.p1573_4 IS '¿En qué va a usar o usó el dinero que ahorró? (opción 4 de respuesta múltiple)';
COMMENT ON COLUMN staging.inclusion_financiera.p1573_5 IS '¿En qué va a usar o usó el dinero que ahorró? (opción 5 de respuesta múltiple)';
COMMENT ON COLUMN staging.inclusion_financiera.p1573_6 IS '¿En qué va a usar o usó el dinero que ahorró? (opción 6 de respuesta múltiple)';
COMMENT ON COLUMN staging.inclusion_financiera.p1574 IS '¿Por qué no ahorró?';
COMMENT ON COLUMN staging.inclusion_financiera.p1771 IS '¿En dónde ahorró?';
COMMENT ON COLUMN staging.inclusion_financiera.clase_te IS 'Clase (cabecera / centros poblados y rural disperso)';
COMMENT ON COLUMN staging.inclusion_financiera.cod_depto IS 'Departamento (código DANE)';
COMMENT ON COLUMN staging.inclusion_financiera.area IS 'Ciudades principales y áreas metropolitanas';
COMMENT ON COLUMN staging.inclusion_financiera.f_exp IS 'Factor de expansión del módulo (referencia, NO usar en agregaciones)';
COMMENT ON COLUMN staging.inclusion_financiera.fex_c IS 'Factor de expansión departamental oficial 2023';

-- ============================================================================
-- 3. ÍNDICES
-- Aceleran los filtros y joins más frecuentes en las queries de negocio:
-- cod_depto / grupos4 / grupos12 / area para cruces geográficos y
-- sectoriales, y fex_c para agregaciones ponderadas.
-- ============================================================================

-- 3.1 Identificación
CREATE INDEX idx_identificacion_depto   ON staging.identificacion (cod_depto);
CREATE INDEX idx_identificacion_grupos4  ON staging.identificacion (grupos4);
CREATE INDEX idx_identificacion_grupos12 ON staging.identificacion (grupos12);
CREATE INDEX idx_identificacion_fexc     ON staging.identificacion (fex_c);

-- 3.2 Características
CREATE INDEX idx_caracteristicas_depto   ON staging.caracteristicas (cod_depto);
CREATE INDEX idx_caracteristicas_fexc    ON staging.caracteristicas (fex_c);

-- 3.3 Ubicación
CREATE INDEX idx_ubicacion_depto         ON staging.ubicacion (cod_depto);
CREATE INDEX idx_ubicacion_fexc          ON staging.ubicacion (fex_c);

-- 3.4 Ventas
CREATE INDEX idx_ventas_depto            ON staging.ventas (cod_depto);
CREATE INDEX idx_ventas_fexc             ON staging.ventas (fex_c);

-- 3.5 Factores de expansión
CREATE INDEX idx_factores_exp_fexc       ON staging.factores_exp (fex_c);

-- 3.6 Inclusión financiera
CREATE INDEX idx_inclusion_financiera_depto
    ON staging.inclusion_financiera (cod_depto);
CREATE INDEX idx_inclusion_financiera_area
    ON staging.inclusion_financiera (area);
CREATE INDEX idx_inclusion_financiera_fexc
    ON staging.inclusion_financiera (fex_c);
