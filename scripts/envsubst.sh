#!/usr/bin/env bash

set -euo pipefail

# -- error handling ------------------------------------------------------------

trap "printf \"\n-- %s -- \n\n\" \"$0: was interrupted\" >&2; exit 2" INT TERM

# -- check dependencies --------------------------------------------------------

if ! command -v sed > /dev/null; then
  printf "\n-- %s --\n" "sed: command not found"
  exit 1
fi

# -- check if config directory exists, else create if non-existent -------------

if [[ ! -d config ]]; then
  mkdir -p config
fi

# -- check if config files exist in config directory; then create backup -------

if command -v find >/dev/null; then
  find config -type f -exec mkdir -p _config-backup \; \
                      -exec cp -R {} _config-backup \;
fi

# -- import variables from .env ------------------------------------------------

set -o allexport && source .env && set +o allexport

# -- configure services --------------------------------------------------------

configure_services() {

  # -- etherpad ----------------------------------------------------------------

  sed \
    -e "s/\${HTTP_SCHEMA}/${HTTP_SCHEMA}/g" \
    -e "s/\${SPACES_HOSTNAME}/${SPACES_HOSTNAME}/g" \
    -e "s/\${ETHERPAD_HOSTNAME}/${ETHERPAD_HOSTNAME}/g" \
    ./template/nginx-etherpad.conf \
    > ./config/nginx-etherpad.conf

  sed \
    -e "s/\${ETHERPAD_POSTGRES_PASSWORD}/${ETHERPAD_POSTGRES_PASSWORD}/g" \
    -e "s/\${ETHERPAD_ADMIN_PASSWORD}/${ETHERPAD_ADMIN_PASSWORD}/g" \
    -e "s/\${LDAP_SCHEMA}/${LDAP_SCHEMA}/g" \
    -e "s/\${LDAP_HOST}/${LDAP_HOST}/g" \
    -e "s/\${LDAP_PORT}/${LDAP_PORT}/g" \
    -e "s/\${LDAP_SEARCH_BASE}/${LDAP_SEARCH_BASE}/g" \
    -e "s/\${LDAP_ATTRIBUTE_UID}/${LDAP_ATTRIBUTE_UID}/g" \
    -e "s/\${LDAP_ATTRIBUTE_MAIL}/${LDAP_ATTRIBUTE_MAIL}/g" \
    -e "s/\${LDAP_ATTRIBUTE_NAME}/${LDAP_ATTRIBUTE_NAME}/g" \
    -e "s/\${LDAP_ATTRIBUTE_FIRSTNAME}/${LDAP_ATTRIBUTE_FIRSTNAME}/g" \
    -e "s/\${LDAP_ATTRIBUTE_LASTNAME}/${LDAP_ATTRIBUTE_LASTNAME}/g" \
    -e "s/\${LDAP_BIND_DN}/${LDAP_BIND_DN}/g" \
    -e "s/\${LDAP_BIND_PASSWORD}/${LDAP_BIND_PASSWORD}/g" \
    ./template/etherpad.json \
    > ./config/etherpad.json

  sed \
      -e "s/\${HTTP_SCHEMA}/${HTTP_SCHEMA}/g" \
      -e "s/\${ETHERPAD_HOSTNAME}/${ETHERPAD_HOSTNAME}/g" \
      ./template/etherpad-mypads-extra-html-javascript.html \
      > ./config/etherpad-mypads-extra-html-javascript.html

  # -- spacedeck ---------------------------------------------------------------

  sed \
    -e "s/\${HTTP_SCHEMA}/${HTTP_SCHEMA}/g" \
    -e "s/\${SPACES_HOSTNAME}/${SPACES_HOSTNAME}/g" \
    -e "s/\${SPACEDECK_HOSTNAME}/${SPACEDECK_HOSTNAME}/g" \
    ./template/nginx-spacedeck.conf \
    > ./config/nginx-spacedeck.conf

  sed \
    -e "s/\${SPACEDECK_INVITE_CODE}/${SPACEDECK_INVITE_CODE}/g" \
    -e "s/\${SPACEDECK_SESSION_KEY}/${SPACEDECK_SESSION_KEY}/g" \
    -e "s/\${SPACEDECK_EXPORT_API_SECRET}/${SPACEDECK_EXPORT_API_SECRET}/g" \
    -e "s/\${SPACEDECK_POSTGRES_PASSWORD}/${SPACEDECK_POSTGRES_PASSWORD}/g" \
    -e "s/\${LDAP_SCHEMA}/${LDAP_SCHEMA}/g" \
    -e "s/\${LDAP_HOST}/${LDAP_HOST}/g" \
    -e "s/\${LDAP_PORT}/${LDAP_PORT}/g" \
    -e "s/\${LDAP_SEARCH_BASE}/${LDAP_SEARCH_BASE}/g" \
    -e "s/\${LDAP_ATTRIBUTE_UID}/${LDAP_ATTRIBUTE_UID}/g" \
    -e "s/\${LDAP_ATTRIBUTE_MAIL}/${LDAP_ATTRIBUTE_MAIL}/g" \
    -e "s/\${LDAP_ATTRIBUTE_NAME}/${LDAP_ATTRIBUTE_NAME}/g" \
    -e "s/\${LDAP_BIND_DN}/${LDAP_BIND_DN}/g" \
    -e "s/\${LDAP_BIND_PASSWORD}/${LDAP_BIND_PASSWORD}/g" \
    ./template/spacedeck.json \
    > ./config/spacedeck.json

  # -- matrix-synapse ----------------------------------------------------------

  sed \
    -e "s/\${HTTP_SCHEMA}/${HTTP_SCHEMA}/g" \
    -e "s/\${MATRIX_BASEURL}/${MATRIX_BASEURL}/g" \
    ./template/nginx-matrix-synapse.conf \
    > ./config/nginx-matrix-synapse.conf

  sed \
    -e "s/\${HTTP_SCHEMA}/${HTTP_SCHEMA}/g" \
    -e "s/\${MATRIX_SERVERNAME}/${MATRIX_SERVERNAME}/g" \
    -e "s/\${MATRIX_BASEURL}/${MATRIX_BASEURL}/g" \
    -e "s/\${MATRIX_HTTP_LISTENERS}/${MATRIX_HTTP_LISTENERS:-"[client]"}/g" \
    -e "s/\${MATRIX_POSTGRES_PASSWORD}/${MATRIX_POSTGRES_PASSWORD}/g" \
    -e "s/\${LDAP_SCHEMA}/${LDAP_SCHEMA}/g" \
    -e "s/\${LDAP_HOST}/${LDAP_HOST}/g" \
    -e "s/\${LDAP_PORT}/${LDAP_PORT}/g" \
    -e "s/\${LDAP_STARTTLS}/${LDAP_STARTTLS}/g" \
    -e "s/\${LDAP_SEARCH_BASE}/${LDAP_SEARCH_BASE}/g" \
    -e "s/\${LDAP_ATTRIBUTE_UID}/${LDAP_ATTRIBUTE_UID}/g" \
    -e "s/\${LDAP_ATTRIBUTE_MAIL}/${LDAP_ATTRIBUTE_MAIL}/g" \
    -e "s/\${LDAP_ATTRIBUTE_NAME}/${LDAP_ATTRIBUTE_NAME}/g" \
    -e "s/\${LDAP_BIND_DN}/${LDAP_BIND_DN}/g" \
    -e "s/\${LDAP_BIND_PASSWORD}/${LDAP_BIND_PASSWORD}/g" \
    -e "s/\${MATRIX_REGISTRATION_SECRET}/${MATRIX_REGISTRATION_SECRET}/g" \
    -e "s/\${MATRIX_MACAROON_SECRET_KEY}/${MATRIX_MACAROON_SECRET_KEY}/g" \
    -e "s/\${MATRIX_FORM_SECRET}/${MATRIX_FORM_SECRET}/g" \
    -e "s/\${COTURN_LISTENING_PORT}/${COTURN_LISTENING_PORT:-3478}/g" \
    -e "s/\${COTURN_TLS_LISTENING_PORT}/${COTURN_TLS_LISTENING_PORT:-5349}/g" \
    -e "s/\${COTURN_ALT_LISTENING_PORT}/${COTURN_ALT_LISTENING_PORT:-0}/g" \
    -e "s/\${COTURN_ALT_TLS_LISTENING_PORT}/${COTURN_ALT_TLS_LISTENING_PORT:-0}/g" \
    -e "s/\${COTURN_REALM}/${COTURN_REALM}/g" \
    -e "s/\${COTURN_STATIC_AUTH_SECRET}/${COTURN_STATIC_AUTH_SECRET}/g" \
    ./template/matrix-synapse.yaml \
    > ./config/matrix-synapse.yaml

  # -- element-web -------------------------------------------------------------

  sed \
    -e "s/\${HTTP_SCHEMA}/${HTTP_SCHEMA}/g" \
    -e "s/\${MATRIX_BASEURL}/${MATRIX_BASEURL}/g" \
    -e "s/\${MATRIX_SERVERNAME}/${MATRIX_SERVERNAME}/g" \
    ./template/element.json \
    > ./config/element.json

  # -- coturn ------------------------------------------------------------------

  sed \
    -e "s/\${COTURN_LISTENING_PORT}/${COTURN_LISTENING_PORT:-3478}/g" \
    -e "s/\${COTURN_TLS_LISTENING_PORT}/${COTURN_TLS_LISTENING_PORT:-5349}/g" \
    -e "s/\${COTURN_ALT_LISTENING_PORT}/${COTURN_ALT_LISTENING_PORT:-0}/g" \
    -e "s/\${COTURN_ALT_TLS_LISTENING_PORT}/${COTURN_ALT_TLS_LISTENING_PORT:-0}/g" \
    -e "s/\${COTURN_MIN_PORT}/${COTURN_MIN_PORT:-49152}/g" \
    -e "s/\${COTURN_MAX_PORT}/${COTURN_MAX_PORT:-65535}/g" \
    -e "s/\${COTURN_REALM}/${COTURN_REALM}/g" \
    -e "s/\${COTURN_STATIC_AUTH_SECRET}/${COTURN_STATIC_AUTH_SECRET}/g" \
    ./template/coturn-turnserver.conf \
    > ./config/coturn-turnserver.conf

  # -- medienhaus-spaces -------------------------------------------------------

  sed \
    -e "s/\${SPACES_APP_PREFIX}/${SPACES_APP_PREFIX}/g" \
    -e "s/\${HTTP_SCHEMA}/${HTTP_SCHEMA}/g" \
    -e "s/\${MATRIX_BASEURL}/${MATRIX_BASEURL}/g" \
    -e "s/\${SPACES_HOSTNAME}/${SPACES_HOSTNAME}/g" \
    -e "s/\${ETHERPAD_HOSTNAME}/${ETHERPAD_HOSTNAME}/g" \
    -e "s/\${SPACEDECK_HOSTNAME}/${SPACEDECK_HOSTNAME}/g" \
    ./template/medienhaus-spaces.config.js \
    > ./config/medienhaus-spaces.config.js

  cp \
    ./template/element-medienhaus-spaces.json \
    ./config/element-medienhaus-spaces.json

}

