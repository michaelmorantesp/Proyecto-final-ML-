# Proyecto Final · Machine Learning con PySpark y Docker

> **Curso:** Machine Learning con PySpark y Docker — Semestre 2026-1
> **Estudiante:** **Michael Morantes** — Pregrado en Estadística
> **Peso:** 50 % del parcial final · **Modalidad:** individual con sustentación oral
> **Estado:** estructura del proyecto generada · pendiente implementación de los notebooks

---

## 39. Estudiante

**Michael Morantes** — `michaelmorantesp@gmail.com`

## 40. Descripción del problema

Este proyecto integra tres bloques técnicos (EDA, ML supervisado/no supervisado y NLP) sobre una
misma historia: **el trabajo y la voz del ciudadano colombiano**. Primero medimos y modelamos la
**informalidad laboral** —un problema estructural del país— con microdatos GEIH del DANE
(Bloques 1 y 2). Luego escuchamos la **voz del ciudadano** a través de las PQRS dirigidas a una
entidad pública, mediante NLP (Bloque 3).

El hilo conductor es la relación **Estado–ciudadano**: condiciones laborales objetivas vs.
percepción y quejas subjetivas hacia la administración.

## 41. Datasets por bloque

| Bloque | Dataset | Filas | Fuente oficial |
|---|---|---|---|
| 1 · EDA | **GEIH — Gran Encuesta Integrada de Hogares**, corte **Diciembre 2025** | ≈ 66.559 personas (29.611 ocupados) | [microdatos.dane.gov.co · catálogo 853](https://microdatos.dane.gov.co/index.php/catalog/853) |
| 2 · ML | GEIH (mismo corte; label = no cotiza a pensión) | 29.126 ocupados con label | DANE — Microdatos GEIH |
| 3 · NLP | **PQRS Alcaldía de Flandes** (`gb9w-jt96`) | 4.643 documentos | [datos.gov.co · Socrata](https://www.datos.gov.co/resource/gb9w-jt96.csv) |

## 42. Cómo ejecutar

### Requisitos

- Docker Desktop (Windows / macOS / Linux) con **mínimo 6 GB de RAM disponibles**.
- Conexión a internet la primera vez (para descargar imagen base + pesos del modelo HF).

### Paso 1 — Descargar los datos

**PQRS** (vía API Socrata, sin login):

```bash
python scripts/download_pqrs.py
```

**GEIH** (manual, sin login pero requiere navegador):

1. Abrir https://microdatos.dane.gov.co/index.php/catalog/853/get-microdata
2. Descargar el mes deseado (este proyecto usa **Diciembre 2025**) — ZIP de ~60 MB.
3. Colocar el ZIP en `data/geih/GEIH_<Mes>_<Año>.zip`.
4. Descomprimir los CSV a `data/geih/csv/` con nombres limpios (ver
   `scripts/_gen_notebooks.py` o el primer notebook).

### Paso 2 — Levantar el entorno

```bash
docker-compose up --build
```

Abrir el enlace `http://localhost:8888` que imprime el contenedor. No hay token (entorno local).

### Paso 3 — Ejecutar los notebooks en orden

1. `bloque1_eda/bloque1_eda_morantes.ipynb` — EDA GEIH (puntos 1–6)
2. `bloque2_ml/bloque2_ml_morantes.ipynb` — ML sobre informalidad (puntos 7–20)
3. `bloque3_nlp/bloque3_nlp_morantes.ipynb` — NLP sobre PQRS (puntos 21–38)

Cada notebook está diseñado para correr **Restart & Run All** sin errores.

### Versiones

- Python 3.11 (imagen `quay.io/jupyter/pyspark-notebook:2024-10-14`)
- PySpark 3.5.x
- Dependencias completas en `requirements.txt`

## 43. Conclusión integrada

> _Pendiente — se completa al cerrar los 3 bloques (5–8 líneas conectando informalidad medida
> en GEIH con el tono de las PQRS de Flandes)._

---

## Estructura del repositorio

```
proyecto_final_morantes_michael/
├── README.md                    # este archivo (puntos 39–43)
├── claude.md                    # plan maestro y especificación técnica
├── Dockerfile                   # imagen jupyter/pyspark + NLP
├── docker-compose.yml           # servicio jupyter
├── requirements.txt             # dependencias Python
├── .gitignore
├── data/
│   ├── geih/                    # ZIP + CSV módulos GEIH (no versionado)
│   └── pqrs/                    # CSV PQRS Flandes (no versionado)
├── scripts/
│   ├── download_pqrs.py         # descarga reproducible PQRS
│   └── _gen_notebooks.py        # regenera los esqueletos de notebooks
├── bloque1_eda/
│   └── bloque1_eda_morantes.ipynb
├── bloque2_ml/
│   ├── bloque2_ml_morantes.ipynb
│   └── models/                  # modelos Spark guardados (opcional)
├── bloque3_nlp/
│   └── bloque3_nlp_morantes.ipynb
├── img/                         # figuras exportadas para el reporte
└── reporte_ejecutivo.pdf        # pendiente (2–3 páginas)
```

## Reproducibilidad

- Semilla fija `seed=42` en todos los `randomSplit`, `KMeans` y modelos.
- Versiones de librerías ancladas en `requirements.txt`.
- Imagen Docker etiquetada (`quay.io/jupyter/pyspark-notebook:2024-10-14`).
- Todos los notebooks pasan `Restart & Run All` antes de la entrega.
