# Proyecto BI - Cadena Hotelera

Proyecto de Inteligencia de Negocios desarrollado para una cadena hotelera. Integra una base de datos transaccional en **PostgreSQL** con un proceso **ETL construido en Apache Hop**, que alimenta un **modelo dimensional** listo para análisis en una herramienta de BI.

---

## Tabla de contenidos

1. [Descripción general](#descripción-general)
2. [Arquitectura](#arquitectura)
3. [Herramientas utilizadas](#herramientas-utilizadas)
4. [Estructura del repositorio](#estructura-del-repositorio)
5. [Base de datos y esquemas](#base-de-datos-y-esquemas)
6. [Modelo dimensional](#modelo-dimensional)
7. [Proceso ETL](#proceso-etl)
8. [Reglas de transformación](#reglas-de-transformación)
9. [Workflow maestro](#workflow-maestro)
10. [Configuración del proyecto](#configuración-del-proyecto)
11. [Requisitos](#requisitos)
12. [Conexión a PostgreSQL](#conexión-a-postgresql)
13. [Ejecución](#ejecución)
14. [Resultados esperados](#resultados-esperados)
15. [Validación](#validación)
16. [Evidencia](#evidencia)

---

## Descripción general

El objetivo del proyecto es transformar los datos operativos de la cadena hotelera (reservas, huéspedes, habitaciones, tarifas, servicios, etc.) en un modelo dimensional que facilite el análisis de:

- Ocupación y rendimiento por hotel.
- Ingresos por alojamiento y servicios complementarios.
- Comportamiento por canal de reserva.
- Perfil de los huéspedes.
- Cancelaciones y no-show.
- Estacionalidad y tarifas.

El proceso ETL extrae la información del esquema operacional, aplica transformaciones y carga los resultados en el esquema dimensional dentro de la misma base de datos.

---

## Arquitectura

```text
PostgreSQL
Esquema operacional
        ↓
Apache Hop
Extracción, transformación y carga
        ↓
PostgreSQL
Esquema dimensional
        ↓
Herramienta de BI
```

---

## Herramientas utilizadas

| Herramienta | Versión / Uso |
|---|---|
| Apache Hop | 2.19.0 - Diseño y ejecución del ETL |
| Java | 21 - Requerido por Apache Hop |
| PostgreSQL | Motor de base de datos |
| pgAdmin 4 | Administración y validación de la base de datos |

---

## Estructura del repositorio

```text
etl/
├── README.md
├── project-config.json
├── pipelines/
│   ├── 01_dim_hotel.hpl
│   ├── 02_dim_habitacion.hpl
│   ├── 03_dim_canal.hpl
│   ├── 04_dim_cliente.hpl
│   ├── 05_dim_tarifa.hpl
│   ├── 06_dim_fecha.hpl
│   └── 07_fact_reservas.hpl
└── workflows/
    └── wf_carga_completa.hwf
```

---

## Base de datos y esquemas

Base de datos utilizada:

```text
cadena_hotelera_g3
```

Esquemas principales:

- `operacional`: contiene las tablas transaccionales (origen de los datos).
- `dimensional`: contiene las dimensiones y la tabla de hechos (destino del ETL).

### Tablas del esquema operacional utilizadas

| Tabla | Uso |
|---|---|
| `hotel` | Datos de los hoteles |
| `habitacion` | Habitaciones de cada hotel |
| `tipo_habitacion` | Tipo y capacidad de habitación |
| `canal_reserva` | Canales por los que se realiza una reserva |
| `huesped` | Datos de los clientes |
| `segmento_huesped` | Segmento al que pertenece el huésped |
| `tarifa` | Tarifas por hotel, tipo de habitación, temporada y plan |
| `temporada` | Temporadas |
| `plan_tarifa` | Planes de tarifa |
| `reserva` | Cabecera de reservas |
| `detalle_reserva` | Detalle de habitaciones por reserva |
| `estadia` | Estadías efectivas |
| `consumo_servicio` | Consumos de servicios complementarios |
| `servicio` | Catálogo de servicios |

---

## Modelo dimensional

El modelo sigue un esquema en estrella con una tabla de hechos y seis dimensiones.

```text
                dim_fecha
                    │
dim_hotel ──── fact_reservas ──── dim_cliente
                │       │
        dim_habitacion  dim_canal
                    │
                dim_tarifa
```

### Dimensiones

| Dimensión | Descripción |
|---|---|
| `dim_hotel` | Hoteles, con categoría en estrellas y habitaciones activas |
| `dim_habitacion` | Habitaciones con su tipo y capacidad |
| `dim_canal` | Canales de reserva con su clasificación |
| `dim_cliente` | Huéspedes con su perfil derivado |
| `dim_tarifa` | Tarifas con código y descripción consolidada |
| `dim_fecha` | Calendario con atributos de año, trimestre, mes, día y temporada |

### Tabla de hechos

`fact_reservas` tiene como granularidad **una fila por reserva**. Integra:

- Hotel, habitación, canal, cliente, tarifa y fechas.
- Duración de la estadía (`duracion_estadia_noches`).
- Ingreso por alojamiento.
- Ingreso por servicios complementarios.
- Indicadores de cancelación (`es_cancelacion`) y no-show (`es_noshow`).

---

## Proceso ETL

El proceso está dividido en **siete pipelines independientes** y **un workflow maestro** que los orquesta. Las dimensiones se cargan antes de la tabla de hechos para respetar las relaciones del modelo dimensional.

### 01_dim_hotel.hpl

Carga `dimensional.dim_hotel`.

- **Fuentes:** `operacional.hotel`, `operacional.habitacion`
- **Transformaciones:**
  - Renombramiento de atributos.
  - Conversión de la categoría del hotel al formato `N estrellas`.
  - Cálculo de habitaciones activas disponibles.

### 02_dim_habitacion.hpl

Carga `dimensional.dim_habitacion`.

- **Fuentes:** `operacional.habitacion`, `operacional.tipo_habitacion`
- **Transformaciones:**
  - Asociación de cada habitación con su tipo.
  - Obtención de la capacidad correspondiente.

### 03_dim_canal.hpl

Carga `dimensional.dim_canal`.

- **Fuente:** `operacional.canal_reserva`
- **Transformación:** se genera el campo `tipo_canal` mediante homologación.

| Canal original | `tipo_canal` |
|---|---|
| Sitio web | Directo digital |
| Teléfono | Directo tradicional |
| Recepción | Directo tradicional |
| Agencia | Intermediado |
| OTA | Intermediado |
| Cualquier otro | Otro |

### 04_dim_cliente.hpl

Carga `dimensional.dim_cliente`.

- **Fuentes:** `operacional.huesped`, `operacional.segmento_huesped`
- **Transformación:** se deriva el perfil del huésped.

| Segmento original | `perfil_huesped` |
|---|---|
| Individual | Viajero individual |
| Pareja | Turismo en pareja |
| Familia | Turismo familiar |
| Corporativo | Viajero de negocios |
| Cualquier otro | Sin clasificar |

### 05_dim_tarifa.hpl

Carga `dimensional.dim_tarifa`.

- **Fuentes:** `operacional.tarifa`, `operacional.hotel`, `operacional.tipo_habitacion`, `operacional.temporada`, `operacional.plan_tarifa`
- **Transformaciones:**
  - Generación del código de tarifa en formato `TAR-0001`.
  - Construcción de una descripción consolidada de la tarifa.

### 06_dim_fecha.hpl

Carga `dimensional.dim_fecha`.

La dimensión se genera a partir del rango de fechas registrado en las reservas. Se derivan:

- Año.
- Trimestre.
- Mes.
- Día de la semana.
- Temporada.

La llave de fecha utiliza el formato `YYYYMMDD`. Ejemplo: `20260115`.

### 07_fact_reservas.hpl

Carga `dimensional.fact_reservas`.

- **Granularidad:** una fila por reserva.
- **Fuentes:** `operacional.reserva`, `operacional.detalle_reserva`, `operacional.habitacion`, `operacional.hotel`, `operacional.estadia`, `operacional.consumo_servicio`, `operacional.servicio`
- Los consumos de servicios se agregan por reserva para mantener la granularidad de la tabla de hechos.

---

## Reglas de transformación

### Selección

Se conservan únicamente los atributos necesarios para el modelo dimensional.

### Renombramiento

```text
hotel.nombre → nombre_hotel
canal_reserva.nombre → nombre_canal
huesped.id_huesped → id_cliente
```

### Homologación

Se estandarizan valores categóricos para facilitar su análisis.

```text
Sitio web → Directo digital
Agencia → Intermediado
Familia → Turismo familiar
```

### Derivación

Se crean atributos nuevos a partir de datos existentes:

```text
categoria
tipo_canal
perfil_huesped
codigo_tarifa
descripcion_tarifa
id_fecha
duracion_estadia_noches
es_cancelacion
es_noshow
```

### Manejo de valores nulos

Los valores nulos asociados a ingresos por servicios se reemplazan por `0` mediante `COALESCE`.

### Agregación

Los consumos de servicios complementarios se agrupan por reserva antes de cargarse en la tabla de hechos.

---

## Workflow maestro

El archivo `workflows/wf_carga_completa.hwf` permite ejecutar automáticamente el proceso completo. Carga las dimensiones en secuencia y, al final, la tabla de hechos.

```text
Inicio_ETL
    ↓
01_dim_hotel.hpl
    ↓
02_dim_habitacion.hpl
    ↓
03_dim_canal.hpl
    ↓
04_dim_cliente.hpl
    ↓
05_dim_tarifa.hpl
    ↓
06_dim_fecha.hpl
    ↓
07_fact_reservas.hpl
```

---

## Configuración del proyecto

El archivo `project-config.json` contiene la configuración general del proyecto de Apache Hop.

El proyecto utiliza la variable `${PROJECT_HOME}` para evitar depender de rutas absolutas específicas de una computadora, lo que permite que cualquier integrante del equipo lo abra sin modificar rutas.

---

## Requisitos

- PostgreSQL en ejecución.
- Base de datos `cadena_hotelera_g3`.
- Esquema `operacional` creado y cargado con datos.
- Esquema `dimensional` creado (tablas de dimensiones y hechos).
- Java 21.
- Apache Hop 2.19.0.

---

## Conexión a PostgreSQL

Nombre de la conexión en Apache Hop:

```text
PostgreSQL_CadenaHotelera
```

Configuración general:

| Parámetro | Valor |
|---|---|
| Host | `localhost` |
| Puerto | `5432` |
| Base de datos | `cadena_hotelera_g3` |
| Motor | PostgreSQL |

> Las credenciales **no** se almacenan en el repositorio y deben configurarse localmente.

---

## Ejecución

1. Abrir Apache Hop.
2. Abrir el proyecto ETL.
3. Configurar la conexión `PostgreSQL_CadenaHotelera`.
4. Probar la conexión con PostgreSQL.
5. Abrir `workflows/wf_carga_completa.hwf`.
6. Ejecutar el workflow completo.

---

## Resultados esperados

Con el conjunto de datos utilizado durante el proyecto, se obtuvieron los siguientes registros:

| Tabla | Registros |
|---|---:|
| `dim_hotel` | 5 |
| `dim_habitacion` | 200 |
| `dim_canal` | 5 |
| `dim_cliente` | 2000 |
| `dim_tarifa` | 360 |
| `dim_fecha` | 725 |
| `fact_reservas` | 12000 |

---

## Validación

La carga puede validarse mediante consultas de conteo en pgAdmin 4:

```sql
SELECT COUNT(*) FROM dimensional.dim_hotel;
SELECT COUNT(*) FROM dimensional.dim_habitacion;
SELECT COUNT(*) FROM dimensional.dim_canal;
SELECT COUNT(*) FROM dimensional.dim_cliente;
SELECT COUNT(*) FROM dimensional.dim_tarifa;
SELECT COUNT(*) FROM dimensional.dim_fecha;
SELECT COUNT(*) FROM dimensional.fact_reservas;
```

---

## Evidencia

La evidencia visual de la ejecución y validación del proceso (capturas de pipelines, workflow y consultas) se incluye en el documento principal del proyecto.
