# Development Plan & Engineering Post-Mortem

## Phase 1: Architectural Evolution (Post-Mortem Log)

### Milestone 1: Multi-Database Resolution
* **Initial Concept**: Run a primary database and a shadow database inside a single PostgreSQL server process instance.
* **Failure Point**: Failed because PostgreSQL cannot natively map two individual database schemas to two separate external host network ports. Prisma ORM requires two distinct port definitions to bypass proxy routing conflicts over GitHub proxies.
* **Resolution**: Re-engineered to use two completely independent PostgreSQL server containers running side-by-side, separating traffic safely onto host ports `5432` and `5433`.

### Milestone 2: Feature & Registry Mitigation
* **Initial Concept**: Utilize default devcontainer image paths (`://microsoft.com...`) and devcontainer feature keys (`ghcr.io/devcontainers/features/postgres`).
* **Failure Point**: The underlying Codespaces build engine repeatedly hit fatal network lookup or registry permission blocks (`UnifiedContainersErrorFatalCreatingContainer`) when resolving feature layers over custom base images.
* **Resolution**: Completely eliminated the `features` block. Switched to installing PostgreSQL packages directly via native Ubuntu package managers within a local `Dockerfile`.
### Milestone 3: Base Image Manifest Alignment
* **Initial Concept**: Using the hyphenated `ubuntu-latest` configuration parameter directly inside the devcontainer image reference block.
* **Failure Point**: Failed with `No manifest found for docker.io/library/ubuntu-latest`. The string `ubuntu-latest` is valid only for GitHub Actions runners; the Docker engine requires an explicit colon format (`ubuntu:latest`).
* **Resolution**: Switched string definition format strictly to `ubuntu:latest`.

### Milestone 4: Storage Path & Binary Validation
* **Initial Concept**: Call raw binary execution parameters or file search flags via wildcards (`/etc/postgresql/*/main/`) during the raw container image compilation phase.
* **Failure Point**: Failed with directory non-existent errors. When `apt` downloads database packages, it does not initialize a cluster on disk. Volume binds overwrote target paths, leaving folders empty and causing execution lookups to fail (`exec: "postgres": executable file not found in $PATH`).
* **Resolution**: Implemented a dedicated `entrypoint.sh` script. This script defers directory verification and parameter string appends to the active container execution runtime phase, preventing empty directory initialization crashes.

---

## Phase 2: Next Implementation Milestones

### 1. Automation Expansion
* Implement automated configuration validation tests within a `postCreateCommand` loop to ensure ports respond prior to terminal handover.
* Integrate internal logging to capture health statuses for `db_main`, `db_shadow`, and `redis` simultaneously.

### 2. Application Workspace Integration
* Launch the companion application Codespace fork `PhantomNimbi/Master-Bot`.
* Bind the public infrastructure connection handles securely into the environment layers.
* Execute `pnpm prisma db push` to verify successful cross-container synchronization across the active secure network proxy layer.
