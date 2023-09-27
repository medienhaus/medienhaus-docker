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

# -- create matrix-synapse account for api user --------------------------------
# -- NOTE: for now this needs to be an admin account due to ratelimit reasons --

docker exec matrix-synapse \
  register_new_matrix_user http://localhost:8008 \
    -c /etc/matrix-synapse/homeserver.yaml \
    --user "${MEDIENHAUS_API_USER_ID}" \
    --password "${MEDIENHAUS_API_PASSWORD}" \
    --admin

# -- retrieve access_token for api account -------------------------------------

#MEDIENHAUS_API_ACCESS_TOKEN=$(docker exec -i matrix-synapse \
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

MEDIENHAUS_API_ACCESS_TOKEN=$(docker exec -i matrix-synapse \
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

# -- create root context space for medienhaus-api ------------------------------

MEDIENHAUS_API_ROOT_CONTEXT_SPACE_ID=$(docker exec -i matrix-synapse \
  curl "http://localhost:8008/_matrix/client/r0/createRoom?access_token=${MEDIENHAUS_API_ACCESS_TOKEN}" \
    --silent \
    --request POST \
    --data-binary @- << EOF | sed -En 's/.*"room_id":"([^"]*).*/\1/p'
{
  "name": "medienhaus-api-root-context",
  "preset": "private_chat",
  "visibility": "private",
  "power_level_content_override": {
    "events_default": 100,
    "invite": 50
  },
  "topic": "[medienhaus-api](https://github.com/medienhaus/medienhaus-api/) root context",
  "creation_content": {
    "type": "m.space"
  },
  "initial_state": [
    {
      "type": "m.room.guest_access",
      "state_key": "",
      "content": {
        "guest_access": "can_join"
      }
    },
    {
      "type": "m.room.history_visibility",
      "content": {
        "history_visibility": "world_readable"
      }
    },
    {
      "type": "dev.medienhaus.meta",
      "content": {
        "type": "context",
        "template": "structure-root"
      }
    }
  ]
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
    -e "s/\${MEDIENHAUS_API_ROOT_CONTEXT_SPACE_ID}/${MEDIENHAUS_API_ROOT_CONTEXT_SPACE_ID}/g" \
    ./template/medienhaus-api.config.js \
    > ./config/medienhaus-api.config.js

# -- configure medienhaus-cms --------------------------------------------------

#sed \
#    -e "s/\${SPACES_HOSTNAME}/${SPACES_HOSTNAME}/g" \
#    ./template/nginx-medienhaus-cms.conf \
#    > ./config/nginx-medienhaus-cms.conf

sed \
    -e "s/\${SPACES_APP_PREFIX}/${SPACES_APP_PREFIX}/g" \
    -e "s/\${HTTP_SCHEMA}/${HTTP_SCHEMA}/g" \
    -e "s/\${MATRIX_BASEURL}/${MATRIX_BASEURL}/g" \
    -e "s/\${SPACES_HOSTNAME}/${SPACES_HOSTNAME}/g" \
    ./template/medienhaus-cms.env \
    > ./config/medienhaus-cms.env

cp \
    ./template/medienhaus-cms.config.json \
    ./config/medienhaus-cms.config.json

# -- update docker-compose.yml and docker-compose.websecure.yml ----------------

sed -i '' '1,2 s/^#//' docker-compose.yml
sed -i '' '1,2 s/^#//' docker-compose.websecure.yml

# -- print success message -----------------------------------------------------

printf "\n-- %s --\n\n" "$0: finished successfully"
