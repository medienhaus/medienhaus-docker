<img src="./public/favicon.svg" width="70" />

### medienhaus/

Customizable, modular, free and open-source environment for decentralized, distributed communication and collaboration without third-party dependencies.

[Website](https://medienhaus.dev/) — [Twitter](https://twitter.com/medienhaus_)

<br>

# medienhaus-docker

This repository contains our Docker composition for a containerized runtime environment of [medienhaus-spaces](https://github.com/medienhaus/medienhaus-spaces/) including [synapse](https://github.com/matrix-org/synapse/), [element-web](https://github.com/vector-im/element-web/), [etherpad-lite](https://github.com/ether/etherpad-lite/), [spacedeck-open](https://github.com/arillo/spacedeck-open/), [openldap](https://github.com/osixia/docker-openldap/), and [ldap-user-manager](https://github.com/wheelybird/ldap-user-manager/).

## Instructions

1. `git submodule update --init --remote`
2. `docker-compose up -d --build --no-deps`
3. initialize `openldap` via: http://openldap.localhost/setup/
   - username: `admin`
   - password: `change_me`
   - run ldap setup (follow instructions)
   - create user account (all fields required)
4. happy hacking

## URLs / Links

| Application / Service | URL / Link |
| --- | --- |
| `medienhaus-spaces` | http://localhost/ |
| `etherpad-lite` | http://write.localhost/ |
| `spacedeck-open` | http://sketch.localhost/ |
| `matrix / `synapse` | http://matrix.localhost:8008/ |
| `element-web` | http://element.localhost/ |
| `traefik` dashboard | http://localhost:8080/ |
