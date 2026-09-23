-- ============================================================
-- PROYECTO 01 - INTELIGENCIA DE NEGOCIOS
-- GRUPO 3 - CADENA HOTELERA
-- SCRIPT DDL - MODELO TRANSACCIONAL
-- Elaborado por: Tamara Ortega, Daniela Sánchez, Rachel Rojas, Raúl Rojas y Melody Coto
-- ============================================================

-- Database: cadena_hotelera_g3

DROP DATABASE IF EXISTS cadena_hotelera_g3;

CREATE DATABASE cadena_hotelera_g3
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'Spanish_Spain.1252'
    LC_CTYPE = 'Spanish_Spain.1252'
    LOCALE_PROVIDER = 'libc'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;

DROP SCHEMA IF EXISTS operacional CASCADE;

CREATE SCHEMA operacional;

SET search_path TO operacional, public;

CREATE TABLE hotel (
    id_hotel BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    ciudad VARCHAR(80) NOT NULL,
    provincia VARCHAR(80) NOT NULL,

    categoria_estrellas SMALLINT NOT NULL
        CHECK (categoria_estrellas BETWEEN 1 AND 5),

    activo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE tipo_habitacion (
    id_tipo_habitacion BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    nombre VARCHAR(60) NOT NULL UNIQUE,

    capacidad SMALLINT NOT NULL
        CHECK (capacidad > 0),

    tarifa_base NUMERIC(10,2) NOT NULL
        CHECK (tarifa_base >= 0),

    descripcion VARCHAR(200)
);

CREATE TABLE habitacion (
    id_habitacion BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    id_hotel BIGINT NOT NULL,
    id_tipo_habitacion BIGINT NOT NULL,

    numero_habitacion VARCHAR(10) NOT NULL,

    estado VARCHAR(20) NOT NULL DEFAULT 'ACTIVA'
        CHECK (
            estado IN (
                'ACTIVA',
                'MANTENIMIENTO',
                'INACTIVA'
            )
        ),

    CONSTRAINT fk_habitacion_hotel
        FOREIGN KEY (id_hotel)
        REFERENCES hotel(id_hotel),

    CONSTRAINT fk_habitacion_tipo
        FOREIGN KEY (id_tipo_habitacion)
        REFERENCES tipo_habitacion(id_tipo_habitacion),

    CONSTRAINT uq_habitacion_hotel_numero
        UNIQUE (id_hotel, numero_habitacion)
);


CREATE TABLE segmento_huesped (
    id_segmento BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    nombre VARCHAR(60) NOT NULL UNIQUE,

    descripcion VARCHAR(200)
);

CREATE TABLE huesped (
    id_huesped BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    id_segmento BIGINT NOT NULL,

    nombre VARCHAR(120) NOT NULL,

    pais_origen VARCHAR(80),

    fecha_nacimiento DATE,

    correo VARCHAR(150) UNIQUE,

    CONSTRAINT fk_huesped_segmento
        FOREIGN KEY (id_segmento)
        REFERENCES segmento_huesped(id_segmento)
);

CREATE TABLE canal_reserva (
    id_canal BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    nombre VARCHAR(60) NOT NULL UNIQUE
);

CREATE TABLE temporada (
    id_temporada BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    nombre VARCHAR(80) NOT NULL,

    tipo VARCHAR(20) NOT NULL
        CHECK (tipo IN ('ALTA', 'BAJA')),

    fecha_inicio DATE NOT NULL,

    fecha_fin DATE NOT NULL,

    CONSTRAINT chk_temporada_fechas
        CHECK (fecha_fin >= fecha_inicio)
);

CREATE TABLE plan_tarifa (
    id_plan_tarifa BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    nombre VARCHAR(80) NOT NULL UNIQUE,

    reembolsable BOOLEAN NOT NULL
);

CREATE TABLE tarifa (
    id_tarifa BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    id_hotel BIGINT NOT NULL,

    id_tipo_habitacion BIGINT NOT NULL,

    id_temporada BIGINT NOT NULL,

    id_plan_tarifa BIGINT NOT NULL,

    precio_noche NUMERIC(10,2) NOT NULL
        CHECK (precio_noche >= 0),

    CONSTRAINT fk_tarifa_hotel
        FOREIGN KEY (id_hotel)
        REFERENCES hotel(id_hotel),

    CONSTRAINT fk_tarifa_tipo
        FOREIGN KEY (id_tipo_habitacion)
        REFERENCES tipo_habitacion(id_tipo_habitacion),

    CONSTRAINT fk_tarifa_temporada
        FOREIGN KEY (id_temporada)
        REFERENCES temporada(id_temporada),

    CONSTRAINT fk_tarifa_plan
        FOREIGN KEY (id_plan_tarifa)
        REFERENCES plan_tarifa(id_plan_tarifa),

    CONSTRAINT uq_tarifa
        UNIQUE (
            id_hotel,
            id_tipo_habitacion,
            id_temporada,
            id_plan_tarifa
        )
);

CREATE TABLE reserva (
    id_reserva BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    codigo_reserva VARCHAR(20) NOT NULL UNIQUE,

    id_huesped BIGINT NOT NULL,

    id_canal BIGINT NOT NULL,

    fecha_reserva DATE NOT NULL,

    fecha_entrada_prevista DATE NOT NULL,

    fecha_salida_prevista DATE NOT NULL,

    estado VARCHAR(20) NOT NULL
        CHECK (
            estado IN (
                'CONFIRMADA',
                'CANCELADA',
                'NO_SHOW',
                'COMPLETADA'
            )
        ),

    fecha_cancelacion DATE,

    motivo_cancelacion VARCHAR(200),

    CONSTRAINT fk_reserva_huesped
        FOREIGN KEY (id_huesped)
        REFERENCES huesped(id_huesped),

    CONSTRAINT fk_reserva_canal
        FOREIGN KEY (id_canal)
        REFERENCES canal_reserva(id_canal),

    CONSTRAINT chk_reserva_fechas
        CHECK (
            fecha_reserva <= fecha_entrada_prevista
            AND
            fecha_salida_prevista > fecha_entrada_prevista
        ),

    CONSTRAINT chk_cancelacion
        CHECK (
            (
                estado = 'CANCELADA'
                AND fecha_cancelacion IS NOT NULL
                AND motivo_cancelacion IS NOT NULL
                AND fecha_cancelacion >= fecha_reserva
                AND fecha_cancelacion <= fecha_entrada_prevista
            )
            OR
            (
                estado <> 'CANCELADA'
                AND fecha_cancelacion IS NULL
                AND motivo_cancelacion IS NULL
            )
        )
);

CREATE TABLE detalle_reserva (
    id_detalle_reserva BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    id_reserva BIGINT NOT NULL,

    id_habitacion BIGINT NOT NULL,

    id_tarifa BIGINT NOT NULL,

    cantidad_noches INTEGER NOT NULL
        CHECK (cantidad_noches > 0),

    precio_noche NUMERIC(10,2) NOT NULL
        CHECK (precio_noche >= 0),

    subtotal_alojamiento NUMERIC(12,2)
        GENERATED ALWAYS AS (
            cantidad_noches * precio_noche
        ) STORED,

    CONSTRAINT fk_detalle_reserva
        FOREIGN KEY (id_reserva)
        REFERENCES reserva(id_reserva),

    CONSTRAINT fk_detalle_habitacion
        FOREIGN KEY (id_habitacion)
        REFERENCES habitacion(id_habitacion),

    CONSTRAINT fk_detalle_tarifa
        FOREIGN KEY (id_tarifa)
        REFERENCES tarifa(id_tarifa),

    CONSTRAINT uq_reserva_habitacion
        UNIQUE (id_reserva, id_habitacion)
);

CREATE TABLE estadia (
    id_estadia BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    id_detalle_reserva BIGINT NOT NULL UNIQUE,

    fecha_checkin DATE NOT NULL,

    fecha_checkout DATE NOT NULL,

    CONSTRAINT fk_estadia_detalle
        FOREIGN KEY (id_detalle_reserva)
        REFERENCES detalle_reserva(id_detalle_reserva),

    CONSTRAINT chk_estadia_fechas
        CHECK (fecha_checkout > fecha_checkin)
);

CREATE TABLE servicio (
    id_servicio BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    nombre VARCHAR(100) NOT NULL UNIQUE,

    categoria VARCHAR(60) NOT NULL,

    precio_base NUMERIC(10,2) NOT NULL
        CHECK (precio_base >= 0)
);

CREATE TABLE consumo_servicio (
    id_consumo BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    id_estadia BIGINT NOT NULL,

    id_servicio BIGINT NOT NULL,

    fecha_consumo DATE NOT NULL,

    cantidad INTEGER NOT NULL
        CHECK (cantidad > 0),

    precio_unitario NUMERIC(10,2) NOT NULL
        CHECK (precio_unitario >= 0),

    total NUMERIC(12,2)
        GENERATED ALWAYS AS (
            cantidad * precio_unitario
        ) STORED,

    CONSTRAINT fk_consumo_estadia
        FOREIGN KEY (id_estadia)
        REFERENCES estadia(id_estadia),

    CONSTRAINT fk_consumo_servicio
        FOREIGN KEY (id_servicio)
        REFERENCES servicio(id_servicio)
);

CREATE INDEX idx_habitacion_hotel
    ON habitacion(id_hotel);

CREATE INDEX idx_habitacion_tipo
    ON habitacion(id_tipo_habitacion);

CREATE INDEX idx_huesped_segmento
    ON huesped(id_segmento);

CREATE INDEX idx_reserva_huesped
    ON reserva(id_huesped);

CREATE INDEX idx_reserva_canal
    ON reserva(id_canal);

CREATE INDEX idx_reserva_estado
    ON reserva(estado);

CREATE INDEX idx_reserva_fecha_entrada
    ON reserva(fecha_entrada_prevista);

CREATE INDEX idx_tarifa_hotel
    ON tarifa(id_hotel);

CREATE INDEX idx_tarifa_tipo
    ON tarifa(id_tipo_habitacion);

CREATE INDEX idx_tarifa_temporada
    ON tarifa(id_temporada);

CREATE INDEX idx_tarifa_plan
    ON tarifa(id_plan_tarifa);

CREATE INDEX idx_detalle_reserva
    ON detalle_reserva(id_reserva);

CREATE INDEX idx_detalle_habitacion
    ON detalle_reserva(id_habitacion);

CREATE INDEX idx_estadia_checkin
    ON estadia(fecha_checkin);

CREATE INDEX idx_consumo_estadia
    ON consumo_servicio(id_estadia);

CREATE INDEX idx_consumo_servicio
    ON consumo_servicio(id_servicio);

CREATE INDEX idx_consumo_fecha
    ON consumo_servicio(fecha_consumo);