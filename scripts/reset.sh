#!/usr/bin/env bash

set -euo pipefail

trap "printf \"\n-- %s -- \n\n\" \"$0: was interrupted\" >&2; exit 2" INT TERM

docker compose down

rm -rf data/

cp .env.example .env

cp docker-compose.example.yml docker-compose.yml

sh scripts/envsubst.sh

docker compose up -d --build --force-recreate --wait

sh scripts/init.sh

sh scripts/envsubst.sh

docker compose up -d --build --force-recreate --wait

printf "\n-- %s --\n\n" "$0: finished successfully"
