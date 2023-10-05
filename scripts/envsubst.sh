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

# -- import variables from .env ------------------------------------------------

set -o allexport && source .env && set +o allexport

# -- configure services --------------------------------------------------------

configure_services() {

  # -- configure etherpad ------------------------------------------------------

  sed \
    -e "s/\${HTTP_SCHEMA}/${HTTP_SCHEMA}/g" \
    -e "s/\${SPACES_HOSTNAME}/${SPACES_HOSTNAME}/g" \
    ./template/nginx-etherpad.conf \
    > ./config/nginx-etherpad.conf

  sed \
    -e "s/\${ETHERPAD_POSTGRES_PASSWORD}/${ETHERPAD_POSTGRES_PASSWORD}/g" \
    -e "s/\${ETHERPAD_ADMIN_PASSWORD}/${ETHERPAD_ADMIN_PASSWORD}/g" \
    ./template/etherpad.json \
    > ./config/etherpad.json

  #sed \
  #    -e "s/\${HTTP_SCHEMA}/${HTTP_SCHEMA}/g" \
  #    -e "s/\${SPACES_HOSTNAME}/${SPACES_HOSTNAME}/g" \
  #    ./template/etherpad-mypads-extra-html-javascript.html \
  #    > ./config/etherpad-mypads-extra-html-javascript.html

  #sed \
  #    -e "s/\${LDAP_SCHEMA}/${LDAP_SCHEMA}/g" \
  #    -e "s/\${LDAP_HOST}/${LDAP_HOST}/g" \
  #    -e "s/\${LDAP_PORT}/${LDAP_PORT}/g" \
  #    -e "s/\${LDAP_SEARCH_BASE}/${LDAP_SEARCH_BASE}/g" \
  #    -e "s/\${LDAP_ATTRIBUTE_UID}/${LDAP_ATTRIBUTE_UID}/g" \
  #    -e "s/\${LDAP_ATTRIBUTE_MAIL}/${LDAP_ATTRIBUTE_MAIL}/g" \
  #    -e "s/\${LDAP_ATTRIBUTE_NAME}/${LDAP_ATTRIBUTE_NAME}/g" \
  #    -e "s/\${LDAP_ATTRIBUTE_FIRSTNAME}/${LDAP_ATTRIBUTE_FIRSTNAME}/g" \
  #    -e "s/\${LDAP_ATTRIBUTE_LASTNAME}/${LDAP_ATTRIBUTE_LASTNAME}/g" \
  #    -e "s/\${LDAP_BIND_DN}/${LDAP_BIND_DN}/g" \
  #    -e "s/\${LDAP_BIND_PASSWORD}/${LDAP_BIND_PASSWORD}/g" \
  #    ./template/etherpad-mypads-ldap-configuration.json \
  #    > ./config/etherpad-mypads-ldap-configuration.json

  sed \
    -e "s/\${HTTP_SCHEMA}/${HTTP_SCHEMA}/g" \
    -e "s/\${SPACES_HOSTNAME}/${SPACES_HOSTNAME}/g" \
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
    ./template/etherpad-mypads.configuration.js \
    > ./config/etherpad-mypads.configuration.js

  # -- configure spacedeck -----------------------------------------------------

  sed \
    -e "s/\${HTTP_SCHEMA}/${HTTP_SCHEMA}/g" \
    -e "s/\${SPACES_HOSTNAME}/${SPACES_HOSTNAME}/g" \
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

  # -- configure matrix-synapse ------------------------------------------------

  sed \
    -e "s/\${HTTP_SCHEMA}/${HTTP_SCHEMA}/g" \
    -e "s/\${MATRIX_BASEURL}/${MATRIX_BASEURL}/g" \
    ./template/nginx-matrix-synapse.conf \
    > ./config/nginx-matrix-synapse.conf

  sed \
    -e "s/\${HTTP_SCHEMA}/${HTTP_SCHEMA}/g" \
    -e "s/\${MATRIX_SERVERNAME}/${MATRIX_SERVERNAME}/g" \
    -e "s/\${MATRIX_BASEURL}/${MATRIX_BASEURL}/g" \
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
    ./template/matrix-synapse.yaml \
    > ./config/matrix-synapse.yaml

  # -- configure element-web ---------------------------------------------------

  sed \
    -e "s/\${HTTP_SCHEMA}/${HTTP_SCHEMA}/g" \
    -e "s/\${MATRIX_BASEURL}/${MATRIX_BASEURL}/g" \
    -e "s/\${MATRIX_SERVERNAME}/${MATRIX_SERVERNAME}/g" \
    ./template/element.json \
    > ./config/element.json

  # -- configure medienhaus-spaces (without root_context_space_id) -------------

  sed \
    -e "s/\${SPACES_APP_PREFIX}/${SPACES_APP_PREFIX}/g" \
    -e "s/\${HTTP_SCHEMA}/${HTTP_SCHEMA}/g" \
    -e "s/\${MATRIX_BASEURL}/${MATRIX_BASEURL}/g" \
    -e "s/\${SPACES_HOSTNAME}/${SPACES_HOSTNAME}/g" \
    ./template/medienhaus-spaces.config.js \
    > ./config/medienhaus-spaces.config.js

  cp \
    ./template/element-medienhaus-spaces.json \
    ./config/element-medienhaus-spaces.json

}

