#!/usr/bin/env bash
# Runs once when the postgres_data volume is first created.

set -euo pipefail

echo "==> Initializing bay_area_jobs schema and data"

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" \
    -f /workspace/sql/schema.sql

{
    printf '%s\n' "\\copy bay_area_jobs.staging_bay_area_tech_jobs FROM STDIN WITH (FORMAT csv, HEADER true, QUOTE '\"', ESCAPE '\"')"
    cat /workspace/data/processed/bay_area_tech_jobs.csv
    printf '%s\n' "\\."
} | psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB"

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" \
    -f /workspace/sql/import_bay_area_tech_jobs.sql

echo "==> Database initialization complete"
