-- ============================================================
-- PROYECTO BI - CADENA HOTELERA
-- MODELO DIMENSIONAL - DDL
--
-- Este script crea:
--   6 dimensiones
--   1 tabla de hechos
--
-- No inserta datos.
-- ============================================================

CREATE SCHEMA IF NOT EXISTS dimensional;


-- ============================================================
-- DIM_HOTEL
-- ============================================================

DROP TABLE IF EXISTS dimensional.fact_reservas CASCADE;
DROP TABLE IF EXISTS dimensional.dim_hotel CASCADE;
DROP TABLE IF EXISTS dimensional.dim_habitacion CASCADE;
DROP TABLE IF EXISTS dimensional.dim_canal CASCADE;
DROP TABLE IF EXISTS dimensional.dim_cliente CASCADE;
DROP TABLE IF EXISTS dimensional.dim_tarifa CASCADE;
DROP TABLE IF EXISTS dimensional.dim_fecha CASCADE;


CREATE TABLE dimensional.dim_hotel (
    id_hotel BIGINT PRIMARY KEY,
    nombre_hotel VARCHAR(150),
    ciudad VARCHAR(100),
    categoria VARCHAR(50),
    total_habitaciones_disponibles INTEGER
);


-- ============================================================
-- DIM_HABITACION
-- ============================================================

CREATE TABLE dimensional.dim_habitacion (
    id_habitacion BIGINT PRIMARY KEY,
    tipo_habitacion VARCHAR(100),
    capacidad INTEGER
);


-- ============================================================
-- DIM_CANAL
-- ============================================================

CREATE TABLE dimensional.dim_canal (
    id_canal BIGINT PRIMARY KEY,
    nombre_canal VARCHAR(100),
    tipo_canal VARCHAR(100)
);


-- ============================================================
-- DIM_CLIENTE
-- ============================================================

CREATE TABLE dimensional.dim_cliente (
    id_cliente BIGINT PRIMARY KEY,
    nombre VARCHAR(150),
    segmento_cliente VARCHAR(100),
    perfil_huesped VARCHAR(100)
);


-- ============================================================
-- DIM_TARIFA
-- ============================================================

CREATE TABLE dimensional.dim_tarifa (
    id_tarifa BIGINT PRIMARY KEY,
    codigo_tarifa VARCHAR(100),
    descripcion_tarifa VARCHAR(255)
);


-- ============================================================
-- DIM_FECHA
-- ============================================================

CREATE TABLE dimensional.dim_fecha (
    id_fecha INTEGER PRIMARY KEY,
    fecha DATE NOT NULL,
    anio INTEGER,
    trimestre INTEGER,
    mes INTEGER,
    dia_de_la_semana VARCHAR(20),
    temporada VARCHAR(50)
);


-- ============================================================
-- FACT_RESERVAS
-- Granularidad: una fila por reserva
-- ============================================================

CREATE TABLE dimensional.fact_reservas (

    id_reserva BIGINT PRIMARY KEY,

    id_canal BIGINT,
    id_hotel BIGINT,
    id_fecha_reserva INTEGER,
    id_habitacion BIGINT,
    id_cliente BIGINT,
    id_tarifa BIGINT,
    id_fecha_checkin INTEGER,

    duracion_estadia_noches INTEGER,

    ingreso_alojamiento NUMERIC(14,2),

    ingreso_desayuno NUMERIC(14,2),
    ingreso_almuerzo NUMERIC(14,2),
    ingreso_cena NUMERIC(14,2),
    ingreso_spa NUMERIC(14,2),
    ingreso_lavanderia NUMERIC(14,2),
    ingreso_tour NUMERIC(14,2),
    ingreso_transporte NUMERIC(14,2),
    ingreso_room_service NUMERIC(14,2),

    ingreso_servicios_complementarios NUMERIC(14,2),

    es_cancelacion BOOLEAN,
    es_noshow BOOLEAN,

    CONSTRAINT fk_fact_canal
        FOREIGN KEY (id_canal)
        REFERENCES dimensional.dim_canal(id_canal),

    CONSTRAINT fk_fact_hotel
        FOREIGN KEY (id_hotel)
        REFERENCES dimensional.dim_hotel(id_hotel),

    CONSTRAINT fk_fact_fecha_reserva
        FOREIGN KEY (id_fecha_reserva)
        REFERENCES dimensional.dim_fecha(id_fecha),

    CONSTRAINT fk_fact_habitacion
        FOREIGN KEY (id_habitacion)
        REFERENCES dimensional.dim_habitacion(id_habitacion),

    CONSTRAINT fk_fact_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES dimensional.dim_cliente(id_cliente),

    CONSTRAINT fk_fact_tarifa
        FOREIGN KEY (id_tarifa)
        REFERENCES dimensional.dim_tarifa(id_tarifa),

    CONSTRAINT fk_fact_fecha_checkin
        FOREIGN KEY (id_fecha_checkin)
        REFERENCES dimensional.dim_fecha(id_fecha)
);
