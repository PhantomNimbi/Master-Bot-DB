FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

# Install all foundational utilities natively
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

# Fix Git pushing permission mechanics globally inside the environment
RUN git config --global credential.helper store

EXPOSE 5432 5433 6379

