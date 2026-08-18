FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

# Install all requested tools using standard native distribution channels
RUN apt-get update && apt-get install -y \
    curl \
    git \
    sudo \
    gnupg \
    ca-certificates \
    docker.io \
    docker-compose \
    postgresql \
    postgresql-contrib \
    && rm -rf /var/lib/apt/lists/*

RUN git config --global credential.helper store

# Copy and set up the automated database runtime initialization hook
COPY .devcontainer/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 5432 5433 6379

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
