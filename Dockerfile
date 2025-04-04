FROM jupyter/pyspark-notebook:spark-3.3.1

USER root
COPY requirements.txt /tmp/
RUN pip install --upgrade pip && pip install -r /tmp/requirements.txt
USER jovyan
