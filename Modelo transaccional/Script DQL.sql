-- ============================================================
-- PROYECTO 01 - INTELIGENCIA DE NEGOCIOS
-- GRUPO 3 - CADENA HOTELERA
-- SCRIPT DQL - VALIDACIONES Y CONSULTAS DE NEGOCIO
-- Elaborado por: Tamara Ortega, Daniela Sánchez, Rachel Rojas, Raúl Barrios y Melody Coto
-- ============================================================

SET search_path TO operacional, public;


-- ============================================================
-- 1. CONTEO DE REGISTROS
-- ============================================================

SELECT 'hotel' AS tabla, COUNT(*) AS cantidad
FROM hotel

UNION ALL

SELECT 'tipo_habitacion', COUNT(*)
FROM tipo_habitacion

UNION ALL

SELECT 'habitacion', COUNT(*)
FROM habitacion

UNION ALL

SELECT 'segmento_huesped', COUNT(*)
FROM segmento_huesped

UNION ALL

SELECT 'huesped', COUNT(*)
FROM huesped

UNION ALL

SELECT 'canal_reserva', COUNT(*)
FROM canal_reserva

UNION ALL

SELECT 'temporada', COUNT(*)
FROM temporada

UNION ALL

SELECT 'plan_tarifa', COUNT(*)
FROM plan_tarifa

UNION ALL

SELECT 'tarifa', COUNT(*)
FROM tarifa

UNION ALL

SELECT 'reserva', COUNT(*)
FROM reserva

UNION ALL

SELECT 'detalle_reserva', COUNT(*)
FROM detalle_reserva

UNION ALL

SELECT 'estadia', COUNT(*)
FROM estadia

UNION ALL

SELECT 'servicio', COUNT(*)
FROM servicio

UNION ALL

SELECT 'consumo_servicio', COUNT(*)
FROM consumo_servicio

ORDER BY tabla;


-- ============================================================
-- 2. VALIDACIÓN DE SOLAPAMIENTO DE HABITACIONES
--
-- Debe devolver 0.
-- Una habitación no debe tener dos estadías al mismo tiempo.
-- ============================================================

SELECT
    COUNT(*) AS solapamientos_encontrados

FROM estadia e1

JOIN detalle_reserva dr1
    ON dr1.id_detalle_reserva =
       e1.id_detalle_reserva

JOIN estadia e2
    ON e1.id_estadia <
       e2.id_estadia

JOIN detalle_reserva dr2
    ON dr2.id_detalle_reserva =
       e2.id_detalle_reserva

WHERE
    dr1.id_habitacion =
    dr2.id_habitacion

    AND e1.fecha_checkin <
        e2.fecha_checkout

    AND e2.fecha_checkin <
        e1.fecha_checkout;


-- ============================================================
-- 3. DISTRIBUCIÓN DE ESTADOS DE RESERVA
-- ============================================================

SELECT
    estado,

    COUNT(*) AS cantidad,

    ROUND(
        COUNT(*) * 100.0
        /
        SUM(COUNT(*)) OVER (),
        2
    ) AS porcentaje

FROM reserva

GROUP BY estado

ORDER BY estado;


-- ============================================================
-- 4. KPIs GENERALES
--
-- Permite validar:
-- - porcentaje de ocupación
-- - noches vendidas
-- - ingresos alojamiento
-- - ingreso total
-- - ADR
-- - RevPAR
-- - cancelación
-- - no-show
-- - servicios complementarios
-- - ingreso promedio por estadía
-- - duración promedio
-- - anticipación promedio
-- - ingreso promedio por consumo
-- ============================================================

WITH periodo AS (

    SELECT
        MIN(fecha_checkin) AS inicio,
        MAX(fecha_checkout) AS fin

    FROM estadia
),

disponibilidad AS (

    SELECT
        COUNT(*)::NUMERIC
        AS habitaciones_noches_disponibles

    FROM habitacion ha

    CROSS JOIN periodo p

    CROSS JOIN LATERAL
        generate_series(
            p.inicio,
            p.fin - 1,
            INTERVAL '1 day'
        ) AS d(fecha)

    WHERE ha.estado = 'ACTIVA'
),

alojamiento AS (

    SELECT
        COUNT(*)::NUMERIC
            AS cantidad_estadias,

        SUM(dr.cantidad_noches)::NUMERIC
            AS noches_vendidas,

        SUM(dr.subtotal_alojamiento)::NUMERIC
            AS ingreso_alojamiento

    FROM estadia e

    JOIN detalle_reserva dr
        ON dr.id_detalle_reserva =
           e.id_detalle_reserva
),

