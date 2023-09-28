#!/usr/bin/env bash

set -euo pipefail

# -- error handling ------------------------------------------------------------

trap "printf \"\n-- %s -- \n\n\" \"$0: was interrupted\" >&2; exit 2" INT TERM

# -- check dependencies --------------------------------------------------------

if ! command -v sed >/dev/null; then
  printf "\n-- %s --\n" "sed: command not found"
  exit 1
fi

# -- check if config directory exists, else exit -------------------------------

if [[ ! -d config ]]; then
  printf "\n-- %s --\n" "./config/ directory not found"
  printf "\n-- %s --\n" "make sure to follow the setup instructions in README.md"
  exit 1
fi

# -- import variables from .env ------------------------------------------------

set -o allexport && source .env && set +o allexport

# -- create matrix-synapse account for medienhaus ------------------------------
# -- NOTE: for now this needs to be an admin account due to ratelimit reasons --

docker exec matrix-synapse \
  register_new_matrix_user http://localhost:8008 \
    -c /etc/matrix-synapse/homeserver.yaml \
    --user "${MEDIENHAUS_ADMIN_USER_ID}" \
    --password "${MEDIENHAUS_ADMIN_PASSWORD}" \
    --admin

# -- retrieve access_token for medienhaus account ------------------------------

#MEDIENHAUS_ADMIN_ACCESS_TOKEN=$(docker exec -i matrix-synapse \
#  curl "http://localhost:8008/_matrix/client/r0/login" \
#    --silent \
#    --request POST \
#    --data-binary @- << EOF | grep -o '"access_token":"[^"]*' | grep -o '[^"]*$'
#{
#  "type": "m.login.password",
#  "user": "${MEDIENHAUS_ADMIN_USER_ID}",
#  "password": "${MEDIENHAUS_ADMIN_PASSWORD}"
#}
#EOF
#)

MEDIENHAUS_ADMIN_ACCESS_TOKEN=$(docker exec -i matrix-synapse \
  curl "http://localhost:8008/_matrix/client/r0/login" \
    --silent \
    --request POST \
    --data-binary @- << EOF | sed -En 's/.*"access_token":"([^"]*).*/\1/p'
{
  "type": "m.login.password",
  "user": "${MEDIENHAUS_ADMIN_USER_ID}",
  "password": "${MEDIENHAUS_ADMIN_PASSWORD}"
}
EOF
)

# -- create root context space for medienhaus ----------------------------------

MEDIENHAUS_ROOT_CONTEXT_SPACE_ID=$(docker exec -i matrix-synapse \
  curl "http://localhost:8008/_matrix/client/r0/createRoom?access_token=${MEDIENHAUS_ADMIN_ACCESS_TOKEN}" \
    --silent \
    --request POST \
    --data-binary @- << EOF | sed -En 's/.*"room_id":"([^"]*).*/\1/p'
{
  "name": "medienhaus/ root context",
  "preset": "private_chat",
  "visibility": "private",
  "power_level_content_override": {
    "events_default": 100,
    "invite": 50
  },
  "topic": "medienhaus/ root context — https://github.com/medienhaus/",
  "creation_content": {
    "type": "m.space"
  },
  "initial_state": [
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
        "template": "context"
      }
    }
  ]
}
EOF
)

# -- configure medienhaus-api --------------------------------------------------

sed \
    -e "s/\${MEDIENHAUS_ADMIN_USER_ID}/${MEDIENHAUS_ADMIN_USER_ID}/g" \
    -e "s/\${MATRIX_SERVERNAME}/${MATRIX_SERVERNAME}/g" \
    -e "s/\${MEDIENHAUS_ADMIN_ACCESS_TOKEN}/${MEDIENHAUS_ADMIN_ACCESS_TOKEN}/g" \
    -e "s/\${MEDIENHAUS_ROOT_CONTEXT_SPACE_ID}/${MEDIENHAUS_ROOT_CONTEXT_SPACE_ID}/g" \
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
    -e "s/\${MEDIENHAUS_ROOT_CONTEXT_SPACE_ID}/${MEDIENHAUS_ROOT_CONTEXT_SPACE_ID}/g" \
    ./template/medienhaus-cms.env \
    > ./config/medienhaus-cms.env

sed \
    -e "s/\${HTTP_SCHEMA}/${HTTP_SCHEMA}/g" \
    -e "s/\${SPACES_HOSTNAME}/${SPACES_HOSTNAME}/g" \
    ./template/medienhaus-cms.config.json \
    > ./config/medienhaus-cms.config.json

# -- configure medienhaus-spaces -----------------------------------------------

sed \
    -e "s/\${SPACES_APP_PREFIX}/${SPACES_APP_PREFIX}/g" \
    -e "s/\${HTTP_SCHEMA}/${HTTP_SCHEMA}/g" \
    -e "s/\${MATRIX_BASEURL}/${MATRIX_BASEURL}/g" \
    -e "s/\${SPACES_HOSTNAME}/${SPACES_HOSTNAME}/g" \
    -e "s/\${MEDIENHAUS_ROOT_CONTEXT_SPACE_ID}/${MEDIENHAUS_ROOT_CONTEXT_SPACE_ID}/g" \
    ./template/medienhaus-spaces.config.js \
    > ./config/medienhaus-spaces.config.js

cp \
    ./template/element-medienhaus-spaces.json \
    ./config/element-medienhaus-spaces.json

# -- update docker-compose.yml and docker-compose.websecure.yml ----------------

sed -i '' '1,2 s/^#//' docker-compose.yml
sed -i '' '1,2 s/^#//' docker-compose.websecure.yml

# -- print success message -----------------------------------------------------

printf "\n-- %s --\n\n" "$0: finished successfully"
