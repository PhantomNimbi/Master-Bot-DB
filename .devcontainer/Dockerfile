FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

# Install base dependencies and setup keys for official Docker and Postgres repositories
RUN apt-get update && apt-get install -y \
    curl \
    git \
    sudo \
    gnupg \
    ca-certificates \
    && mkdir -p /etc/apt/keyrings \
    # 1. Add official Docker GPG key & repository
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    # 2. Add official PostgreSQL GPG key & repository
    && curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /etc/apt/keyrings/postgresql.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/postgresql.gpg] http://postgresql.org $(. /etc/os-release && echo "$VERSION_CODENAME")-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list > /dev/null

# Install Docker CE, Docker Compose plugin, and PostgreSQL
RUN apt-get update && apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin \
    postgresql \
    postgresql-contrib \
    && rm -rf /var/lib/apt/lists/*

# Configure PostgreSQL settings globally to accept connections from external application workspaces
RUN sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/*/main/postgresql.conf && \
    echo "host all all 0.0.0.0/0 md5" >> /etc/postgresql/*/main/pg_hba.conf

# Set up runtime permissions
EXPOSE 5432 5433
