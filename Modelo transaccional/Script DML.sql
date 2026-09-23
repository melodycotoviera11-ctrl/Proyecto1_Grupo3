-- ============================================================
-- PROYECTO 01 - INTELIGENCIA DE NEGOCIOS
-- GRUPO 3 - CADENA HOTELERA
-- SCRIPT DML - GENERACIÓN DE DATOS TRANSACCIONALES
-- Elaborado por: Tamara Ortega, Daniela Sánchez, Rachel Rojas, Raúl Rojas y Melody Coto
-- ============================================================

SET search_path TO operacional, public;


-- ============================================================
-- 1. HOTELES
-- ============================================================

INSERT INTO hotel
(
    nombre,
    ciudad,
    provincia,
    categoria_estrellas
)
VALUES
('Hotel Central', 'San José', 'San José', 4),
('Hotel Montaña', 'Cartago', 'Cartago', 4),
('Hotel Pacífico', 'Puntarenas', 'Puntarenas', 5),
('Hotel Caribe', 'Limón', 'Limón', 4),
('Hotel Guanacaste', 'Liberia', 'Guanacaste', 5);


-- ============================================================
-- 2. TIPOS DE HABITACIÓN
-- ============================================================

INSERT INTO tipo_habitacion
(
    nombre,
    capacidad,
    tarifa_base,
    descripcion
)
VALUES
(
    'Estándar',
    2,
    65000,
    'Habitación estándar para una o dos personas'
),
(
    'Doble',
    4,
    85000,
    'Habitación con capacidad para cuatro personas'
),
(
    'Suite',
    2,
    125000,
    'Habitación tipo suite'
),
(
    'Familiar',
    6,
    145000,
    'Habitación destinada a grupos familiares'
);


-- ============================================================
-- 3. SEGMENTOS DE HUÉSPED
-- ============================================================

INSERT INTO segmento_huesped
(
    nombre,
    descripcion
)
VALUES
(
    'Individual',
    'Personas que viajan individualmente'
),
(
    'Pareja',
    'Huéspedes que viajan en pareja'
),
(
    'Familia',
    'Reservas asociadas a grupos familiares'
),
(
    'Corporativo',
    'Clientes relacionados con viajes de negocios'
);


-- ============================================================
-- 4. CANALES DE RESERVA
-- ============================================================

INSERT INTO canal_reserva(nombre)
VALUES
('Sitio web'),
('Agencia'),
('OTA'),
('Teléfono'),
('Recepción');


-- ============================================================
-- 5. PLANES TARIFARIOS
-- ============================================================

INSERT INTO plan_tarifa
(
    nombre,
    reembolsable
)
VALUES
('Flexible', TRUE),
('No reembolsable', FALSE),
('Corporativa', TRUE);


-- ============================================================
-- 6. TEMPORADAS
-- Reglas sintéticas definidas para el caso académico.
-- ============================================================

INSERT INTO temporada
(
    nombre,
    tipo,
    fecha_inicio,
    fecha_fin
)
VALUES
('Alta 2025 I', 'ALTA', '2025-01-01', '2025-04-30'),
('Baja 2025', 'BAJA', '2025-05-01', '2025-10-31'),
('Alta 2025 II', 'ALTA', '2025-11-01', '2025-12-31'),

('Alta 2026 I', 'ALTA', '2026-01-01', '2026-04-30'),
('Baja 2026', 'BAJA', '2026-05-01', '2026-10-31'),
('Alta 2026 II', 'ALTA', '2026-11-01', '2026-12-31');


-- ============================================================
-- 7. SERVICIOS COMPLEMENTARIOS
-- ============================================================

INSERT INTO servicio
(
    nombre,
    categoria,
    precio_base
)
VALUES
('Desayuno', 'Alimentación', 8000),
('Almuerzo', 'Alimentación', 12000),
('Cena', 'Alimentación', 15000),
('Spa', 'Bienestar', 35000),
('Lavandería', 'Servicios', 10000),
('Tour', 'Entretenimiento', 30000),
('Transporte', 'Transporte', 25000),
('Room Service', 'Alimentación', 12000);


-- ============================================================
-- 8. HABITACIONES
-- 5 hoteles x 4 tipos x 10 habitaciones = 200
-- ============================================================

