<img src="./public/favicon.svg" width="70" />

### medienhaus/

Customizable, modular, free and open-source environment for decentralized, distributed communication and collaboration without third-party dependencies.

[Website](https://medienhaus.dev/) — [Twitter](https://twitter.com/medienhaus_)

<br>

# medienhaus-docker

This repository contains our Docker composition for a containerized runtime environment of [medienhaus-spaces](https://github.com/medienhaus/medienhaus-spaces/) including [synapse](https://github.com/matrix-org/synapse/), [element-web](https://github.com/vector-im/element-web/), [etherpad-lite](https://github.com/ether/etherpad-lite/), [spacedeck-open](https://github.com/arillo/spacedeck-open/), [openldap](https://github.com/osixia/docker-openldap/), and [ldap-user-manager](https://github.com/wheelybird/ldap-user-manager/).

## Instructions

1. `git submodule update --init --remote`
2. `cp docker-compose.example.yml docker-compose.yml`
3. `${VISUAL:-${EDITOR:-vim}} docker-compose.yml`
4. `docker-compose up -d --build --no-deps`
5. initialize `openldap` directory via: http://openldap.localhost/setup/
   - password: `change_me`
   - run ldap setup (follow instructions)
   - create admin account (all fields required)
6. set up `openldap` account(s) via: http://openldap.localhost/log_in/
   - username: *# set in step 3*
   - password: *# set in step 3*
   - create user account (all fields required)
7. happy hacking!

## URLs / Links

| Application / Service | URL / Link |
| --- | --- |
| `medienhaus-spaces` | http://localhost/ |
| `etherpad-lite` | http://write.localhost/ |
| `spacedeck-open` | http://sketch.localhost/ |
| `synapse` | http://matrix.localhost:8008/ |
| `element-web` | http://element.localhost/ |
| `traefik` | http://localhost:8080/ |
