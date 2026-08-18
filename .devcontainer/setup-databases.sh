#!/bin/bash
set -e

USER="${PGUSER:-postgres}"
MAIN_DB="${PGDATABASE:-master_bot}"
SHADOW_DB="${PGDATABASE_SHADOW:-master_bot_shadow}"

echo "Starting Multi-Database Provisioning..."

# Ensure database process loop is fully operational before executing commands
until psql -U "$USER" -d "postgres" -c '\q' 2>/dev/null; do
  echo "Waiting for database service container layers to synchronize..."
  sleep 2
done

# Create Primary application database
if [ "$MAIN_DB" != "postgres" ]; then
  psql -U "$USER" -d "postgres" -c "SELECT 1 FROM pg_database WHERE datname = '$MAIN_DB'" | grep -q 1 || \
  psql -U "$USER" -d "postgres" -c "CREATE DATABASE $MAIN_DB;"
fi

# Create dedicated Prisma Shadow database
psql -U "$USER" -d "postgres" -c "SELECT 1 FROM pg_database WHERE datname = '$SHADOW_DB'" | grep -q 1 || \
  psql -U "$USER" -d "postgres" -c "CREATE DATABASE $SHADOW_DB;"

echo "Database operational synchronization complete!"
