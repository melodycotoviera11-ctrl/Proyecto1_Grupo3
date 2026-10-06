# Proyecto 01 - Solución de Inteligencia de Negocios para una Cadena Hotelera

## TI-6900 Inteligencia de Negocios

**Instituto Tecnológico de Costa Rica**  
**Escuela de Administración de Tecnología de Información**  
**II Semestre 2026**

### Integrantes

| Integrante | Carné |
|---|---|
| Tamara Ortega Villalobos | 2023105927 |
| Daniela Sánchez Acuña | 2022438562 |
| Edgar Raúl Barrios Vega | 2024156520 |
| Rachel Fernanda Rojas Gómez | 2020302748 |
| Melody Onid Coto Viera | 2024224269 |

---

## Descripción del proyecto

Este proyecto desarrolla una solución integral de Inteligencia de Negocios para una cadena hotelera ficticia.

La organización administra distintas propiedades de alojamiento y genera información relacionada con reservas, estadías, habitaciones, huéspedes, tarifas, canales de reserva, cancelaciones, no-show y servicios complementarios.

La solución integra esta información desde una fuente operacional, la transforma mediante un proceso ETL y la organiza en un modelo dimensional para facilitar posteriormente su análisis mediante Power BI.

El objetivo es convertir los datos operativos de la cadena hotelera en información estructurada que apoye la toma de decisiones comerciales y operativas.

---

## Problema de negocio

La cadena hotelera no dispone inicialmente de una plataforma centralizada que permita analizar de forma integrada sus reservas, estadías, ocupación e ingresos.

La información se encuentra distribuida entre distintos procesos, lo cual dificulta:

- comparar el desempeño entre propiedades;
- analizar temporadas de alta y baja demanda;
- evaluar canales de reserva;
- identificar segmentos con mayores tasas de cancelación o no-show;
- analizar el rendimiento de las tarifas;
- determinar cuáles servicios complementarios generan mayores ingresos;
- analizar indicadores como ADR y RevPAR;
- estudiar la anticipación con la que los huéspedes realizan sus reservas.

La solución de BI busca centralizar esta información y proporcionar una estructura adecuada para realizar estos análisis.

---

## Objetivo general

Implementar una solución de Inteligencia de Negocios que centralice y transforme los datos de la cadena hotelera en información para la toma de decisiones, permitiendo analizar el desempeño comercial y operativo de sus propiedades.

---

## Preguntas de negocio

La solución fue diseñada para responder las siguientes preguntas:

1. ¿Cómo se comportan la ocupación, las noches vendidas y los ingresos según hotel, tipo de habitación, temporada y canal de reserva?

2. ¿Qué diferencias presentan indicadores como ADR e ingreso por habitación disponible (RevPAR) entre propiedades y periodos?

3. ¿Qué canales, tarifas y segmentos de cliente registran mayores tasas de cancelación y no-show?

4. ¿Qué servicios complementarios generan mayores ingresos según el perfil del huésped, la duración de la estadía y la propiedad?

Como pregunta adicional se analiza:

5. ¿Con cuánta anticipación se realizan las reservas y cómo influye dicha anticipación en la tasa de cancelación, el nivel de ocupación y el ingreso obtenido según temporada, canal y propiedad?

---

# Arquitectura de la solución

La solución está organizada en cuatro capas principales:

```text
┌──────────────────────────────────┐
│     Fuente operacional           │
│         PostgreSQL               │
│      esquema: operacional        │
└────────────────┬─────────────────┘
                 │
                 ▼
┌──────────────────────────────────┐
│          Proceso ETL             │
│          Apache Hop              │
│     Pipelines + Workflow         │
└────────────────┬─────────────────┘
                 │
                 ▼
┌──────────────────────────────────┐
│      Modelo dimensional          │
│          PostgreSQL              │
│      esquema: dimensional        │
└────────────────┬─────────────────┘
                 │
                 ▼
┌──────────────────────────────────┐
│       Solución analítica         │
│            Power BI              │
│ Dashboard, KPIs, filtros y       │
│ visualizaciones                  │
└──────────────────────────────────┘
```