# -- configure medienhaus-* ----------------------------------------------------
configure_medienhaus() {

  # -- configure medienhaus-api ------------------------------------------------

  sed \
    -e "s/\${MEDIENHAUS_ADMIN_USER_ID}/${MEDIENHAUS_ADMIN_USER_ID}/g" \
    -e "s/\${MATRIX_SERVERNAME}/${MATRIX_SERVERNAME}/g" \
    -e "s/\${MEDIENHAUS_ADMIN_ACCESS_TOKEN}/${MEDIENHAUS_ADMIN_ACCESS_TOKEN}/g" \
    -e "s/\${MEDIENHAUS_ROOT_CONTEXT_SPACE_ID}/${MEDIENHAUS_ROOT_CONTEXT_SPACE_ID}/g" \
    ./template/medienhaus-api.config.js \
    > ./config/medienhaus-api.config.js

  # -- configure medienhaus-cms ------------------------------------------------

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

  # -- configure medienhaus-spaces (with root_context_space_id) ----------------

  sed \
    -e "s/\${SPACES_APP_PREFIX}/${SPACES_APP_PREFIX}/g" \
    -e "s/\${HTTP_SCHEMA}/${HTTP_SCHEMA}/g" \
    -e "s/\${MATRIX_BASEURL}/${MATRIX_BASEURL}/g" \
    -e "s/\${SPACES_HOSTNAME}/${SPACES_HOSTNAME}/g" \
    -e "s/\${MEDIENHAUS_ROOT_CONTEXT_SPACE_ID}/${MEDIENHAUS_ROOT_CONTEXT_SPACE_ID}/g" \
    ./template/medienhaus-spaces.config.js \
    > ./config/medienhaus-spaces.config.js

  #cp \
  #  ./template/element-medienhaus-spaces.json \
  #  ./config/element-medienhaus-spaces.json

}

# -- check command-line arguments ----------------------------------------------

if [[ $# -eq 0 ]] || [[ $1 != "--services" && $1 != "--medienhaus" ]]; then
  printf "\n-- %s -- %s --\n\n" "$0: exited" "nothing done !!"
  printf "# %s\n" "envsubst for services (matrix-synapse, etherpad-lite, spacedeck, lldap, etc.)"
  printf "%s\n\n" "$0 --services"
  printf "# %s\n" "envsubst for medienhaus-* (medienhaus-spaces, medienhaus-api, medienhaus-cms)"
  printf "%s\n\n" "$0 --medienhaus"
  printf "# %s\n" "envsubst for services && medienhaus-*"
  printf "%s\n\n" "$0 --services --medienhaus"
  exit 1
else
  while [[ $# -gt 0 ]]; do
    case $1 in
      --services)
        configure_services
        printf "\n-- %s --\n" "$0 $1: finished successfully"
        shift
        ;;
      --medienhaus)
        configure_medienhaus
        printf "\n-- %s --\n" "$0 $1: finished successfully"
        shift
        ;;
    esac
  done
  printf "\n"
  exit
fi
