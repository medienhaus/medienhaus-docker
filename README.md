<img src="./public/favicon.svg" width="70" />

### medienhaus/

Customizable, modular, free and open-source environment for decentralized, distributed communication and collaboration without third-party dependencies.

[Website](https://medienhaus.dev/) — [Twitter](https://twitter.com/medienhaus_)

<br>

# medienhaus-docker

This repository contains our Docker composition for a containerized runtime environment of [medienhaus-spaces](https://github.com/medienhaus/medienhaus-spaces/) including [synapse](https://github.com/matrix-org/synapse/), [element-web](https://github.com/vector-im/element-web/), [etherpad-lite](https://github.com/ether/etherpad-lite/), [spacedeck-open](https://github.com/arillo/spacedeck-open/), [openldap](https://github.com/osixia/docker-openldap/), and [ldap-user-manager](https://github.com/wheelybird/ldap-user-manager/).

## Instructions

1. fetch contents of submodules
   - `git submodule update --init --remote`
2. create and edit `docker-compose.yml` file
   - `cp docker-compose.example.yml docker-compose.yml`
   - `${VISUAL:-${EDITOR:-vim}} docker-compose.yml`
3. create and edit `config/medienhaus-spaces.config.yml` file
   - `cp config/medienhaus-spaces.config.example.js config/medienhaus-spaces.config.js`
   - `${VISUAL:-${EDITOR:-vim}} config/medienhaus-spaces.config.js`
4. start docker composition
   - `docker-compose up -d --build --no-deps`
5. initialize `openldap` directory via: http://openldap.localhost/setup/
   - password: `change_me` (configured via `.env`)
   - run ldap setup (follow instructions)
   - create admin account *(all fields required)*
6. set up `openldap` account(s) via: http://openldap.localhost/log_in/
   - username: *# set in step 3*
   - password: *# set in step 3*
   - create user account *(all fields required)*
7. happy hacking!

## URLs / Links

| Application / Service | URL / Link |
| --- | --- |
| `medienhaus-spaces` | http://localhost/ |
| `matrix-synapse` | http://matrix.localhost:8008/ |
| `element-web` | http://element.localhost/ |
| `etherpad-lite` | http://write.localhost/ |
| `spacedeck-open` | http://sketch.localhost/ |
| `traefik` | http://localhost:8080/ |