servicios AS (

    SELECT
        COALESCE(
            SUM(total),
            0
        )::NUMERIC
            AS ingreso_servicios,

        COUNT(*)::NUMERIC
            AS cantidad_consumos

    FROM consumo_servicio
),

reservas_kpi AS (

    SELECT
        COUNT(*)::NUMERIC AS reservas_totales,

        COUNT(*) FILTER (
            WHERE estado = 'CANCELADA'
        )::NUMERIC
            AS reservas_canceladas,

        COUNT(*) FILTER (
            WHERE estado = 'NO_SHOW'
        )::NUMERIC
            AS reservas_no_show,

        AVG(
            fecha_entrada_prevista
            - fecha_reserva
        )::NUMERIC
            AS anticipacion_promedio

    FROM reserva
)

SELECT
    ROUND(
        a.noches_vendidas * 100
        /
        NULLIF(
            d.habitaciones_noches_disponibles,
            0
        ),
        2
    ) AS porcentaje_ocupacion,

    a.noches_vendidas,

    ROUND(
        a.ingreso_alojamiento,
        2
    ) AS ingreso_alojamiento,

    ROUND(
        s.ingreso_servicios,
        2
    ) AS ingreso_servicios_complementarios,

    ROUND(
        a.ingreso_alojamiento
        + s.ingreso_servicios,
        2
    ) AS ingreso_total,

    ROUND(
        a.ingreso_alojamiento
        /
        NULLIF(
            a.noches_vendidas,
            0
        ),
        2
    ) AS adr,

    ROUND(
        a.ingreso_alojamiento
        /
        NULLIF(
            d.habitaciones_noches_disponibles,
            0
        ),
        2
    ) AS revpar,

    ROUND(
        r.reservas_canceladas * 100
        /
        NULLIF(
            r.reservas_totales,
            0
        ),
        2
    ) AS tasa_cancelacion,

    ROUND(
        r.reservas_no_show * 100
        /
        NULLIF(
            r.reservas_totales,
            0
        ),
        2
    ) AS tasa_no_show,

    ROUND(
        (
            a.ingreso_alojamiento
            + s.ingreso_servicios
        )
        /
        NULLIF(
            a.cantidad_estadias,
            0
        ),
        2
    ) AS ingreso_promedio_estadia,

    ROUND(
        a.noches_vendidas
        /
        NULLIF(
            a.cantidad_estadias,
            0
        ),
        2
    ) AS duracion_promedio_estadia,

    ROUND(
        r.anticipacion_promedio,
        2
    ) AS anticipacion_promedio_reserva,

    ROUND(
        s.ingreso_servicios
        /
        NULLIF(
            s.cantidad_consumos,
            0
        ),
        2
    ) AS ingreso_promedio_servicio

FROM alojamiento a

CROSS JOIN disponibilidad d

CROSS JOIN servicios s

CROSS JOIN reservas_kpi r;


-- ============================================================
-- 5. PREGUNTA DE NEGOCIO 1
--
-- Ocupación, noches vendidas e ingresos
-- según hotel, tipo de habitación,
-- temporada y canal de reserva.
-- ============================================================

WITH noches_ocupadas AS (

    SELECT
        h.id_hotel,

        h.nombre AS hotel,

        th.id_tipo_habitacion,

        th.nombre AS tipo_habitacion,

        te.id_temporada,

        te.nombre AS temporada,

        c.id_canal,

        c.nombre AS canal,

        fecha_noche::DATE AS fecha,

        dr.precio_noche

    FROM estadia e

    JOIN detalle_reserva dr
        ON dr.id_detalle_reserva =
           e.id_detalle_reserva

    JOIN reserva r
        ON r.id_reserva =
           dr.id_reserva

    JOIN canal_reserva c
        ON c.id_canal =
           r.id_canal

    JOIN habitacion ha
        ON ha.id_habitacion =
           dr.id_habitacion

    JOIN hotel h
        ON h.id_hotel =
           ha.id_hotel

    JOIN tipo_habitacion th
        ON th.id_tipo_habitacion =
           ha.id_tipo_habitacion

    CROSS JOIN LATERAL
        generate_series(
            e.fecha_checkin,
            e.fecha_checkout - 1,
            INTERVAL '1 day'
        ) AS gs(fecha_noche)

    JOIN temporada te
        ON fecha_noche::DATE
           BETWEEN te.fecha_inicio
           AND te.fecha_fin
),

