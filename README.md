# Master-Bot Database Infrastructure (GitHub Codespaces)

This repository provisions a dedicated, multi-process data backend for [galnir/Master-Bot](https://github.com). It runs completely within GitHub Codespaces using a pure, native `ubuntu:latest` base layer. It exposes a Primary PostgreSQL database, an isolated Prisma Shadow database, and a Redis cache on independent public network ports.

## Architecture Topology

                  ┌───────────────────────────────────────────────┐
                  │          GITHUB CODESPACES CONTAINER          │
                  │               (ubuntu:latest)                 │
                  └───────┬───────────────┬───────────────┬───────┘
                          │               │               │
                          ▼               ▼               ▼
                   ┌────────────┐  ┌────────────┐  ┌────────────┐
                   │  db_main   │  │ db_shadow  │  │   redis    │
                   │ (Container)│  │ (Container)│  │ (Container)│
                   └──────┬─────┘  └──────┬─────┘  └──────┬─────┘
                          │               │               │
  Internal Port:         5432            5432            6379
  Forwarded Host Port:   5432            5433            6379
  GitHub Proxy Port:     443             443             443

## Infrastructure Components

1. **Primary Database (`db_main`)**: Handles active application runtime data. Exposes local port `5432`.
2. **Prisma Shadow Database (`db_shadow`)**: Dedicated, completely separate server instance strictly used by Prisma ORM to safely calculate migrations. Exposes local port `5433`.
3. **Shared Cache (`redis`)**: High-performance key-value memory layer required by the bot. Exposes local port `6379`.
## File Manifest

### `.devcontainer/devcontainer.json`
Acts as the configuration orchestrator. It forces the setup to build over Docker Compose, passes through the required user secrets, maps default labels, and runs the GitHub CLI (`gh`) to automatically set the forwarded ports' visibility to **Public** on startup.

### `docker-compose.yml`
Defines the multi-container topology. It mounts the host's Docker socket `/var/run/docker.sock` to enable Docker-in-Docker capabilities, configures data volume mapping for strict database persistence, and overrides standard container initialization loops.

### `.devcontainer/Dockerfile`
Implements the mandatory `ubuntu:latest` requirement. Installs system binaries including `curl`, `git`, `sudo`, `gnupg`, `docker.io`, `docker-compose`, and full PostgreSQL packages natively from standard distribution channels. It also fixes local git permission helper mappings globally.

### `.devcontainer/entrypoint.sh`
The custom runtime shell script. Deployed because an unprivileged `apt-get install` does not initialize physical database clusters on disk. It intercepts startup loops, verifies if a database volume is blank, triggers `initdb` when needed, opens up `listen_addresses = '*'`, appends wildcards to `pg_hba.conf`, and safely switches the postgres daemon thread to the container foreground.

---

## Runtime Variables Matrix

The infrastructure requires the following repository secrets to be set in your repository's **Settings -> Secrets and variables -> Codespaces**:

| Variable Key | Purpose | Default / Fallback |
| :--- | :--- | :--- |
| `DB_USER` | Operational superuser name for both engines | `postgres` |
| `DB_PASSWORD` | Secure authentication credential string | `postgres` |
| `DB_NAME` | Name of the primary core application schema | `master_bot` |

*Note: The shadow database server automatically generates its schema matching the pattern `${DB_NAME}_shadow`.*

---

## Deployment & Usage

### 1. Initial Launch
1. Ensure your repository secrets are saved in your GitHub settings.
2. Launch a new GitHub Codespace from your branch.
3. Wait for the compilation stages to finish. The ports view will open up, and the `postStartCommand` will automatically transition your endpoints to public visibility.

### 2. Copying Connection Strings
Navigate to the **Ports** tab inside the Codespace window and extract your explicit public host links. Combine them into your target `Master-Bot` application `.env` template format:

DATABASE_URL="postgresql://<USER>:<PASSWORD>@<YOUR-5432-HOST-URL>:443/<DB_NAME>?sslmode=require"
SHADOW_DB_URL="postgresql://<USER>:<PASSWORD>@<YOUR-5433-HOST-URL>:443/<DB_NAME>_shadow?sslmode=require"
REDIS_URL="redis://<YOUR-6379-HOST-URL>:443"

> **Critical Routing Reminder**: Because GitHub routes public ports over a secure HTTPS web proxy, you must connect external applications via port **`443`** instead of the container's native internal ports, and append the **`?sslmode=require`** flag to complete the SSL handshake successfully.
