#!/usr/bin/env bash

set -euo pipefail

# -- error handling ------------------------------------------------------------

trap "printf \"\n-- %s -- \n\n\" \"$0: was interrupted\" >&2; exit 2" INT TERM

# -- check dependencies --------------------------------------------------------

if ! command -v sed >/dev/null; then
  printf "\n-- %s --\n" "sed: command not found"
  exit 1
fi

# -- check if .env file exists, else exit --------------------------------------

if [[ ! -w .env ]]; then
  printf "\n-- %s --\n" ".env file not found or not writable"
  printf "\n-- %s --\n" "make sure to follow the setup instructions in README.md"
  exit 1
fi

# -- import variables from .env ------------------------------------------------

set -o allexport && source .env && set +o allexport

# -- register matrix-synapse account for medienhaus-* --------------------------
# -- NOTE: for now this needs to be an admin account due to ratelimit reasons --

register_matrix_account() {
  docker exec matrix-synapse \
    register_new_matrix_user http://localhost:8008 \
      -c /etc/matrix-synapse/homeserver.yaml \
      --user "${MEDIENHAUS_ADMIN_USER_ID}" \
      --password "${MEDIENHAUS_ADMIN_PASSWORD}" \
      --admin
}

# -- retrieve access_token for created matrix-synapse account ------------------

retrieve_access_token() {
  MEDIENHAUS_ADMIN_ACCESS_TOKEN=$(docker exec -i matrix-synapse \
    curl "http://localhost:8008/_matrix/client/r0/login" \
      --silent \
      --request POST \
      --data-binary @- << EOF | sed -n 's/.*"access_token":"\([^"]*\).*/\1/p'
{
  "type": "m.login.password",
  "user": "${MEDIENHAUS_ADMIN_USER_ID}",
  "password": "${MEDIENHAUS_ADMIN_PASSWORD}"
}
EOF
  )
}

# -- create root context space for medienhaus-* and retrieve room_id -----------

create_root_context_space() {
  MEDIENHAUS_ROOT_CONTEXT_SPACE_ID=$(docker exec -i matrix-synapse \
    curl "http://localhost:8008/_matrix/client/r0/createRoom?access_token=${MEDIENHAUS_ADMIN_ACCESS_TOKEN}" \
      --silent \
      --request POST \
      --data-binary @- << EOF | sed -n 's/.*"room_id":"\([^"]*\).*/\1/p'
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
}

# -- configure access_token and room_id in .env --------------------------------

configure_env() {
  sed -e '67s/^#//' \
      -e '68s/^#//' \
      ./.env > ./.env.tmp \
      && mv ./.env.tmp ./.env

  sed -e "s/\${MEDIENHAUS_ADMIN_ACCESS_TOKEN}/${MEDIENHAUS_ADMIN_ACCESS_TOKEN}/g" \
      -e "s/\${MEDIENHAUS_ROOT_CONTEXT_SPACE_ID}/${MEDIENHAUS_ROOT_CONTEXT_SPACE_ID}/g" \
      ./.env > ./.env.tmp \
      && mv ./.env.tmp ./.env
}

# -- configure includes in docker-compose.yml ----------------------------------

configure_compose_spaces() {
  sed -e '1s/^#//' \
      -e '2s/^#//' \
      ./docker-compose.yml > ./docker-compose.tmp \
      && mv ./docker-compose.tmp ./docker-compose.yml
}

configure_compose_api() {
  sed -e '1s/^#//' \
      -e '3s/^#//' \
      ./docker-compose.yml > ./docker-compose.tmp \
      && mv ./docker-compose.tmp ./docker-compose.yml
}

configure_compose_cms() {
  sed -e '1s/^#//' \
      -e '4s/^#//' \
      ./docker-compose.yml > ./docker-compose.tmp \
      && mv ./docker-compose.tmp ./docker-compose.yml
}

# -- show help / print usage information ---------------------------------------

show_help() {
cat << EOF

-- init for medienhaus-spaces (default) --

$0


-- init for medienhaus-spaces and medienhaus-api --

$0 --api


-- init for medienhaus-spaces and medienhaus-cms --

$0 --cms


-- init for medienhaus-* (all of the above) --

$0 --all

EOF
}

# -- check command-line arguments ----------------------------------------------

if [[ $# -eq 0 ]]; then
  register_matrix_account
  retrieve_access_token
  create_root_context_space
  configure_env
  configure_compose_spaces
  printf "\n-- %s --\n\n" "$0: finished successfully"
  exit
else
  while [[ $# -gt 0 ]]; do
    case $1 in
      --api)
        register_matrix_account
        retrieve_access_token
        create_root_context_space
        configure_env
        configure_compose_spaces
        configure_compose_api
        printf "\n-- %s --\n\n" "$0 $1: finished successfully"
        exit
        ;;
      --cms)
        register_matrix_account
        retrieve_access_token
        create_root_context_space
        configure_env
        configure_compose_spaces
        configure_compose_cms
        printf "\n-- %s --\n\n" "$0 $1: finished successfully"
        exit
        ;;
      --all)
        register_matrix_account
        retrieve_access_token
        create_root_context_space
        configure_env
        configure_compose_spaces
        configure_compose_api
        configure_compose_cms
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
