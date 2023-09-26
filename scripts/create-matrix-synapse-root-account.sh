#!/usr/bin/env bash

set -euo pipefail

# -- error handling ------------------------------------------------------------

trap "printf \"\n-- %s -- \n\n\" \"$0: was interrupted\" >&2; exit 2" INT TERM

# -- check if config directory exists, else exit if non-existent ---------------

if [[ ! -d config ]]; then
  printf "\n-- %s --\n" "./config/ directory not found"
  printf "\n-- %s --\n" "make sure to follow the setup instructions in README.md"
  exit 1
fi

# -- import variables from .env ------------------------------------------------

set -o allexport && source .env && set +o allexport

# -- create matrix-synapse root account ----------------------------------------

docker exec matrix-synapse \
  register_new_matrix_user http://localhost:8008 \
    -c /etc/matrix-synapse/homeserver.yaml \
    --user "root" \
    --password "${MATRIX_ADMIN_PASSWORD}" \
    --admin

# -- print success message -----------------------------------------------------

printf "\n-- %s --\n\n" "$0: finished successfully"
