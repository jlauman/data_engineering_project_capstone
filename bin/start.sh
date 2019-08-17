#!/usr/bin/env bash
set -e

SCRIPT_DIR=$(dirname "$0")
PROJECT_DIR=$(cd ${SCRIPT_DIR}/../; pwd)

PG_USER=$(cat ${PROJECT_DIR}/etc/postgres-user)
PG_PASSWORD=$(cat ${PROJECT_DIR}/etc/postgres-pass)

VOLUMES_DIR="${PROJECT_DIR}/mnt/postgres"
echo "VOLUMES_DIR=${VOLUMES_DIR}"

if [ -d ${VOLUMES_DIR} ]; then
    rm -rf ${VOLUMES_DIR}
fi
mkdir -p ${VOLUMES_DIR}

CONTAINER_EXISTS=$(docker ps | grep "capstone-database$" | wc -l | tr -d " ")

if [ "$CONTAINER_EXISTS" -eq "1" ]; then
   docker kill capstone-database
   sleep 5
fi

docker run \
    --name capstone-database \
    --publish 5432:5432 \
    --mount type=bind,source="${VOLUMES_DIR}",target=/var/lib/postgresql/data \
    --env POSTGRES_USER=$PG_USER \
    --env POSTGRES_PASSWORD=$PG_PASSWORD \
    --rm --detach \
    capstone-postgres-11.3


docker logs -f capstone-database