disponibilidad AS (

    SELECT
        h.id_hotel,

        th.id_tipo_habitacion,

        te.id_temporada,

        COUNT(*)::NUMERIC
            AS habitaciones_noches_disponibles

    FROM hotel h

    JOIN habitacion ha
        ON ha.id_hotel =
           h.id_hotel

    JOIN tipo_habitacion th
        ON th.id_tipo_habitacion =
           ha.id_tipo_habitacion

    CROSS JOIN temporada te

    CROSS JOIN LATERAL
        generate_series(
            te.fecha_inicio,
            te.fecha_fin,
            INTERVAL '1 day'
        ) AS gs(fecha)

    WHERE ha.estado = 'ACTIVA'

    GROUP BY
        h.id_hotel,
        th.id_tipo_habitacion,
        te.id_temporada
)

SELECT
    n.hotel,

    n.tipo_habitacion,

    n.temporada,

    n.canal,

    COUNT(*) AS noches_vendidas,

    ROUND(
        SUM(n.precio_noche),
        2
    ) AS ingreso_alojamiento,

    ROUND(
        COUNT(*) * 100.0
        /
        NULLIF(
            d.habitaciones_noches_disponibles,
            0
        ),
        2
    ) AS porcentaje_ocupacion

FROM noches_ocupadas n

JOIN disponibilidad d
    ON d.id_hotel =
       n.id_hotel

    AND d.id_tipo_habitacion =
        n.id_tipo_habitacion

    AND d.id_temporada =
        n.id_temporada

GROUP BY
    n.hotel,
    n.tipo_habitacion,
    n.temporada,
    n.canal,
    d.habitaciones_noches_disponibles

ORDER BY
    n.hotel,
    n.temporada,
    n.tipo_habitacion,
    n.canal;


-- ============================================================
-- 6. PREGUNTA DE NEGOCIO 2
--
-- ADR y RevPAR por propiedad y periodo mensual.
-- ============================================================

WITH limites AS (

    SELECT
        MIN(fecha_checkin) AS inicio,

        MAX(fecha_checkout) - 1
            AS fin

    FROM estadia
),

calendario AS (

    SELECT
        fecha::DATE AS fecha

    FROM limites

    CROSS JOIN LATERAL
        generate_series(
            inicio,
            fin,
            INTERVAL '1 day'
        ) AS gs(fecha)
),

disponibilidad AS (

    SELECT
        h.id_hotel,

        h.nombre AS hotel,

        DATE_TRUNC(
            'month',
            c.fecha
        )::DATE AS periodo,

        COUNT(*)::NUMERIC
            AS habitaciones_noches_disponibles

    FROM hotel h

    JOIN habitacion ha
        ON ha.id_hotel =
           h.id_hotel

    CROSS JOIN calendario c

    WHERE ha.estado = 'ACTIVA'

    GROUP BY
        h.id_hotel,
        h.nombre,
        DATE_TRUNC(
            'month',
            c.fecha
        )::DATE
),

ventas AS (

    SELECT
        h.id_hotel,

        DATE_TRUNC(
            'month',
            fecha_noche
        )::DATE AS periodo,

        COUNT(*)::NUMERIC
            AS noches_vendidas,

        SUM(
            dr.precio_noche
        )::NUMERIC
            AS ingreso_alojamiento

    FROM estadia e

    JOIN detalle_reserva dr
        ON dr.id_detalle_reserva =
           e.id_detalle_reserva

    JOIN habitacion ha
        ON ha.id_habitacion =
           dr.id_habitacion

    JOIN hotel h
        ON h.id_hotel =
           ha.id_hotel

    CROSS JOIN LATERAL
        generate_series(
            e.fecha_checkin,
            e.fecha_checkout - 1,
            INTERVAL '1 day'
        ) AS gs(fecha_noche)

    GROUP BY
        h.id_hotel,

        DATE_TRUNC(
            'month',
            fecha_noche
        )::DATE
)

SELECT
    d.hotel,

    TO_CHAR(
        d.periodo,
        'YYYY-MM'
    ) AS periodo,

    COALESCE(
        v.noches_vendidas,
        0
    ) AS noches_vendidas,

    d.habitaciones_noches_disponibles,

    ROUND(
        COALESCE(
            v.noches_vendidas,
            0
        ) * 100
        /
        NULLIF(
            d.habitaciones_noches_disponibles,
            0
        ),
        2
    ) AS porcentaje_ocupacion,

    ROUND(
        COALESCE(
            v.ingreso_alojamiento,
            0
        )
        /
        NULLIF(
            v.noches_vendidas,
            0
        ),
        2
    ) AS adr,

    ROUND(
        COALESCE(
            v.ingreso_alojamiento,
            0
        )
        /
        NULLIF(
            d.habitaciones_noches_disponibles,
            0
        ),
        2
    ) AS revpar

