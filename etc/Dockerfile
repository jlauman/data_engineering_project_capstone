FROM postgres:11

RUN apt-get update &&\
    apt-get install -y --no-install-recommends postgresql-11-postgis-2.5 postgresql-11-postgis-2.5-scripts postgis &&\
    rm -rf /var/lib/apt/lists/*

COPY ./database.sh /docker-entrypoint-initdb.d/