INSERT INTO habitacion
(
    id_hotel,
    id_tipo_habitacion,
    numero_habitacion
)
SELECT
    h.id_hotel,
    th.id_tipo_habitacion,

    LPAD(
        (
            th.id_tipo_habitacion * 100
            + n
        )::TEXT,
        3,
        '0'
    )

FROM hotel h
CROSS JOIN tipo_habitacion th
CROSS JOIN generate_series(1, 10) AS n

ORDER BY
    h.id_hotel,
    th.id_tipo_habitacion,
    n;


-- ============================================================
-- 9. TARIFAS
--
-- El precio depende de:
-- - tipo de habitación
-- - temporada
-- - plan tarifario
-- - propiedad
--
-- Esto permite obtener diferencias reales en ADR y RevPAR.
-- ============================================================

INSERT INTO tarifa
(
    id_hotel,
    id_tipo_habitacion,
    id_temporada,
    id_plan_tarifa,
    precio_noche
)
SELECT
    h.id_hotel,

    th.id_tipo_habitacion,

    te.id_temporada,

    pt.id_plan_tarifa,

    ROUND(
        th.tarifa_base

        *
        CASE
            WHEN te.tipo = 'ALTA'
                THEN 1.25

            ELSE 0.90
        END

        *
        CASE
            WHEN pt.nombre = 'No reembolsable'
                THEN 0.90

            WHEN pt.nombre = 'Corporativa'
                THEN 0.95

            ELSE 1.00
        END

        *
        CASE h.id_hotel
            WHEN 1 THEN 1.00
            WHEN 2 THEN 0.95
            WHEN 3 THEN 1.20
            WHEN 4 THEN 1.10
            WHEN 5 THEN 1.25
        END,

        2
    )

FROM hotel h

CROSS JOIN tipo_habitacion th

CROSS JOIN temporada te

CROSS JOIN plan_tarifa pt;


-- ============================================================
-- 10. HUÉSPEDES
-- 2 000 huéspedes sintéticos
-- ============================================================

INSERT INTO huesped
(
    id_segmento,
    nombre,
    pais_origen,
    fecha_nacimiento,
    correo
)
SELECT
    ((g - 1) % 4) + 1,

    'Huésped ' || g,

    CASE (g % 8)
        WHEN 0 THEN 'Costa Rica'
        WHEN 1 THEN 'Estados Unidos'
        WHEN 2 THEN 'México'
        WHEN 3 THEN 'España'
        WHEN 4 THEN 'Canadá'
        WHEN 5 THEN 'Colombia'
        WHEN 6 THEN 'Alemania'
        ELSE 'Argentina'
    END,

    DATE '1960-01-01'
        + ((g * 37) % 16000),

    'huesped' || g || '@correo.test'

FROM generate_series(1, 2000) AS g;


-- ============================================================
-- 11. RESERVAS
--
-- Se generan 60 oportunidades de reserva por habitación.
--
-- 200 habitaciones x 60 = 12 000 reservas.
--
-- Las reservas de una misma habitación se separan 10 días
-- entre sí y duran entre 2 y 6 noches.
--
-- Por esta razón no se generan solapamientos de habitación.
-- ============================================================

WITH base AS (

    SELECT
        (
            (ha.id_habitacion - 1) * 60
            + gs.slot
            + 1
        )::BIGINT AS seq,

        ha.id_habitacion,

        ha.id_hotel,

        gs.slot,

        DATE '2025-01-05'
        +
        (
            gs.slot * 10
            +
            ((ha.id_habitacion - 1) % 5)
        )::INTEGER AS entrada,

        (
            2
            +
            (
                (
                    ha.id_habitacion
                    + gs.slot
                    + ha.id_hotel
                ) % 5
            )
        )::INTEGER AS noches,

        (
            1
            +
            (
                (
                    (ha.id_habitacion - 1) * 60
                    + gs.slot
                    + ha.id_hotel
                    + gs.slot
                    + 1
                ) % 5
            )
        )::BIGINT AS id_canal,

        (
            1
            +
            (
                (
                    (
                        (ha.id_habitacion - 1) * 60
                        + gs.slot
                        + 1
                    ) * 37
                    +
                    ha.id_habitacion * 11
                    +
                    gs.slot * 19
                ) % 2000
            )
        )::BIGINT AS id_huesped

    FROM habitacion ha

    CROSS JOIN generate_series(0, 59) AS gs(slot)
),

