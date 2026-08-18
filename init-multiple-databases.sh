#!/bin/bash
set -e

# Default to master_bot if the DB_NAME variable is empty
MAIN_DB="${DB_NAME:-master_bot}"
SHADOW_DB="${MAIN_DB}_shadow"

echo "Creating shadow database: ${SHADOW_DB}"

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE ${SHADOW_DB};
EOSQL
