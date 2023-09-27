<img src="./public/favicon.svg" width="70" />

### medienhaus/

Customizable, modular, free and open-source environment for decentralized, distributed communication and collaboration without third-party dependencies.

[Website](https://medienhaus.dev/) — [Twitter](https://twitter.com/medienhaus_)

<br>

# medienhaus-docker

This repository contains our Docker composition for a containerized runtime environment of [medienhaus-spaces](https://github.com/medienhaus/medienhaus-spaces/) + [medienhaus-api](https://github.com/medienhaus/medienhaus-api/) + [medienhaus-cms](https://github.com/medienhaus/medienhaus-cms/) including [matrix-synapse](https://github.com/matrix-org/synapse/), [element-web](https://github.com/vector-im/element-web/), [etherpad-lite](https://github.com/ether/etherpad-lite/), [spacedeck-open](https://github.com/medienhaus/spacedeck-open/), and [lldap](https://github.com/lldap/lldap).

## Instructions

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
   ⚠️ For *production*, please use [`docker-compose.websecure.yml`](docker-compose.websecure.yml) with secured `https` context!
   ```
   cp docker-compose.websecure.yml docker-compose.yml
   ```

4. create config files from `template/*` files and `.env` variables
   <br>
   ```
   chmod +x ./scripts/envsubst.sh
   ```
   ```
   ./scripts/envsubst.sh
   ```

5. start docker composition
   <br>
   ```
   docker compose up -d
   ```
   ⚠️ For *production*, please use [`docker-init.websecure.yml`](docker-init.websecure.yml) with secured `https` context!

6. create `medienhaus-api` matrix account and create config files from `template/*`
   <br>
   ```
   chmod +x ./scripts/init-medienhaus-api.sh
   ```
   💬 This script uses `MEDIENHAUS_API_USER_ID` and `MEDIENHAUS_API_PASSWORD` from `.env`!
   ```
   ./scripts/init-medienhaus-api.sh
   ```

7. re-start docker composition, include `medienhaus-api` and `medienhaus-cms` services
   <br>
   ```
   docker compose up -d
   ```
   ⚠️ For *production*, please use [`docker-compose.websecure.yml`](docker-compose.websecure.yml) with secured `https` context!

8. set up `lldap` user account(s) via: http://ldap.localhost/
   - username: `admin` *(configured via `.env`)*
   - password: `change_me` *(configured via `.env`)*
   - create user account(s)

9. initialize etherpad `mypads` via: http://etherpad.localhost/mypads/?/admin
   - username: `admin` *(configured via `config/etherpad.json`)*
   - password: `change_me` *(configured via `.env`)*

10. configure etherpad `mypads` via: http://etherpad.localhost/mypads/?/admin
    - copy content from the `config/etherpad-mypads-extra-html-javascript.html` file
    - paste the copied content into the **“Extra HTML for &lt;head&gt;”** input/textarea field
    - click the **“Authentication method”** dropdown and select **“LDAP”** for authentication
    - copy content from the `config/etherpad-mypads-ldap-configuration.json` file
    - paste the copied content into the **“LDAP settings”** input/textarea field

11. open the `medienhaus-spaces` application and log in via: http://localhost/login
    - username: *(configured via `lldap`)*
    - password: *(configured via `lldap`)*

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
