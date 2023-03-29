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

3. create, edit, and understand `docker-compose.yml` file
   <br>
   ```
   cp docker-compose.example.yml docker-compose.yml
   ```
   ```
   ${VISUAL:-${EDITOR:-vim}} docker-compose.yml
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

6. initialize `openldap` directory via: http://openldap.localhost/setup/
   - password: `change_me` *(configured via `.env`)*
   - run ldap setup *(follow instructions)*
   - create admin account *(all fields required)*

7. set up `openldap` account(s) via: http://openldap.localhost/log_in/
   - username: *# set in previous step*
   - password: *# set in previous step*
   - create user account *(all fields required)*

8. initialize `medienhaus-spaces` root context via: http://localhost/login/
   - username: *# set in previous step*
   - password: *# set in previous step*
   - create root context *(follow instructions)*

9. configure/un-comment root context in `.env` file *(at the very bottom)*
   <br>
   ```
   ${VISUAL:-${EDITOR:-vim}} .env
   ```

10. substitute root context variable in `config/*` files via definition in `.env`
    <br>
    ```
    docker compose -f docker-post-compose.yml up
    ```

11. initialize `mypads` via: http://write.localhost/mypads/?/admin
    - username: `admin` *(configured via `config/etherpad.json`)*
    - password: `change_me` *(configured via `.env`)*

12. configure `mypads` via: http://write.localhost/mypads/?/admin
    - copy/paste `config/etherpad-mypads-extra-html-javascript.html` into “Extra HTML for &lt;head&gt;”
    - click the “Authentication method” dropdown menu and select `LDAP` as authentication method
    - copy/paste `config/etherpad-mypads-ldap-configuration.json` into “LDAP settings”

<br>

## URLs / Links for default localhost setup

| Application / Service | URL / Link |
| --- | --- |
| `medienhaus-spaces` | http://localhost/ |
| `matrix-synapse` | http://matrix.localhost:8008/ |
| `element-web` | http://element.localhost/ |
| `etherpad-lite` | http://write.localhost/ |
| `spacedeck-open` | http://sketch.localhost/ |
| `traefik` | http://localhost:8080/ |
