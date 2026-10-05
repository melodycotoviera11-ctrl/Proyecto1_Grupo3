# Modelo Transaccional - Cadena Hotelera G3

## Descripción

Este módulo corresponde a la fuente transaccional u operacional desarrollada para el Proyecto 01 del curso TI-6900 Inteligencia de Negocios.

El caso de estudio corresponde a una cadena hotelera ficticia que requiere analizar información relacionada con reservas, estadías, ocupación, ingresos, cancelaciones, no-show y consumo de servicios complementarios.

La base de datos operacional fue diseñada para almacenar la información necesaria para posteriormente alimentar el modelo dimensional mediante un proceso ETL.

## Problema de negocio

La cadena hotelera requiere integrar y analizar la información generada por sus procesos operativos para apoyar la toma de decisiones comerciales y operativas.

La solución debe disponer de información relacionada con reservas, hoteles, habitaciones, huéspedes, canales de reserva, tarifas, temporadas, estadías, cancelaciones, no-show y servicios complementarios.

La fuente operacional permite almacenar estos datos de manera estructurada y funciona como punto de origen para el proceso de extracción, transformación y carga hacia el modelo dimensional.

## Arquitectura de la solución

La arquitectura general de la solución está compuesta por cuatro capas:

```text
Fuente operacional
PostgreSQL
cadena_hotelera_g3
        │
        ▼
Proceso ETL
Apache Hop
        │
        ▼
Modelo dimensional
PostgreSQL
        │
        ▼
Solución analítica
Power BI
```

La presente carpeta corresponde específicamente a la fuente operacional implementada en PostgreSQL.

## Modelo operacional

El modelo transaccional está compuesto por las siguientes tablas:

| Tabla | Descripción |
|---|---|
| `hotel` | Registra las propiedades de la cadena hotelera. |
| `tipo_habitacion` | Define los diferentes tipos de habitación y sus características. |
| `habitacion` | Registra las habitaciones disponibles en cada hotel. |
| `segmento_huesped` | Define los segmentos utilizados para clasificar a los huéspedes. |
| `huesped` | Almacena la información de los huéspedes. |
| `canal_reserva` | Contiene los canales mediante los cuales se realizan las reservas. |
| `temporada` | Define los periodos de temporada alta y baja. |
| `plan_tarifa` | Registra los diferentes planes tarifarios. |
| `tarifa` | Define el precio por noche según hotel, tipo de habitación, temporada y plan tarifario. |
| `reserva` | Registra las reservas realizadas y su estado. |
| `detalle_reserva` | Relaciona cada reserva con la habitación y tarifa correspondientes. |
| `estadia` | Registra las estadías efectivamente realizadas. |
| `servicio` | Contiene el catálogo de servicios complementarios. |
| `consumo_servicio` | Registra los servicios complementarios consumidos durante cada estadía. |

La estructura diferencia las reservas realizadas de las estadías efectivamente ejecutadas. Esto permite conservar reservas canceladas y casos de no-show sin contabilizarlos como ocupación real.

## Datos utilizados

Los datos utilizados son sintéticos y fueron generados específicamente para fines académicos mediante scripts SQL.

La generación de datos contempla hoteles, habitaciones, huéspedes, reservas, estadías, tarifas, temporadas, canales de reserva y consumos de servicios complementarios.

Las reglas de generación permiten disponer de información para realizar análisis relacionados con ocupación, noches vendidas, ingresos, ADR, RevPAR, cancelaciones, no-show, anticipación de reservas y servicios complementarios.

Los valores generados no corresponden a información real de ninguna empresa hotelera.

## Herramientas utilizadas

| Herramienta | Uso |
|---|---|
| PostgreSQL 18 | Sistema gestor de base de datos utilizado para implementar la fuente operacional. |
| pgAdmin 4 | Administración de PostgreSQL, ejecución de scripts y generación del diagrama del modelo. |
| SQL | Definición de la estructura, generación de datos y consultas de validación. |
| Git y GitHub | Control de versiones y almacenamiento de los recursos del proyecto. |
| Apache Hop | Herramienta utilizada posteriormente para realizar el proceso ETL. |
| Power BI | Herramienta utilizada posteriormente para construir la solución analítica. |

## Estructura de archivos

```text
Modelo_transaccional/
│
├── 01_DDL_modelo_operacional.sql
├── 02_DML_datos_operacionales.sql
├── 03_DQL_consultas_validacion.sql
├── modelo_transaccional.png
└── README.md
```

### 01_DDL_modelo_operacional.sql

Contiene la definición de la estructura de la fuente operacional, incluyendo:

- creación del esquema `operacional`;
- creación de tablas;
- llaves primarias;
- llaves foráneas;
- restricciones de integridad;
- índices.

### 02_DML_datos_operacionales.sql