FROM disponibilidad d

LEFT JOIN ventas v
    ON v.id_hotel =
       d.id_hotel

    AND v.periodo =
        d.periodo

ORDER BY
    d.periodo,
    d.hotel;


-- ============================================================
-- 7. PREGUNTA DE NEGOCIO 3
--
-- Tasas de cancelación y no-show
-- según canal, tarifa y segmento.
-- ============================================================

SELECT
    c.nombre AS canal,

    pt.nombre AS plan_tarifario,

    sh.nombre AS segmento,

    COUNT(
        DISTINCT r.id_reserva
    ) AS reservas_totales,

    COUNT(
        DISTINCT r.id_reserva
    ) FILTER (
        WHERE r.estado = 'CANCELADA'
    ) AS reservas_canceladas,

    COUNT(
        DISTINCT r.id_reserva
    ) FILTER (
        WHERE r.estado = 'NO_SHOW'
    ) AS reservas_no_show,

    ROUND(
        COUNT(
            DISTINCT r.id_reserva
        ) FILTER (
            WHERE r.estado = 'CANCELADA'
        ) * 100.0
        /
        NULLIF(
            COUNT(
                DISTINCT r.id_reserva
            ),
            0
        ),
        2
    ) AS tasa_cancelacion,

    ROUND(
        COUNT(
            DISTINCT r.id_reserva
        ) FILTER (
            WHERE r.estado = 'NO_SHOW'
        ) * 100.0
        /
        NULLIF(
            COUNT(
                DISTINCT r.id_reserva
            ),
            0
        ),
        2
    ) AS tasa_no_show

FROM reserva r

JOIN canal_reserva c
    ON c.id_canal =
       r.id_canal

JOIN huesped hu
    ON hu.id_huesped =
       r.id_huesped

JOIN segmento_huesped sh
    ON sh.id_segmento =
       hu.id_segmento

JOIN detalle_reserva dr
    ON dr.id_reserva =
       r.id_reserva

JOIN tarifa t
    ON t.id_tarifa =
       dr.id_tarifa

JOIN plan_tarifa pt
    ON pt.id_plan_tarifa =
       t.id_plan_tarifa

GROUP BY
    c.nombre,
    pt.nombre,
    sh.nombre

ORDER BY
    tasa_cancelacion DESC,
    tasa_no_show DESC;


-- ============================================================
-- 8. PREGUNTA DE NEGOCIO 4
--
-- Servicios complementarios según:
-- - propiedad
-- - perfil del huésped
-- - duración de la estadía
-- ============================================================

SELECT
    h.nombre AS hotel,

    sh.nombre AS segmento_huesped,

    hu.pais_origen,

    CASE

        WHEN (
            e.fecha_checkout
            - e.fecha_checkin
        ) <= 2

            THEN '1-2 noches'

        WHEN (
            e.fecha_checkout
            - e.fecha_checkin
        ) <= 4

            THEN '3-4 noches'

        ELSE '5 o más noches'

    END AS duracion_estadia,

    s.nombre AS servicio,

    COUNT(
        cs.id_consumo
    ) AS cantidad_consumos,

    SUM(
        cs.cantidad
    ) AS unidades_consumidas,

    ROUND(
        SUM(
            cs.total
        ),
        2
    ) AS ingreso_servicio

FROM consumo_servicio cs

JOIN servicio s
    ON s.id_servicio =
       cs.id_servicio

JOIN estadia e
    ON e.id_estadia =
       cs.id_estadia

JOIN detalle_reserva dr
    ON dr.id_detalle_reserva =
       e.id_detalle_reserva

JOIN reserva r
    ON r.id_reserva =
       dr.id_reserva

JOIN huesped hu
    ON hu.id_huesped =
       r.id_huesped

JOIN segmento_huesped sh
    ON sh.id_segmento =
       hu.id_segmento

JOIN habitacion ha
    ON ha.id_habitacion =
       dr.id_habitacion

JOIN hotel h
    ON h.id_hotel =
       ha.id_hotel

GROUP BY
    h.nombre,
    sh.nombre,
    hu.pais_origen,

    CASE

        WHEN (
            e.fecha_checkout
            - e.fecha_checkin
        ) <= 2
            THEN '1-2 noches'

        WHEN (
            e.fecha_checkout
            - e.fecha_checkin
        ) <= 4
            THEN '3-4 noches'

        ELSE '5 o más noches'

    END,

    s.nombre

