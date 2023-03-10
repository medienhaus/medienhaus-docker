<img src="./public/favicon.svg" width="70" />

### medienhaus/

Customizable, modular, free and open-source environment for decentralized, distributed communication and collaboration without third-party dependencies.

[Website](https://medienhaus.dev/) — [Twitter](https://twitter.com/medienhaus_)

<br>

# medienhaus-docker

This repository contains our Docker composition for a containerized runtime environment of [medienhaus-spaces](https://github.com/medienhaus/medienhaus-spaces/) including [synapse](https://github.com/matrix-org/synapse/), [element-web](https://github.com/vector-im/element-web/), [etherpad-lite](https://github.com/ether/etherpad-lite/), [spacedeck-open](https://github.com/arillo/spacedeck-open/), [openldap](https://github.com/osixia/docker-openldap/), and [ldap-user-manager](https://github.com/wheelybird/ldap-user-manager/).

## Instructions

1. fetch contents of submodules
   <br>
   ```
   git submodule update --init --remote
   ```

2. create and edit `.env` file
   <br>
   ```
   cp .env.example .env
   ```
   ```
   ${VISUAL:-${EDITOR:-vim}} .env
   ```

3. create and edit `docker-compose.yml` file
   <br>
   ```
   cp docker-compose.example.yml docker-compose.yml
   ```
   ```
   ${VISUAL:-${EDITOR:-vim}} docker-compose.yml
   ```

4. create and edit `config/medienhaus-spaces.config.yml` file
   <br>
   ```
   cp config/medienhaus-spaces.config.example.js config/medienhaus-spaces.config.js
   ```
   ```
   ${VISUAL:-${EDITOR:-vim}} config/medienhaus-spaces.config.js
   ```

5. generate `config/medienhaus-spaces.config.yml` file from template
   <br>
   ```
   docker run --env-file .env --mount type=bind,src="$(pwd)/config",dst="/config" --rm busybox \
     sh -c ' \
       sed \
         -e "s/\${SPACES_HOSTNAME}/${SPACES_HOSTNAME}/g"
         -e "s/\${MATRIX_POSTGRES_PASSWORD}/${MATRIX_POSTGRES_PASSWORD}/g" \
         -e "s/\${LDAP_BIND_PASSWORD}/${LDAP_BIND_PASSWORD}/g" \
         -e "s/\${MATRIX_REGISTRATION_SECRET}/${MATRIX_REGISTRATION_SECRET}/g" \
         -e "s/\${MATRIX_MACAROON_SECRET_KEY}/${MATRIX_MACAROON_SECRET_KEY}/g"\
         -e "s/\${MATRIX_FORM_SECRET}/${MATRIX_FORM_SECRET}/g" \
       /config/matrix-synapse.yaml.template > /config/matrix-synapse.yaml \
     '
   ```

6. start docker composition
   <br>
   ```
   docker-compose up -d --build --no-deps
   ```

7. initialize `openldap` directory via: http://openldap.localhost/setup/
   - password: `change_me` *(configured via `.env`)*
   - run ldap setup *(follow instructions)*
   - create admin account *(all fields required)*

8. set up `openldap` account(s) via: http://openldap.localhost/log_in/
   - username: *# set in previous step*
   - password: *# set in previous step*
   - create user account *(all fields required)*

9. initialize `medienhaus-spaces` root context via: http://localhost/login/
   - username: *# set in previous step*
   - password: *# set in previous step*
   - create root context *(follow instructions)*

10. configure/un-comment root context in `.env` file *(at the very bottom)*
   <br>
   ```
   ${VISUAL:-${EDITOR:-vim}} .env
   ```

## URLs / Links for default localhost setup

| Application / Service | URL / Link |
| --- | --- |
| `medienhaus-spaces` | http://localhost/ |
| `matrix-synapse` | http://matrix.localhost:8008/ |
| `element-web` | http://element.localhost/ |
| `etherpad-lite` | http://write.localhost/ |
| `spacedeck-open` | http://sketch.localhost/ |
| `traefik` | http://localhost:8080/ |
