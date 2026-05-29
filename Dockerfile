# Proyecto Final · ML con PySpark y Docker · Michael Morantes
#
# Imagen base oficial de Jupyter Docker Stacks con PySpark 3.x + JupyterLab.
# Sobre ella instalamos las dependencias de NLP (transformers, pysentimiento)
# y utilidades de visualización.
FROM quay.io/jupyter/pyspark-notebook:2024-10-14

LABEL maintainer="Michael Morantes <michaelmorantesp@gmail.com>"
LABEL project="proyecto_final_morantes_michael"

# Las dependencias se instalan como el usuario por defecto (jovyan).
USER ${NB_UID}

COPY --chown=${NB_UID}:${NB_GID} requirements.txt /tmp/requirements.txt

RUN pip install --no-cache-dir -r /tmp/requirements.txt \
    && rm /tmp/requirements.txt

# Pre-descargar los pesos del modelo pre-entrenado (robertuito-sentiment-analysis)
# para que el primer notebook no dependa de red. Se cachean en ~/.cache/huggingface.
RUN python -c "from pysentimiento import create_analyzer; create_analyzer(task='sentiment', lang='es')"

# El directorio de trabajo se monta desde el host vía docker-compose.
WORKDIR /home/jovyan/work
