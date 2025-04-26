#!/bin/bash

# generate_delta.sh
# Usage: ./generate_delta.sh old_schema.sql new_schema.sql

set -e

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 old_schema.sql new_schema.sql"
  exit 1
fi

OLD_SCHEMA="$1"
NEW_SCHEMA="$2"

# Extract version numbers from filenames
OLD_VERSION=$(echo "$OLD_SCHEMA" | grep -oP 'v\d+\.\d+\.\d+')
NEW_VERSION=$(echo "$NEW_SCHEMA" | grep -oP 'v\d+\.\d+\.\d+')

if [ -z "$OLD_VERSION" ] || [ -z "$NEW_VERSION" ]; then
  echo "Error: Cannot extract version numbers from filenames."
  exit 1
fi

DELTA_FILE="delta_${OLD_VERSION}_to_${NEW_VERSION}.sql"

if [ -f "$DELTA_FILE" ]; then
  echo "Error: $DELTA_FILE already exists."
  exit 1
fi

# Check dependencies
if ! command -v psqldef &> /dev/null
then
    echo "Error: psqldef (sqldef for PostgreSQL) is not installed."
    echo "Install it via: go install github.com/k0kubun/sqldef/cmd/psqldef@latest"
    exit 1
fi

# Create a temporary PostgreSQL test database
DB_NAME="delta_temp_db_$(date +%s)"
USER="postgres"

createdb "$DB_NAME"

# Ensure the database is dropped on exit or error
trap "dropdb \"$DB_NAME\"" EXIT

# Apply old schema to temp database
psql -U "$USER" "$DB_NAME" < "$OLD_SCHEMA"

# Generate delta
psqldef localhost -U "$USER" -d "$DB_NAME" --dry-run < "$NEW_SCHEMA" > "$DELTA_FILE"

echo "Delta generated successfully in $DELTA_FILE"
