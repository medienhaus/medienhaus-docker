<img src="./public/favicon.svg" width="70" />

### medienhaus/

Customizable, modular, free and open-source environment for decentralized, distributed communication and collaboration without third-party dependencies.

[Website](https://medienhaus.dev/) — [Twitter](https://twitter.com/medienhaus_)

<br>

# medienhaus-docker

This repository contains our Docker composition for a containerized runtime environment of [medienhaus-spaces](https://github.com/medienhaus/medienhaus-spaces/) + [medienhaus-api](https://github.com/medienhaus/medienhaus-api/) + [medienhaus-cms](https://github.com/medienhaus/medienhaus-cms/) including [matrix-synapse](https://github.com/matrix-org/synapse/), [element-web](https://github.com/vector-im/element-web/), [etherpad-lite](https://github.com/ether/etherpad-lite/), [spacedeck-open](https://github.com/medienhaus/spacedeck-open/), and [lldap](https://github.com/lldap/lldap).

## Instructions

0. `git clone` the `medienhaus-docker` repository and change directory
   <br>
   ```
   git clone https://github.com/medienhaus/medienhaus-docker.git && cd medienhaus-docker/
   ```

1. fetch contents of submodules
   <br>
   ```
   git submodule update --init
   ```

2. create `.env` file from example
   <br>
   ```
   cp .env.example .env
   ```
   ```
   ${VISUAL:-${EDITOR:-vim}} .env
   ```
   ⚠️ For *production*, please change **at least** the following environment variables!
      - `ADMIN_CONTACT_LETSENCRYPT` for issuing SSL certificates via `traefik`
      - `BASE_URL` to your *fully qualified domain name*, e.g. `spaces.example.org`
      - `HTTP_SCHEMA` to `https` for enabling https context for all services
      - `change_me` to generated **long**, **random**, and **secure** passwords/secrets

   💭 Generate **long**, **random**, and **secure** passwords/secrets via `openssl` command:
   ```
   openssl rand -hex 32
   ```

3. create `docker-compose.yml` file from example
   <br>
   ```
   cp docker-compose.example.yml docker-compose.yml
   ```
   ⚠️ For *production*, please use [`docker-compose.example.websecure.yml`](docker-compose.example.websecure.yml) with secured `https` context!
   ```
   cp docker-compose.example.websecure.yml docker-compose.yml
   ```

4. create config files from `template/*` files and `.env` variables
   <br>
   ```
   sh ./scripts/envsubst.sh
   ```
   🧩 Configure `MEDIENHAUS_ROOT_CONTEXT_SPACE_ID` in `.env` if skipping the [*optional*](#optional-instructions-for-medienhaus-api-and-medienhaus-cms) section!

5. start docker composition
   <br>
   ```
   docker compose up -d
   ```

6. set up `lldap` user account(s) via: http://ldap.localhost/
   - username: `admin` *(configured via `.env`)*
   - password: `change_me` *(configured via `.env`)*
   - create user account(s)

7. open the `medienhaus-spaces` application and log in via: http://localhost/login
   - username: *(configured via `lldap`)*
   - password: *(configured via `lldap`)*

<br>

#### OPTIONAL: Instructions for `medienhaus-api` and `medienhaus-cms`

8. create `medienhaus-api` matrix account and create config files from `template/*`
   <br>
   ```
   sh ./scripts/init-medienhaus-api.sh
   ```
   💬 This script uses `MEDIENHAUS_ADMIN_USER_ID` and `MEDIENHAUS_ADMIN_PASSWORD` from `.env`!

9. update config files && re-start docker composition, including `medienhaus-*` services
   <br>
   ```
   sh ./scripts/envsubst.sh --medienhaus
   ```
   ```
   docker compose up -d --force-recreate
   ```

<br>

## URLs / Links for default localhost setup

| Application / Service | URL / Link |
| --- | --- |
| `medienhaus-spaces` | http://localhost/ |
| `medienhaus-api` | http://api.localhost/ |
| `medienhaus-cms` | http://cms.localhost/ |
| `matrix-synapse` | http://matrix.localhost/ |
| `element-web` | http://element.localhost/ |
| `etherpad-lite` | http://etherpad.localhost/ |
| `spacedeck-open` | http://spacedeck.localhost/ |
| `lldap` | http://ldap.localhost/ |
