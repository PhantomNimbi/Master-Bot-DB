FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

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

EXPOSE 5432 5433 6379
