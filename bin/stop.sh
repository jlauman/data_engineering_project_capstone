#!/usr/bin/env bash
set -e

SCRIPT_DIR=$(dirname "$0")

CONTAINER_EXISTS=$(docker ps | grep "capstone-database$" | wc -l | tr -d " ")

if [ "$CONTAINER_EXISTS" -eq "1" ]; then
   docker kill capstone-database
   sleep 5
fi
