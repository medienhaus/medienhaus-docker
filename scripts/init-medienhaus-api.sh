#!/usr/bin/env bash

set -euo pipefail

# -- error handling ------------------------------------------------------------

trap "printf \"\n-- %s -- \n\n\" \"$0: was interrupted\" >&2; exit 2" INT TERM

# -- check dependencies --------------------------------------------------------

if ! command -v sed >/dev/null; then
  printf "\n-- %s --\n" "sed: command not found"
  exit 1
fi

# -- check if config directory exists, else exit if non-existent ---------------

if [[ ! -d config ]]; then
  printf "\n-- %s --\n" "./config/ directory not found"
  printf "\n-- %s --\n" "make sure to follow the setup instructions in README.md"
  exit 1
fi

# -- import variables from .env ------------------------------------------------

set -o allexport && source .env && set +o allexport

# -- configure matrix-synapse --------------------------------------------------

docker exec matrix-synapse \
  register_new_matrix_user http://localhost:8008 \
    -c /etc/matrix-synapse/homeserver.yaml \
    --user "${MEDIENHAUS_API_USER_ID}" \
    --password "${MEDIENHAUS_API_PASSWORD}" \
    --admin

#MEDIENHAUS_API_ACCESS_TOKEN=$(docker exec matrix-synapse \
#  curl "http://localhost:8008/_matrix/client/r0/login" \
#    --silent \
#    --request POST \
#    --data-binary @- << EOF | grep -o '"access_token":"[^"]*' | grep -o '[^"]*$'
#{
#  "type": "m.login.password",
#  "user": "${MATRIX_ADMIN_USER}",
#  "password": "${MATRIX_ADMIN_PASSWORD}"
#}
#EOF
#)

MEDIENHAUS_API_ACCESS_TOKEN=$(docker exec matrix-synapse \
  curl "http://localhost:8008/_matrix/client/r0/login" \
    --silent \
    --request POST \
    --data-binary @- << EOF | sed -En 's/.*"access_token":"([^"]*).*/\1/p'
{
  "type": "m.login.password",
  "user": "${MEDIENHAUS_API_USER_ID}",
  "password": "${MEDIENHAUS_API_PASSWORD}"
}
EOF
)

# -- configure medienhaus-api --------------------------------------------------

sed \
    -e "s/\${HTTP_SCHEMA}/${HTTP_SCHEMA}/g" \
    -e "s/\${MATRIX_BASEURL}/${MATRIX_BASEURL}/g" \
    -e "s/\${MATRIX_SERVERNAME}/${MATRIX_SERVERNAME}/g" \
    -e "s/\${MEDIENHAUS_API_USER_ID}/${MEDIENHAUS_API_USER_ID}/g" \
    -e "s/\${MEDIENHAUS_API_ACCESS_TOKEN}/${MEDIENHAUS_API_ACCESS_TOKEN}/g" \
    ./template/medienhaus-api.config.js \
    > ./config/medienhaus-api.config.js

# -- configure medienhaus-cms --------------------------------------------------

##sed \
##    -e "s/\${SPACES_HOSTNAME}/${SPACES_HOSTNAME}/g" \
##    ./template/nginx-medienhaus-cms.conf \
##    > ./config/nginx-medienhaus-cms.conf
#
#sed \
#    -e "s/\${SPACES_APP_PREFIX}/${SPACES_APP_PREFIX}/g" \
#    -e "s/\${HTTP_SCHEMA}/${HTTP_SCHEMA}/g" \
#    -e "s/\${MATRIX_BASEURL}/${MATRIX_BASEURL}/g" \
#    -e "s/\${SPACES_HOSTNAME}/${SPACES_HOSTNAME}/g" \
#    ./template/medienhaus-cms.env \
#    > ./config/medienhaus-cms.env
#
#cp \
#    ./template/medienhaus-cms.config.json \
#    ./config/medienhaus-cms.config.json

# -- print success message -----------------------------------------------------

printf "\n-- %s --\n\n" "$0: finished successfully"
