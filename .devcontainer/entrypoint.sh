#!/bin/bash
set -e

# Detect the installed PostgreSQL system major version dynamically
PG_VERSION=$(ls /etc/postgresql/)
DATA_DIR="/var/lib/postgresql/data"

# Auto-initialize the raw volume folder if it is missing cluster structures
if [ ! -s "$DATA_DIR/PG_VERSION" ]; then
    echo "Initializing blank PostgreSQL database data storage layout..."
    chown -R postgres:postgres "$DATA_DIR"
    sudo -u postgres /usr/lib/postgresql/$PG_VERSION/bin/initdb -D "$DATA_DIR"
    
    # Enable global listening permissions
    echo "listen_addresses = '*'" >> "$DATA_DIR/postgresql.conf"
    echo "host all all 0.0.0.0/0 md5" >> "$DATA_DIR/pg_hba.conf"
fi

# Ensure permissions match perfectly across volume mappings
chown -R postgres:postgres "$DATA_DIR"

# Launch the database process cleanly into the foreground
echo "Launching PostgreSQL server process cluster..."
exec sudo -u postgres /usr/lib/postgresql/$PG_VERSION/bin/postgres -D "$DATA_DIR"
