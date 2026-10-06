# Proyecto 1 — Cadena Hotelera Grupo 3

## Solución analítica y Dashboard

### 1. Descripción

La solución analítica del proyecto fue desarrollada en **Microsoft Power BI**, utilizando el modelo dimensional de la cadena hotelera como fuente de información.

El dashboard permite analizar el comportamiento de las reservas, ocupación, ingresos, tarifas, cancelaciones, no-show y servicios complementarios de los cinco hoteles de la cadena.

Los hoteles analizados son:

* Hotel Central
* Hotel Montaña
* Hotel Pacífico
* Hotel Caribe
* Hotel Guanacaste

---

## 2. Herramienta utilizada

**Microsoft Power BI Desktop**

La solución utiliza un modelo dimensional compuesto por una tabla de hechos de reservas y dimensiones relacionadas con:

* Fechas
* Hoteles
* Habitaciones
* Clientes
* Canales
* Tarifas

La conexión con la base de datos se realizó mediante **PostgreSQL**.

---

## 3. Dashboard

El dashboard está organizado en cuatro páginas principales:

### 01 — Resumen ejecutivo

Presenta una visión general del desempeño de la cadena mediante indicadores y visualizaciones principales.

KPIs incluidos:

* Ocupación
* ADR
* RevPAR
* Ingreso total
* Noches vendidas

También permite comparar el desempeño de los hoteles.

Resultados generales observados:

* Ocupación general: **29.0 %**
* Noches vendidas: **aproximadamente 42 mil**
* ADR: **aproximadamente ₡117.96 mil**
* RevPAR: **aproximadamente ₡40 mil**
* Ingreso total: **aproximadamente ₡5.43 mil millones**

---

### 02 — Ocupación, ADR y RevPAR

Esta página permite analizar el desempeño comercial y de ocupación de los hoteles.

Incluye:

* Ocupación por mes
* Ingreso de alojamiento por mes
* Ocupación por hotel
* ADR por hotel
* RevPAR por hotel
* Noches vendidas por tipo de habitación y canal
* Ingreso de alojamiento por tipo de habitación y canal
* Ocupación por hotel y temporada

Los indicadores permiten identificar diferencias de desempeño entre hoteles, temporadas, tipos de habitación y canales de reserva.

---

### 03 — Cancelaciones y No-Show

Esta página analiza el comportamiento de las reservas que fueron canceladas o que terminaron en no-show.

Se realizan comparaciones según:

* Canal de reserva
* Segmento de cliente
* Plan tarifario

Los principales indicadores utilizados son:

* Tasa de cancelación
* Tasa de no-show

Esto permite identificar segmentos o canales que presentan un mayor nivel de pérdida de reservas y que podrían requerir estrategias comerciales específicas.

---

### 04 — Servicios y anticipación

Esta página analiza los ingresos generados por los servicios complementarios y el comportamiento de las reservas según su anticipación.

Servicios analizados:

* Desayuno
* Almuerzo
* Cena
* Spa
* Lavandería
* Tour
* Transporte
* Room Service

También se analiza la anticipación de las reservas mediante los siguientes rangos:

* 0–7 días
* 8–30 días
* 31–90 días
* Más de 90 días

Además, se relaciona la anticipación con las noches vendidas, los ingresos de alojamiento y la temporada.

---

## 4. KPIs implementados

Los principales indicadores implementados en Power BI son:

* **Reservas totales:** cantidad total de reservas registradas.
* **Estadías efectivas:** reservas que no fueron canceladas ni registradas como no-show.
* **Noches vendidas:** suma de noches correspondientes a estadías efectivas.
* **Ocupación:** relación entre las noches vendidas y las noches disponibles.
* **Ingreso de alojamiento:** ingresos provenientes de las estadías efectivas.
* **Ingreso de servicios:** ingresos provenientes de servicios complementarios.
* **Ingreso total:** suma del ingreso de alojamiento y servicios complementarios.
* **ADR:** ingreso promedio de alojamiento por noche vendida.
* **RevPAR:** ingreso de alojamiento por habitación disponible.
* **Tasa de cancelación:** proporción de reservas canceladas respecto al total.
* **Tasa de no-show:** proporción de reservas no presentadas respecto al total.
* **Duración promedio:** promedio de noches de las estadías efectivas.
* **Anticipación promedio:** promedio de días entre la reserva y el check-in.

---

## 5. Filtros interactivos

El dashboard incorpora filtros para facilitar el análisis de la información.

Entre los principales filtros se encuentran:

* Año
* Temporada
* Hotel

Estos filtros permiten analizar los indicadores y visualizaciones bajo diferentes contextos de negocio.

---

## 6. Principales resultados

El análisis realizado mediante Power BI permitió observar diferencias entre los hoteles de la cadena.

En términos de ocupación, **Hotel Pacífico presentó el valor más alto con 29.6 %**, seguido por Hotel Guanacaste con 29.0 %, Hotel Caribe y Hotel Central con 28.9 %, y Hotel Montaña con 28.5 %.

En cuanto al RevPAR, Hotel Pacífico presentó aproximadamente **₡39 mil**, seguido por Hotel Guanacaste con ₡38 mil, Hotel Caribe con ₡34 mil, Hotel Central con ₡31 mil y Hotel Montaña con ₡29 mil.

Para el ADR, Hotel Guanacaste y Hotel Pacífico presentaron los valores más altos, de aproximadamente **₡130 mil**, mientras que Hotel Montaña presentó el valor más bajo, cercano a ₡100 mil.

El dashboard también permite analizar el comportamiento de las cancelaciones, no-show, servicios complementarios y anticipación de las reservas para apoyar la toma de decisiones comerciales y operativas.

---

## 7. Archivos de esta sección

La carpeta `Dashboard/` contiene los archivos correspondientes a la solución analítica:

* Archivo de Power BI (`.pbix`)
* Documento final del proyecto

---

## 8. Consideraciones

Los datos utilizados en el proyecto son **datos sintéticos**, por lo que los resultados representan un escenario de análisis académico y no el comportamiento real de una cadena hotelera.

Además, las noches de las reservas se asignan a la fecha de check-in para efectos del análisis dimensional implementado.

Como posibles mejoras futuras se plantea incorporar datos reales, variables externas, costos operativos y técnicas de analítica predictiva que permitan complementar el análisis descriptivo realizado en Power BI.