La fuente operacional y el modelo dimensional se almacenan dentro de la misma base de datos:

```text
cadena_hotelera_g3
```

utilizando dos esquemas diferentes:

```text
operacional
dimensional
```

---

# Herramientas utilizadas

| Herramienta | Uso |
|---|---|
| PostgreSQL 18 | Implementación de la fuente operacional y del modelo dimensional |
| pgAdmin 4 | Administración, ejecución de scripts SQL y validación de la base de datos |
| Apache Hop 2.19.0 | Diseño y ejecución del proceso ETL |
| Java 21 | Requisito de ejecución de Apache Hop |
| Power BI | Construcción de dashboards, KPIs y visualizaciones |
| SQL | DDL, DML, consultas, transformaciones y validaciones |
| Git | Control de versiones |
| GitHub | Repositorio colaborativo y trazabilidad del proyecto |

---

# Estructura del repositorio

```text
Proyecto1_Grupo3/
│
├── README.md
│
├── Modelo transaccional/
│   ├── Script DDL.sql
│   ├── Script DML.sql
│   ├── Script DQL.sql
│   ├── Diagrama ERD.png
│   └── README.md
│
├── Modelo dimensional/
│   ├── 03_modelo_dimensional_DDL.sql
│   ├── 02_DQL_validaciones_dimensional.sql
│   └── Modelo Dimensional - Grupo 3.png
│
├── etl/
│   ├── README.md
│   ├── project-config.json
│   │
│   ├── pipelines/
│   │   ├── 01_dim_hotel.hpl
│   │   ├── 02_dim_habitacion.hpl
│   │   ├── 03_dim_canal.hpl
│   │   ├── 04_dim_cliente.hpl
│   │   ├── 05_dim_tarifa.hpl
│   │   ├── 06_dim_fecha.hpl
│   │   └── 07_fact_reservas.hpl
│   │
│   └── workflows/
│       └── wf_carga_completa.hwf
│
├── Dashboard/
│   └── Archivo Power BI (.pbix)
│
├── Documentacion/
│   └── Informe del proyecto - Grupo 3.pdf
│
└── Presentacion/
    └── Presentación.pdf
```

# Modelo transaccional

La fuente operacional se encuentra en el esquema:

```text
operacional
```

de la base de datos:

```text
cadena_hotelera_g3
```

El modelo contiene 14 tablas:

| Tabla | Descripción |
|---|---|
| `hotel` | Propiedades de la cadena hotelera |
| `tipo_habitacion` | Tipos de habitación disponibles |
| `habitacion` | Habitaciones de cada propiedad |
| `segmento_huesped` | Clasificación de los huéspedes |
| `huesped` | Información de los huéspedes |
| `canal_reserva` | Canales utilizados para realizar reservas |
| `temporada` | Periodos de temporada |
| `plan_tarifa` | Planes tarifarios |
| `tarifa` | Tarifas aplicables |
| `reserva` | Reservas realizadas |
| `detalle_reserva` | Detalle de las reservas |
| `estadia` | Estadías efectivamente realizadas |
| `servicio` | Catálogo de servicios complementarios |
| `consumo_servicio` | Servicios consumidos durante una estadía |

La separación entre `reserva` y `estadia` permite conservar cancelaciones y no-show sin contabilizarlos como ocupación efectiva.

---

# Datos utilizados

Los datos de la fuente operacional son completamente sintéticos.

Se generaron mediante scripts SQL utilizando funciones como:

```sql
generate_series()
```

además de reglas de asignación y restricciones de integridad referencial.

Los datos incluyen:

- 5 hoteles;
- 200 habitaciones;
- 2000 huéspedes;
- 12000 reservas;
- tarifas;
- temporadas;
- estadías;
- cancelaciones;
- no-show;
- consumos de servicios complementarios.

Los datos fueron creados exclusivamente para fines académicos y no representan el comportamiento real de una empresa hotelera.

---

# Modelo dimensional

El modelo dimensional sigue un esquema en estrella.