ORDER BY
    ingreso_servicio DESC;


-- ============================================================
-- 9. PREGUNTA DE NEGOCIO ADICIONAL
--
-- Anticipación de reserva y relación con:
-- - cancelación
-- - ocupación
-- - ingresos
--
-- Según:
-- - temporada
-- - canal
-- - propiedad
-- ============================================================

WITH reservas_base AS (

    SELECT
        r.id_reserva,

        h.id_hotel,

        h.nombre AS hotel,

        te.id_temporada,

        te.nombre AS temporada,

        c.nombre AS canal,

        (
            r.fecha_entrada_prevista
            - r.fecha_reserva
        ) AS dias_anticipacion,

        CASE

            WHEN (
                r.fecha_entrada_prevista
                - r.fecha_reserva
            ) <= 3
                THEN '0-3 días'

            WHEN (
                r.fecha_entrada_prevista
                - r.fecha_reserva
            ) <= 14
                THEN '4-14 días'

            WHEN (
                r.fecha_entrada_prevista
                - r.fecha_reserva
            ) <= 30
                THEN '15-30 días'

            WHEN (
                r.fecha_entrada_prevista
                - r.fecha_reserva
            ) <= 60
                THEN '31-60 días'

            WHEN (
                r.fecha_entrada_prevista
                - r.fecha_reserva
            ) <= 90
                THEN '61-90 días'

            ELSE 'Más de 90 días'

        END AS rango_anticipacion,

        r.estado,

        dr.cantidad_noches,

        dr.subtotal_alojamiento

    FROM reserva r

    JOIN canal_reserva c
        ON c.id_canal =
           r.id_canal

    JOIN detalle_reserva dr
        ON dr.id_reserva =
           r.id_reserva

    JOIN habitacion ha
        ON ha.id_habitacion =
           dr.id_habitacion

    JOIN hotel h
        ON h.id_hotel =
           ha.id_hotel

    JOIN temporada te
        ON r.fecha_entrada_prevista
           BETWEEN te.fecha_inicio
           AND te.fecha_fin
),

disponibilidad AS (

    SELECT
        h.id_hotel,

        te.id_temporada,

        COUNT(*)::NUMERIC
            AS habitaciones_noches_disponibles

    FROM hotel h

    JOIN habitacion ha
        ON ha.id_hotel =
           h.id_hotel

    CROSS JOIN temporada te

    CROSS JOIN LATERAL
        generate_series(
            te.fecha_inicio,
            te.fecha_fin,
            INTERVAL '1 day'
        ) AS gs(fecha)

    WHERE ha.estado = 'ACTIVA'

    GROUP BY
        h.id_hotel,
        te.id_temporada
)

SELECT
    rb.hotel,

    rb.temporada,

    rb.canal,

    rb.rango_anticipacion,

    COUNT(*) AS total_reservas,

    ROUND(
        AVG(
            rb.dias_anticipacion
        ),
        2
    ) AS anticipacion_promedio_dias,

    ROUND(
        COUNT(*) FILTER (
            WHERE rb.estado = 'CANCELADA'
        ) * 100.0
        /
        NULLIF(
            COUNT(*),
            0
        ),
        2
    ) AS tasa_cancelacion,

    SUM(
        CASE

            WHEN rb.estado = 'COMPLETADA'
                THEN rb.cantidad_noches

            ELSE 0

        END
    ) AS noches_vendidas,

    ROUND(
        SUM(
            CASE

                WHEN rb.estado = 'COMPLETADA'
                    THEN rb.cantidad_noches

                ELSE 0

            END
        ) * 100.0
        /
        NULLIF(
            d.habitaciones_noches_disponibles,
            0
        ),
        2
    ) AS porcentaje_ocupacion,

    ROUND(
        SUM(
            CASE

                WHEN rb.estado = 'COMPLETADA'
                    THEN rb.subtotal_alojamiento

                ELSE 0

            END
        ),
        2
    ) AS ingreso_alojamiento

FROM reservas_base rb

JOIN disponibilidad d
    ON d.id_hotel =
       rb.id_hotel

    AND d.id_temporada =
        rb.id_temporada

GROUP BY
    rb.hotel,
    rb.temporada,
    rb.canal,
    rb.rango_anticipacion,
    d.habitaciones_noches_disponibles

ORDER BY
    rb.hotel,
    rb.temporada,
    rb.canal,
    rb.rango_anticipacion;