perfil AS (

    SELECT
        b.*,

        (
            ((b.id_huesped - 1) % 4) + 1
        )::BIGINT AS id_segmento,

        (
            1
            +
            (
                (
                    b.id_canal
                    + b.id_huesped
                    + b.id_hotel
                    + b.slot
                ) % 3
            )
        )::BIGINT AS id_plan_tarifa,

        CASE b.id_canal

            -- Sitio web
            WHEN 1 THEN
                5
                +
                (
                    (
                        b.seq * 13
                        + b.id_habitacion * 17
                        + b.slot * 7
                    ) % 90
                )

            -- Agencia
            WHEN 2 THEN
                10
                +
                (
                    (
                        b.seq * 13
                        + b.id_habitacion * 17
                        + b.slot * 7
                    ) % 100
                )

            -- OTA
            WHEN 3 THEN
                7
                +
                (
                    (
                        b.seq * 13
                        + b.id_habitacion * 17
                        + b.slot * 7
                    ) % 120
                )

            -- Teléfono
            WHEN 4 THEN
                2
                +
                (
                    (
                        b.seq * 13
                        + b.id_habitacion * 17
                        + b.slot * 7
                    ) % 45
                )

            -- Recepción
            ELSE
                (
                    (
                        b.seq * 13
                        + b.id_habitacion * 17
                        + b.slot * 7
                    ) % 4
                )

        END::INTEGER AS dias_anticipacion

    FROM base b
),

scoring AS (

    SELECT
        p.*,

        p.entrada
        - p.dias_anticipacion
        AS fecha_reserva,

        (
            (
                p.seq * 37
                + p.id_hotel * 17
                + p.id_canal * 11
                + p.id_plan_tarifa * 7
                + p.id_segmento * 13
                + p.slot * 5
            ) % 100
        )::INTEGER AS score,

        GREATEST(
            2,

            CASE p.id_canal
                WHEN 1 THEN 6
                WHEN 2 THEN 8
                WHEN 3 THEN 12
                WHEN 4 THEN 5
                ELSE 3
            END

            +

            CASE p.id_plan_tarifa
                WHEN 1 THEN 2
                WHEN 2 THEN -2
                ELSE -1
            END

            +

            CASE p.id_segmento
                WHEN 1 THEN 1
                WHEN 2 THEN 2
                WHEN 3 THEN 1
                ELSE -2
            END

            +

            CASE
                WHEN p.dias_anticipacion >= 75
                    THEN 4
                ELSE 0
            END

            +

            CASE p.id_hotel
                WHEN 1 THEN 0
                WHEN 2 THEN 2
                WHEN 3 THEN -1
                WHEN 4 THEN 1
                ELSE 0
            END

        )::INTEGER AS umbral_cancelacion,

        (
            CASE p.id_canal
                WHEN 1 THEN 3
                WHEN 2 THEN 4
                WHEN 3 THEN 5
                WHEN 4 THEN 6
                ELSE 2
            END

            +

            CASE
                WHEN p.dias_anticipacion <= 5
                    THEN 2
                ELSE 0
            END

        )::INTEGER AS umbral_no_show

    FROM perfil p
)

INSERT INTO reserva
(
    codigo_reserva,
    id_huesped,
    id_canal,
    fecha_reserva,
    fecha_entrada_prevista,
    fecha_salida_prevista,
    estado,
    fecha_cancelacion,
    motivo_cancelacion
)
SELECT
    'RES-' || LPAD(seq::TEXT, 6, '0'),

    id_huesped,

    id_canal,

    fecha_reserva,

    entrada,

    entrada + noches,

    CASE

        WHEN score < umbral_cancelacion
            THEN 'CANCELADA'

        WHEN score <
             (
                 umbral_cancelacion
                 + umbral_no_show
             )
            THEN 'NO_SHOW'

        ELSE 'COMPLETADA'

    END,

    CASE

        WHEN score < umbral_cancelacion
            THEN
                fecha_reserva
                +
                (dias_anticipacion / 2)

        ELSE NULL

    END,

    CASE

        WHEN score < umbral_cancelacion THEN

            CASE (
                (
                    seq
                    + id_canal
                    + id_segmento
                ) % 4
            )

                WHEN 0
                    THEN 'Cambio de planes'

                WHEN 1
                    THEN 'Motivos personales'

                WHEN 2
                    THEN 'Cambio de fecha del viaje'

                ELSE
                    'Cambio de alojamiento'

            END

        ELSE NULL

    END

FROM scoring

ORDER BY seq;


