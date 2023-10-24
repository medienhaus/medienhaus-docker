<img src="./public/favicon.svg" width="70" />

### medienhaus/

Customizable, modular, free and open-source environment for decentralized, distributed communication and collaboration without third-party dependencies.

[Website](https://medienhaus.dev/) — [Mastodon](https://chaos.social/@medienhaus)

<br>

# medienhaus-docker

This repository contains our Docker composition for a containerized runtime environment of [medienhaus-spaces](https://github.com/medienhaus/medienhaus-spaces/) + [medienhaus-api](https://github.com/medienhaus/medienhaus-api/) + [medienhaus-cms](https://github.com/medienhaus/medienhaus-cms/) including [matrix-synapse](https://github.com/matrix-org/synapse/), [element-web](https://github.com/vector-im/element-web/), [etherpad-lite](https://github.com/ether/etherpad-lite/), [spacedeck-open](https://github.com/medienhaus/spacedeck-open/), and [lldap](https://github.com/lldap/lldap).

🧩 For *local development* of [medienhaus-spaces](https://github.com/medienhaus/medienhaus-spaces/), use the simplified [medienhaus-docker-dev](https://github.com/medienhaus/medienhaus-docker-dev/) composition.

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
   ⚠️ For *production*, please change **at least** the following environment variables❗️
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
   ⚠️ For *production*, please use [`docker-compose.example.websecure.yml`](docker-compose.example.websecure.yml) with secured `https` context❗️
   ```
   cp docker-compose.example.websecure.yml docker-compose.yml
   ```

4. create config files from `template/*` files and `.env` variables
   <br>
   ```
   sh ./scripts/envsubst.sh
   ```

5. start docker composition
   <br>
   ```
   docker compose up -d
   ```

6. create `matrix-synapse` account for `medienhaus-*`
   <br>
   ```
   sh ./scripts/init.sh
   ```
   <details>

   <summary>⚠️ For including <code>medienhaus-api</code> and/or <code>medienhaus-cms</code>, use these commands <strong>instead</strong>❗️</summary>

   <br>

   For including `medienhaus-api`, run the following:

   ```
   sh ./scripts/init.sh --api
   ```

   For including `medienhaus-cms`, run the following:

   ```
   sh ./scripts/init.sh --cms
   ```

   For including `medienhaus-api` and `medienhaus-cms`, run the following:

   ```
   sh ./scripts/init.sh --all
   ```

   The script can list these commands with the `--help` argument:

   ```
   sh ./scripts/init.sh --help
   ```

   </details>

<br>

7. re-create config files from `template/*` files and `.env` variables including `medienhaus-*` services
   <br>
   ```
   sh ./scripts/envsubst.sh
   ```
   <details>

   <br>

   <summary>⚠️ For including <code>medienhaus-api</code> and/or <code>medienhaus-cms</code>, use these commands <strong>instead</strong>❗️</summary>

   For including `medienhaus-api`, run the following:

   ```
   sh ./scripts/envsubst.sh --api
   ```

   For including `medienhaus-cms`, run the following:

   ```
   sh ./scripts/envsubst.sh --cms
   ```

   For including `medienhaus-api` and `medienhaus-cms`, run the following:

   ```
   sh ./scripts/envsubst.sh --all
   ```

   The script can list these commands with the `--help` argument:

   ```
   sh ./scripts/envsubst.sh --help
   ```

   </details>

<br>

8. re-start docker composition including `medienhaus-*` services
   <br>
   ```
   docker compose up -d
   ```

9. set up `lldap` user account(s) via: http://ldap.localhost/
   - username: `admin` *(configured via `.env`)*
   - password: `change_me` *(configured via `.env`)*
   - create user account(s)

10. open the `medienhaus-spaces` application and log in via: http://localhost/login
    - username: *(configured via `lldap`)*
    - password: *(configured via `lldap`)*

<br>

## Destructions — reset everything and start from scratch

```
docker compose down && \
rm -rf data/etherpad && \
rm -rf data/matrix-synapse && \
rm -rf data/spacedeck && \
cp .env.example .env && \
cp docker-compose.example.yml docker-compose.yml && \
sh scripts/envsubst.sh && \
docker compose up -d --build --force-recreate --wait && \
sh scripts/init.sh && \
sh scripts/envsubst.sh && \
docker compose up -d --build --force-recreate
```

💥 If you want to *TAKE ALL THE SHORTCUTS YOU CAN TAKE*, run `scripts/reset.sh`.

```
sh scripts/reset.sh
```

<details>

<br>

<summary>⚠️ For including <code>medienhaus-api</code> and/or <code>medienhaus-cms</code>, use these commands <strong>instead</strong>❗️</summary>

For including `medienhaus-api`, run the following:

```
sh ./scripts/reset.sh --api
```

For including `medienhaus-cms`, run the following:

```
sh ./scripts/reset.sh --cms
```

For including `medienhaus-api` and `medienhaus-cms`, run the following:

```
sh ./scripts/reset.sh --all
```

The script can list these commands with the `--help` argument:

```
sh ./scripts/reset.sh --help
```

</details>

🧩 For convenience reasons, manually created `lldap` accounts are not deleted.

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