Su granularidad es:

> Una fila por cada reserva realizada.

El modelo está compuesto por una tabla de hechos:

```text
fact_reservas
```

y seis dimensiones:

```text
dim_hotel
dim_habitacion
dim_canal
dim_cliente
dim_tarifa
dim_fecha
```

La dimensión `dim_fecha` funciona como una **Role-Playing Dimension**, ya que se utiliza tanto para representar la fecha de reserva como la fecha de check-in.

---

## Tabla de hechos

`fact_reservas` contiene información relacionada con:

- hotel;
- habitación;
- canal;
- cliente;
- tarifa;
- fecha de reserva;
- fecha de check-in;
- duración de la estadía;
- ingresos por alojamiento;
- ingresos por servicios complementarios;
- cancelaciones;
- no-show.

Los ingresos por servicios complementarios se encuentran separados en las siguientes medidas:

```text
ingreso_desayuno
ingreso_almuerzo
ingreso_cena
ingreso_spa
ingreso_lavanderia
ingreso_tour
ingreso_transporte
ingreso_room_service
```

También se incluye:

```text
ingreso_servicios_complementarios
```

como suma total de los servicios adicionales asociados a la reserva.

---

# Proceso ETL

El proceso ETL fue implementado utilizando Apache Hop.

Su función es trasladar y transformar los datos desde:

```text
cadena_hotelera_g3.operacional
```

hacia:

```text
cadena_hotelera_g3.dimensional
```

El proceso está dividido en siete pipelines:

| Pipeline | Destino |
|---|---|
| `01_dim_hotel.hpl` | `dimensional.dim_hotel` |
| `02_dim_habitacion.hpl` | `dimensional.dim_habitacion` |
| `03_dim_canal.hpl` | `dimensional.dim_canal` |
| `04_dim_cliente.hpl` | `dimensional.dim_cliente` |
| `05_dim_tarifa.hpl` | `dimensional.dim_tarifa` |
| `06_dim_fecha.hpl` | `dimensional.dim_fecha` |
| `07_fact_reservas.hpl` | `dimensional.fact_reservas` |

Los pipelines son coordinados por el workflow maestro:

```text
etl/workflows/wf_carga_completa.hwf
```

El orden de ejecución es:

```text
Inicio
  ↓
01_dim_hotel
  ↓
02_dim_habitacion
  ↓
03_dim_canal
  ↓
04_dim_cliente
  ↓
05_dim_tarifa
  ↓
06_dim_fecha
  ↓
07_fact_reservas
```

Las dimensiones se cargan primero debido a que la tabla de hechos depende de sus llaves.

---

# Principales transformaciones ETL

Durante el proceso ETL se realizan operaciones de:

- selección de campos;
- renombramiento;
- combinación de tablas mediante `JOIN`;
- homologación de categorías;
- derivación de atributos;
- tratamiento de valores nulos;
- agregación de consumos;
- generación de la dimensión de tiempo;
- carga de dimensiones;
- carga de la tabla de hechos.

## Homologación de canales

| Canal original | Tipo de canal |
|---|---|
| Sitio web | Directo digital |
| Teléfono | Directo tradicional |
| Recepción | Directo tradicional |
| Agencia | Intermediado |
| OTA | Intermediado |
| Otro | Otro |

## Perfil de huésped

| Segmento | Perfil derivado |
|---|---|
| Individual | Viajero individual |
| Pareja | Turismo en pareja |
| Familia | Turismo familiar |
| Corporativo | Viajero de negocios |
| Otro | Sin clasificar |

Los valores nulos relacionados con ingresos por servicios complementarios son reemplazados por `0` utilizando `COALESCE`.

Los consumos son agrupados por reserva mediante operaciones `SUM` y `GROUP BY` para conservar la granularidad de una fila por reserva.

---

# Solución analítica

La solución analítica se desarrolla en Power BI a partir del modelo dimensional.

La capa analítica permite construir:

- tarjetas de indicadores;
- gráficos;
- tablas;
- filtros;
- segmentadores;
- comparaciones temporales;
- análisis por hotel, canal, tarifa y perfil de huésped.