# -- configure medienhaus-api --------------------------------------------------

configure_api() {
  sed \
    -e "s/\${MEDIENHAUS_ADMIN_USER_ID}/${MEDIENHAUS_ADMIN_USER_ID}/g" \
    -e "s/\${MATRIX_SERVERNAME}/${MATRIX_SERVERNAME}/g" \
    -e "s/\${MEDIENHAUS_ADMIN_ACCESS_TOKEN}/${MEDIENHAUS_ADMIN_ACCESS_TOKEN}/g" \
    -e "s/\${MEDIENHAUS_ROOT_CONTEXT_SPACE_ID}/${MEDIENHAUS_ROOT_CONTEXT_SPACE_ID}/g" \
    ./template/medienhaus-api.config.js \
    > ./config/medienhaus-api.config.js
}

# -- configure medienhaus-cms --------------------------------------------------

configure_cms() {
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
}

# -- show help / print usage information ---------------------------------------

show_help() {
cat << EOF

-- envsubst for services and medienhaus-spaces (default) --

$0


-- envsubst for services and medienhaus-spaces and medienhaus-api --

$0 --api


-- envsubst for services and medienhaus-spaces and medienhaus-cms --

$0 --cms


-- envsubst for services and medienhaus-* (all of the above) --

$0 --all

EOF
}

# -- check command-line arguments ----------------------------------------------

if [[ $# -eq 0 ]]; then
  configure_services
  printf "\n-- %s --\n\n" "$0: finished successfully"
  exit
else
  while [[ $# -gt 0 ]]; do
    case $1 in
      --api)
        configure_services
        configure_api
        printf "\n-- %s --\n\n" "$0 $1: finished successfully"
        exit
        ;;
      --cms)
        configure_services
        configure_cms
        printf "\n-- %s --\n\n" "$0 $1: finished successfully"
        exit
        ;;
      --all)
        configure_services
        configure_api
        configure_cms
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