-- ============================================================
-- 12. DETALLE DE RESERVA
--
-- Cada reserva se vincula con la habitación utilizada,
-- temporada y plan tarifario correspondiente.
-- ============================================================

WITH mapa AS (

    SELECT
        (
            (ha.id_habitacion - 1) * 60
            + gs.slot
            + 1
        )::BIGINT AS seq,

        ha.id_habitacion,

        ha.id_hotel,

        ha.id_tipo_habitacion,

        gs.slot

    FROM habitacion ha

    CROSS JOIN generate_series(0, 59) AS gs(slot)
)

INSERT INTO detalle_reserva
(
    id_reserva,
    id_habitacion,
    id_tarifa,
    cantidad_noches,
    precio_noche
)
SELECT
    r.id_reserva,

    m.id_habitacion,

    t.id_tarifa,

    (
        r.fecha_salida_prevista
        - r.fecha_entrada_prevista
    ),

    t.precio_noche

FROM mapa m

JOIN reserva r
    ON r.codigo_reserva =
       'RES-' || LPAD(m.seq::TEXT, 6, '0')

JOIN temporada te
    ON r.fecha_entrada_prevista
       BETWEEN te.fecha_inicio
       AND te.fecha_fin

JOIN tarifa t
    ON t.id_hotel = m.id_hotel

    AND t.id_tipo_habitacion =
        m.id_tipo_habitacion

    AND t.id_temporada =
        te.id_temporada

    AND t.id_plan_tarifa =
        (
            1
            +
            (
                (
                    r.id_canal
                    + r.id_huesped
                    + m.id_hotel
                    + m.slot
                ) % 3
            )
        );


-- ============================================================
-- 13. ESTADÍAS
--
-- Únicamente las reservas completadas generan
-- ocupación real.
-- ============================================================

INSERT INTO estadia
(
    id_detalle_reserva,
    fecha_checkin,
    fecha_checkout
)
SELECT
    dr.id_detalle_reserva,

    r.fecha_entrada_prevista,

    r.fecha_salida_prevista

FROM detalle_reserva dr

JOIN reserva r
    ON r.id_reserva =
       dr.id_reserva

WHERE r.estado = 'COMPLETADA';


-- ============================================================
-- 14. CONSUMOS DE SERVICIOS
--
-- Los consumos varían según:
-- - huésped
-- - segmento
-- - hotel
-- - estadía
--
-- No todas las estadías generan consumos adicionales.
-- ============================================================

INSERT INTO consumo_servicio
(
    id_estadia,
    id_servicio,
    fecha_consumo,
    cantidad,
    precio_unitario
)
SELECT
    e.id_estadia,

    s.id_servicio,

    e.fecha_checkin
    +
    (
        (gs.n - 1)
        %
        (
            e.fecha_checkout
            - e.fecha_checkin
        )
    )::INTEGER,

    (
        1
        +
        (
            (
                e.id_estadia
                + gs.n
                + hu.id_segmento
            ) % 2
        )
    )::INTEGER,

    ROUND(
        s.precio_base

        *
        CASE ha.id_hotel
            WHEN 1 THEN 1.00
            WHEN 2 THEN 0.95
            WHEN 3 THEN 1.20
            WHEN 4 THEN 1.10
            WHEN 5 THEN 1.25
        END,

        2
    )

FROM estadia e

JOIN detalle_reserva dr
    ON dr.id_detalle_reserva =
       e.id_detalle_reserva

JOIN reserva r
    ON r.id_reserva =
       dr.id_reserva

JOIN huesped hu
    ON hu.id_huesped =
       r.id_huesped

JOIN habitacion ha
    ON ha.id_habitacion =
       dr.id_habitacion

JOIN LATERAL
    generate_series(
        1,

        CASE

            WHEN (
                (
                    e.id_estadia * 17
                    + hu.id_segmento * 13
                    + ha.id_hotel * 7
                ) % 100
            ) < 25

                THEN 0

            ELSE
                1
                +
                (
                    (
                        e.id_estadia
                        + hu.id_segmento
                        + ha.id_hotel
                    ) % 3
                )::INTEGER

        END

    ) AS gs(n)

    ON TRUE

JOIN servicio s
    ON s.id_servicio =
       (
           1
           +
           (
               (
                   e.id_estadia
                   + gs.n
                   + hu.id_segmento * 2
                   + ha.id_hotel
               ) % 8
           )
       );