Entre los principales indicadores considerados se encuentran:

- porcentaje de ocupación;
- noches vendidas;
- ingresos por alojamiento;
- ingreso total;
- ADR;
- RevPAR;
- tasa de cancelación;
- tasa de no-show;
- ingresos por servicios complementarios;
- ingreso promedio por estadía;
- duración promedio de la estadía;
- anticipación promedio de la reserva.

---

# Requisitos previos

Para reproducir la solución se requiere:

| Requisito | Configuración |
|---|---|
| PostgreSQL | Versión 18 o compatible |
| pgAdmin | pgAdmin 4 |
| Java | Java 21 |
| Apache Hop | 2.19.0 |
| Power BI | Power BI Desktop |
| Base de datos | `cadena_hotelera_g3` |
| Puerto PostgreSQL | `5432` |

---

# Instrucciones de ejecución

## 1. Clonar el repositorio

```bash
git clone https://github.com/melodycotoviera11-ctrl/Proyecto1_Grupo3.git
```

Ingresar a la carpeta:

```bash
cd Proyecto1_Grupo3
```

---

## 2. Crear la base de datos

Desde PostgreSQL o pgAdmin crear:

```text
cadena_hotelera_g3
```

Ejemplo:

```sql
CREATE DATABASE cadena_hotelera_g3;
```

---

## 3. Crear y cargar el modelo operacional

Conectarse a:

```text
cadena_hotelera_g3
```

y ejecutar los scripts ubicados en:

```text
Modelo transaccional/
```

en el siguiente orden:

```text
1. Script DDL.sql
2. Script DML.sql
3. Script DQL.sql
```

### Script DDL

Crea el esquema:

```text
operacional
```

y todas las tablas, relaciones y restricciones correspondientes.

### Script DML

Genera y carga los datos sintéticos utilizados por el proyecto.

### Script DQL

Ejecuta consultas de validación sobre los datos cargados.

---

## 4. Crear el modelo dimensional

Ejecutar:

```text
Modelo dimensional/03_modelo_dimensional_DDL.sql
```

Este script crea:

```text
dimensional.dim_hotel
dimensional.dim_habitacion
dimensional.dim_canal
dimensional.dim_cliente
dimensional.dim_tarifa
dimensional.dim_fecha
dimensional.fact_reservas
```

No debe cargarse información manualmente en estas tablas, ya que la carga es responsabilidad del proceso ETL.

---

## 5. Configurar Apache Hop

Abrir Apache Hop 2.19.0 y cargar el proyecto ubicado en:

```text
etl/
```

El archivo:

```text
etl/project-config.json
```

contiene la configuración general del proyecto.

La solución utiliza `${PROJECT_HOME}` para evitar dependencias de rutas absolutas.

---

## 6. Configurar la conexión con PostgreSQL

Crear o verificar en Apache Hop una conexión denominada:

```text
PostgreSQL_CadenaHotelera
```

Configuración:

| Parámetro | Valor |
|---|---|
| Motor | PostgreSQL |
| Host | `localhost` |
| Puerto | `5432` |
| Base de datos | `cadena_hotelera_g3` |
| Usuario | Usuario PostgreSQL local |
| Contraseña | Contraseña PostgreSQL local |

Las credenciales no se almacenan en el repositorio y deben configurarse localmente.

Antes de continuar, utilizar **Test Connection** para verificar la conexión.

---

## 7. Ejecutar el proceso ETL

Abrir:

```text
etl/workflows/wf_carga_completa.hwf
```

y ejecutar el workflow.

El proceso realizará secuencialmente:

```text
dim_hotel
↓
dim_habitacion
↓
dim_canal
↓
dim_cliente
↓
dim_tarifa
↓
dim_fecha
↓
fact_reservas
```

---

## 8. Validar la carga dimensional

Una vez finalizado el workflow, verificar en PostgreSQL los registros cargados.

Resultados esperados:

