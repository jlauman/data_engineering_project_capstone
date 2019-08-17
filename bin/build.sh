#!/usr/bin/env bash
set -e

SCRIPT_DIR=$(dirname "$0")
PROJECT_DIR=$(cd ${SCRIPT_DIR}/../; pwd)

docker build --tag capstone-postgres-11.3 --file "${PROJECT_DIR}/etc/Dockerfile" "${PROJECT_DIR}"
