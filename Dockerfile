FROM python:3.6.8 as deps
COPY requirements.txt /
RUN mkdir /install \
    && pip install --upgrade pip \
    && pip install --install-option="--prefix=/install" -r /requirements.txt

FROM python:3.6.8-alpine as base
COPY --from=deps /install /usr/local

RUN apk update && apk add --no-cache --virtual .build-deps \
    gcc \
    python3-dev \
    musl-dev \
    && pip install --no-cache-dir pymysql \
    && pip install --no-cache-dir mysql-connector \
    && apk del .build-deps

WORKDIR /ara

COPY ara.cfg ./

ENV ANSIBLE_CONFIG=/ara/ara.cfg
ENV GUNICORN_WORKERS=4
ENV GUNICORN_BIND_ADDRESS=0.0.0.0

VOLUME [ "/ara" ]
EXPOSE 8000

ENTRYPOINT gunicorn -w ${GUNICORN_WORKERS} -b ${GUNICORN_BIND_ADDRESS}:8000 ara.wsgi:application