| Tabla | Registros |
|---|---:|
| `dim_hotel` | 5 |
| `dim_habitacion` | 200 |
| `dim_canal` | 5 |
| `dim_cliente` | 2000 |
| `dim_tarifa` | 360 |
| `dim_fecha` | 725 |
| `fact_reservas` | 12000 |

Consultas básicas:

```sql
SELECT COUNT(*) FROM dimensional.dim_hotel;
SELECT COUNT(*) FROM dimensional.dim_habitacion;
SELECT COUNT(*) FROM dimensional.dim_canal;
SELECT COUNT(*) FROM dimensional.dim_cliente;
SELECT COUNT(*) FROM dimensional.dim_tarifa;
SELECT COUNT(*) FROM dimensional.dim_fecha;
SELECT COUNT(*) FROM dimensional.fact_reservas;
```

Si se encuentra disponible el archivo:

```text
Modelo dimensional/02_DQL_validaciones_dimensional.sql
```

también puede utilizarse para realizar validaciones adicionales de integridad y contenido.

---

## 9. Ejecutar la solución analítica

Abrir el archivo `.pbix` incluido en la carpeta:

```text
Dashboard/
```

La solución analítica utiliza la información del esquema:

```text
dimensional
```

de PostgreSQL.

En caso de trabajar con archivos CSV exportados desde PostgreSQL, deberán utilizarse los correspondientes a:

```text
dim_hotel
dim_habitacion
dim_canal
dim_cliente
dim_tarifa
dim_fecha
fact_reservas
```

Actualizar las rutas o credenciales de la fuente de datos en Power BI cuando sea necesario.

---

# Validación de la solución

La solución debe permitir verificar:

```text
Fuente operacional
        ↓
Proceso ETL
        ↓
Modelo dimensional
        ↓
Dashboard
        ↓
Preguntas de negocio
```

La trazabilidad se conserva desde las tablas operacionales hasta las dimensiones y la tabla de hechos mediante los pipelines implementados en Apache Hop.

---

# Documentación

La documentación completa del proyecto se encuentra en:

```text
Documentacion/Informe del proyecto - Grupo 3.pdf
```

El informe contiene:

- descripción del caso;
- objetivos;
- requerimientos;
- KPIs;
- modelo operacional;
- modelo dimensional;
- diccionario de datos;
- diseño del ETL;
- evidencias de ejecución;
- solución analítica;
- respuestas a las preguntas de negocio;
- hallazgos;
- conclusiones;
- limitaciones;
- posibles mejoras.

---

# Presentación

La presentación utilizada para la exposición se encuentra en:

```text
Presentacion/Presentación.pdf
```

---

# Limitaciones identificadas

La solución fue desarrollada considerando un alcance académico.

Entre las principales limitaciones se encuentran:

- uso de datos sintéticos;
- granularidad de una fila por reserva;
- disponibilidad de habitaciones representada mediante valores agregados;
- servicios complementarios almacenados como columnas fijas;
- ausencia de historial de cambios en dimensiones;
- uso de una estrategia de carga completa.

---

# Posibles mejoras futuras

Como evolución de la solución se consideran:

- implementar una tabla de hechos de ocupación diaria;
- crear una tabla de hechos de consumos y una dimensión de servicios;
- implementar Slowly Changing Dimensions tipo 2;
- desarrollar cargas incrementales;
- incorporar tablas de errores para registros rechazados;
- almacenar los días de anticipación directamente en la tabla de hechos;
- publicar el dashboard en Power BI Service;
- utilizar datos reales;
- incorporar modelos predictivos para cancelaciones y no-show.

---

# Control de versiones y colaboración

El proyecto utiliza Git y GitHub para mantener la trazabilidad del trabajo realizado.

Se recomienda que cada modificación significativa se registre mediante commits descriptivos relacionados con:

```text
Modelo operacional
Modelo dimensional
ETL
Dashboard
Documentación
Presentación
```

El historial del repositorio permite identificar la participación de los integrantes y la evolución técnica de la solución.

---

# Repositorio

Repositorio oficial del proyecto:

https://github.com/melodycotoviera11-ctrl/Proyecto1_Grupo3