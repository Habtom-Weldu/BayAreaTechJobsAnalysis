#!/usr/bin/env bash
# Restore bayarea_tech_jobs_db from sql/ scripts and the processed CSV.
# Usage: ./scripts/restore_db.sh
# Env:   DB_NAME (default: bayarea_tech_jobs_db)
#        PSQL_USER (default: postgres)
#
# SQL and CSV are piped via stdin so the postgres OS user does not need
# read access to files under your home directory.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DB_NAME="${DB_NAME:-bayarea_tech_jobs_db}"
PSQL_USER="${PSQL_USER:-postgres}"
CSV="${ROOT}/data/processed/bay_area_tech_jobs.csv"

if [[ ! -f "$CSV" ]]; then
    echo "error: missing CSV at $CSV" >&2
    echo "Run notebooks/data_preparation.ipynb first, or restore the file." >&2
    exit 1
fi

run_psql() {
    if [[ "$(id -un)" == "$PSQL_USER" ]]; then
        psql -d "$DB_NAME" -v ON_ERROR_STOP=1 "$@"
    else
        sudo -u "$PSQL_USER" psql -d "$DB_NAME" -v ON_ERROR_STOP=1 "$@"
    fi
}

run_psql_file() {
    local file="$1"
    run_psql < "$file"
}

run_psql_copy_csv() {
  local table="$1"
  local csv="$2"
  {
    printf '%s\n' "\\copy ${table} FROM STDIN WITH (FORMAT csv, HEADER true, QUOTE '\"', ESCAPE '\"')"
    cat "$csv"
    printf '%s\n' "\\."
  } | run_psql
}

echo "==> Dropping existing bay_area_jobs schema (if any)"
run_psql -c "DROP SCHEMA IF EXISTS bay_area_jobs CASCADE;"

echo "==> Creating schema (sql/schema.sql)"
run_psql_file "${ROOT}/sql/schema.sql"

echo "==> Loading CSV into staging"
run_psql_copy_csv "bay_area_jobs.staging_bay_area_tech_jobs" "$CSV"

echo "==> Importing into tech_jobs (sql/import_bay_area_tech_jobs.sql)"
run_psql_file "${ROOT}/sql/import_bay_area_tech_jobs.sql"

echo "==> Done"
