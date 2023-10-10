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

if [[ ! -w .env ]]; then
  printf "\n-- %s --\n" ".env file not found or not writable"
  printf "\n-- %s --\n" "make sure to follow the setup instructions in README.md"
  exit 1
fi

# -- import variables from .env ------------------------------------------------

set -o allexport && source .env && set +o allexport

# -- create matrix-synapse account for medienhaus-* ----------------------------
# -- NOTE: for now this needs to be an admin account due to ratelimit reasons --

docker exec matrix-synapse \
  register_new_matrix_user http://localhost:8008 \
    -c /etc/matrix-synapse/homeserver.yaml \
    --user "${MEDIENHAUS_ADMIN_USER_ID}" \
    --password "${MEDIENHAUS_ADMIN_PASSWORD}" \
    --admin

# -- retrieve access_token for created matrix-synapse account ------------------

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

# -- create root context space for medienhaus-* and retrieve room_id -----------

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

# -- configure access_token and room_id in .env --------------------------------

configure_env() {
  sed -i '' '67 s/^#//' .env
  sed -i '' '68 s/^#//' .env

  sed -i '' \
      -e "s/\${MEDIENHAUS_ADMIN_ACCESS_TOKEN}/${MEDIENHAUS_ADMIN_ACCESS_TOKEN}/g" \
      -e "s/\${MEDIENHAUS_ROOT_CONTEXT_SPACE_ID}/${MEDIENHAUS_ROOT_CONTEXT_SPACE_ID}/g" \
      ./.env
}

# -- configure includes in docker-compose.yml ----------------------------------

configure_compose_spaces() {
  sed -i '' '1 s/^#//' docker-compose.yml
  sed -i '' '2 s/^#//' docker-compose.yml
}

configure_compose_api() {
  sed -i '' '1 s/^#//' docker-compose.yml
  sed -i '' '3 s/^#//' docker-compose.yml
}

configure_compose_cms() {
  sed -i '' '1 s/^#//' docker-compose.yml
  sed -i '' '4 s/^#//' docker-compose.yml
}

# -- show help / print usage information ---------------------------------------
#
show_help() {
cat << EOF

  -- init for medienhaus-spaces (default) --

  sh $0


  -- init for medienhaus-spaces and medienhaus-api --

  sh $0 --api


  -- init for medienhaus-spaces and medienhaus-cms --

  sh $0 --cms


  -- init for medienhaus-* (all of the above) --

  sh $0 --all

EOF
}

# -- check command-line arguments ----------------------------------------------

if [[ $# -eq 0 ]]; then
  configure_env
  configure_compose_spaces
  printf "\n-- %s --\n\n" "$0: finished successfully"
  exit
else
  while [[ $# -gt 0 ]]; do
    case $1 in
      --api)
        configure_env
        configure_compose_spaces
        configure_compose_api
        printf "\n  -- %s --\n\n" "$0 $1: finished successfully"
        exit
        ;;
      --cms)
        configure_env
        configure_compose_spaces
        configure_compose_cms
        printf "\n  -- %s --\n\n" "$0 $1: finished successfully"
        exit
        ;;
      --all)
        configure_env
        configure_compose_spaces
        configure_compose_api
        configure_compose_cms
        printf "\n  -- %s --\n\n" "$0 $1: finished successfully"
        exit
        ;;
      *)
        show_help
        exit
        ;;
    esac
  done
fi
