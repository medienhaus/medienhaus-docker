<img src="./public/favicon.svg" width="70" />

### medienhaus/

Customizable, modular, free and open-source environment for decentralized, distributed communication and collaboration without third-party dependencies.

[Website](https://medienhaus.dev/) — [Twitter](https://twitter.com/medienhaus_)

<br>

# medienhaus-docker

This repository contains our Docker composition for a containerized runtime environment of [medienhaus-spaces](https://github.com/medienhaus/medienhaus-spaces/) including [matrix-synapse](https://github.com/matrix-org/synapse/), [element-web](https://github.com/vector-im/element-web/), [etherpad-lite](https://github.com/ether/etherpad-lite/), [spacedeck-open](https://github.com/medienhaus/spacedeck-open/), and [lldap](https://github.com/lldap/lldap).

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

3. create `docker-compose.yml` file
   <br>
   - for localhost with unsecured `http` context
   ```
   cp docker-compose.example.yml docker-compose.yml
   ```
   - for production with encrypted `https` context
   ```
   cp docker-compose.example.yml docker-compose.yml
   ```

4. substitute variables in `config/*` files via definitions in `.env`
   <br>
   ```
   docker compose -f docker-pre-compose.yml up
   ```

5. start docker composition
   <br>
   ```
   docker compose up -d --build --no-deps --remove-orphans
   ```

6. set up `lldap` account(s) via: http://ldap.localhost/
   - username: `admin` *(configured via `.env`)*
   - password: `change_me` *(configured via `.env`)*
   - create user account(s)

7. initialize `mypads` via: http://etherpad.localhost/mypads/?/admin
   - username: `admin` *(configured via `config/etherpad.json`)*
   - password: `change_me` *(configured via `.env`)*

8. configure `mypads` via: http://etherpad.localhost/mypads/?/admin
   - copy content from the `config/etherpad-mypads-extra-html-javascript.html` file
   - paste the copied content into the **“Extra HTML for &lt;head&gt;”** input/textarea field
   - click the **“Authentication method”** dropdown and select **“LDAP”** for authentication
   - copy content from the `config/etherpad-mypads-ldap-configuration.json` file
   - paste the copied content into the **“LDAP settings”** input/textarea field

9. now open `medienhaus-spaces` and log in via: http://localhost/login/
   - username: *# set in previous step*
   - password: *# set in previous step*
   - *explore and have fun*

<br>

## URLs / Links for default localhost setup

| Application / Service | URL / Link |
| --- | --- |
| `medienhaus-spaces` | http://localhost/ |
| `matrix-synapse` | http://matrix.localhost:8008/ |
| `element-web` | http://element.localhost/ |
| `etherpad-lite` | http://etherpad.localhost/ |
| `spacedeck-open` | http://spacedeck.localhost/ |
| `lldap` | http://ldap.localhost/ |
| `traefik` | http://localhost:8080/ |
