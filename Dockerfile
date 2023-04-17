FROM python:3.11-slim

LABEL maintainer="Niraj Sanghvi <niraj.sanghvi@gmail.com>"

ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1

ENV PAS_PROM_PORT 9101
ENV PAS_LOGGING info
EXPOSE ${PAS_PROM_PORT}

WORKDIR /app

COPY root/ /

RUN pip install -r /app/requirements.txt

CMD python /app/purpleair_scraper.py
