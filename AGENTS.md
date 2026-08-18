# AI Agent Instruction Guidelines & Workspace Constraints

This repository enforces strict operational parameters. Any AI agent modifying or iterating on this codebase must adhere completely to the rules defined below.

## Critical Constraints (Do Not Violate)

1. **Strict Base Image Enforcement**
   * **Rule**: You must always use the native "ubuntu:latest" image string inside the environment definition.
   * **Constraint**: Never use remote devcontainer registry strings (e.g., "://microsoft.com"), alternative operating system variants (Alpine), or pre-baked database templates.

2. **No Devcontainer Features**
   * **Rule**: Keep the features block completely omitted from devcontainer.json.
   * **Constraint**: Do not introduce keys matching "ghcr.io/devcontainers/features/postgres". All software packages must be installed cleanly using standard native apt-get managers inside the local Dockerfile.
3. **Absolute Command Mappings Only**
   * **Rule**: Never run short-name calls like command: ["postgres"] inside your orchestration files.
   * **Constraint**: Defer database process lifecycle management completely to the custom .devcontainer/entrypoint.sh script. This script handles path mapping and user execution states via clean foreground routing.

4. **Port Visibility Automation**
   * **Rule**: Do not use "visibility": "public" within devcontainer.json port arrays, as the devcontainer engine completely ignores it.
   * **Constraint**: Always use the pre-installed GitHub CLI utility via the postStartCommand hook to force port visibility states to change: gh codespace ports visibility 5432:public 5433:public 6379:public.

## Troubleshooting Playbook for Agents

### If the build hits path non-existent faults:
* Ensure no sed or line-append operations are firing inside the raw Dockerfile compilation stage. 
* All string modifications for postgresql.conf or pg_hba.conf must live inside entrypoint.sh so they execute after the container filesystem mounts.

### If external connections fail to bind:
* Verify that entrypoint.sh successfully appends listen_addresses = '*' and host all all 0.0.0.0/0 md5 to the active runtime data directory.
* Confirm that the external connection strings are routing through port 443 with the parameter ?sslmode=require specified.
