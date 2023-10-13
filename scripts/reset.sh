#!/usr/bin/env bash

set -euo pipefail

# -- error handling ------------------------------------------------------------

trap "printf \"\n-- %s -- \n\n\" \"$0: was interrupted\" >&2; exit 2" INT TERM

# -- show help / print usage information ---------------------------------------

show_help() {
cat << EOF

-- reset for medienhaus-spaces (default) --

sh $0


-- reset for medienhaus-spaces and medienhaus-api --

sh $0 --api


-- reset for medienhaus-spaces and medienhaus-cms --

sh $0 --cms


-- reset for medienhaus-* (all of the above) --

sh $0 --all

EOF
}

# -- check command-line arguments ----------------------------------------------

if [[ $# -eq 0 ]]; then
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
  exit
else
  while [[ $# -gt 0 ]]; do
    case $1 in
      --api)
        docker compose down
        rm -rf data/
        cp .env.example .env
        cp docker-compose.example.yml docker-compose.yml
        sh scripts/envsubst.sh
        docker compose up -d --build --force-recreate --wait
        sh scripts/init.sh --api
        sh scripts/envsubst.sh --api
        docker compose up -d --build --force-recreate --wait
        printf "\n-- %s --\n\n" "$0 $1: finished successfully"
        exit
        ;;
      --cms)
        docker compose down
        rm -rf data/
        cp .env.example .env
        cp docker-compose.example.yml docker-compose.yml
        sh scripts/envsubst.sh
        docker compose up -d --build --force-recreate --wait
        sh scripts/init.sh --cms
        sh scripts/envsubst.sh --cms
        docker compose up -d --build --force-recreate --wait
        printf "\n-- %s --\n\n" "$0 $1: finished successfully"
        exit
        ;;
      --all)
        docker compose down
        rm -rf data/
        cp .env.example .env
        cp docker-compose.example.yml docker-compose.yml
        sh scripts/envsubst.sh
        docker compose up -d --build --force-recreate --wait
        sh scripts/init.sh --all
        sh scripts/envsubst.sh --all
        docker compose up -d --build --force-recreate --wait
        printf "\n-- %s --\n\n" "$0 $1: finished successfully"
        exit
        ;;
      *)
        show_help
        exit
        ;;
    esac
  done
fi