Contiene la carga de los catálogos y la generación de los datos sintéticos utilizados en la fuente operacional.

### 03_DQL_consultas_validacion.sql

Contiene consultas utilizadas para verificar la correcta carga de los datos, validar la integridad de la información y realizar comprobaciones preliminares relacionadas con los requerimientos del proyecto.

## Requisitos previos

Para ejecutar el modelo operacional se requiere:

| Requisito | Configuración |
|---|---|
| PostgreSQL | Versión 18 o compatible |
| pgAdmin | pgAdmin 4 |
| Puerto predeterminado | `5432` |
| Base de datos | `cadena_hotelera_g3` |
| Esquema | `operacional` |

## Instrucciones de ejecución

### 1. Crear la base de datos

Crear en PostgreSQL una base de datos con el siguiente nombre:

```text
cadena_hotelera_g3
```

Desde pgAdmin puede realizarse mediante:

```text
Databases > Create > Database
```

También puede utilizarse el siguiente comando SQL desde una conexión con permisos para crear bases de datos:

```sql
CREATE DATABASE cadena_hotelera_g3
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = FALSE;
```

### 2. Conectarse a la base de datos

Desde pgAdmin seleccionar la base:

```text
Servers
└── PostgreSQL 18
    └── Databases
        └── cadena_hotelera_g3
```

Posteriormente abrir:

```text
Tools > Query Tool
```

### 3. Ejecutar el script DDL

Ejecutar primero:

```text
01_DDL_modelo_operacional.sql
```

Este script crea el esquema `operacional`, las tablas, relaciones, restricciones e índices necesarios.

### 4. Ejecutar el script DML

Ejecutar posteriormente:

```text
02_DML_datos_operacionales.sql
```

Este script carga los catálogos y genera los datos sintéticos utilizados como fuente operacional.

### 5. Ejecutar el script DQL

Finalmente ejecutar:

```text
03_DQL_consultas_validacion.sql
```

Este archivo contiene consultas para validar la información cargada y comprobar que la fuente operacional dispone de los datos requeridos para el análisis.

## Validaciones principales

Después de ejecutar los scripts se recomienda verificar los siguientes aspectos:

| Validación | Resultado esperado |
|---|---|
| Tablas operacionales | 14 tablas dentro del esquema `operacional` |
| Hoteles | 5 propiedades |
| Habitaciones | 200 habitaciones |
| Huéspedes | 2000 registros sintéticos |
| Reservas | 12000 registros sintéticos |
| Estadías | Asociadas únicamente a reservas completadas |
| Cancelaciones | No generan estadías |
| No-show | No generan estadías |
| Solapamientos | No deben existir estadías simultáneas para una misma habitación |
| Servicios complementarios | Deben existir consumos asociados a estadías completadas |

## Relación con el proceso ETL

La fuente operacional constituye el punto de origen del proceso ETL.

Apache Hop será utilizado para extraer los registros almacenados en PostgreSQL, aplicar las reglas de transformación necesarias y cargar posteriormente la información en el modelo dimensional.

El flujo general es el siguiente:

```text
Fuente operacional
        │
        ▼
Extracción
        │
        ▼
Limpieza y validación
        │
        ▼
Homologación
        │
        ▼
Derivación de campos
        │
        ▼
Búsqueda de llaves subrogadas
        │
        ▼
Carga de dimensiones
        │
        ▼
Carga de tabla de hechos
```

Durante este proceso pueden derivarse campos como la duración de la estadía, los días de anticipación de una reserva y los indicadores asociados a cancelaciones y no-show.

## Preguntas de negocio soportadas

La fuente operacional contiene la información necesaria para alimentar posteriormente el modelo dimensional y responder las preguntas definidas para el caso.

### Ocupación, noches vendidas e ingresos

La información puede analizarse según hotel, tipo de habitación, temporada y canal de reserva.

### ADR y RevPAR

Los datos de ingresos, noches vendidas, habitaciones y periodos permiten obtener los indicadores ADR y RevPAR por propiedad y periodo.

### Cancelaciones y no-show

Las reservas pueden analizarse según canal de reserva, tarifa y segmento del huésped.

### Servicios complementarios

Los consumos de servicios permiten identificar los ingresos generados por cada servicio y relacionarlos con el perfil del huésped, la duración de la estadía y la propiedad.

### Anticipación de reservas

La fecha de realización de la reserva y la fecha de entrada prevista permiten calcular los días de anticipación y analizar su relación con la cancelación, la ocupación y los ingresos.

## Consideraciones

La base de datos y los registros utilizados corresponden a un escenario ficticio creado exclusivamente para fines académicos.

La fuente operacional fue diseñada a partir de los requerimientos de información definidos para el proyecto y constituye el punto de partida para la construcción del modelo dimensional, el proceso ETL y la solución analítica.
