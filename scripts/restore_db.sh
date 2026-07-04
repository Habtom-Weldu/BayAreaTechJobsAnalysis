#!/usr/bin/env bash
# Restore bayarea_tech_jobs_db from sql/ scripts and the processed CSV.
#
# Local usage:
#   ./scripts/restore_db.sh
#
# Docker usage:
#   docker compose exec notebook ./scripts/restore_db.sh
#
# Env:
#   DB_NAME (default: bayarea_tech_jobs_db)
#   PSQL_USER / PGUSER (default: postgres)
#   PGHOST (set to db or localhost for TCP; unset uses local Unix socket)
#   PGPORT (default: 5432)
#   PGPASSWORD (required for TCP auth)

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DB_NAME="${DB_NAME:-${PGDATABASE:-bayarea_tech_jobs_db}}"
PSQL_USER="${PSQL_USER:-${PGUSER:-postgres}}"
PGHOST="${PGHOST:-}"
PGPORT="${PGPORT:-5432}"
CSV="${ROOT}/data/processed/bay_area_tech_jobs.csv"

if [[ ! -f "$CSV" ]]; then
    echo "error: missing CSV at $CSV" >&2
    echo "Run notebooks/data_preparation.ipynb first, or restore the file." >&2
    exit 1
fi

run_psql() {
    local args=(-d "$DB_NAME" -v ON_ERROR_STOP=1 "$@")

    if [[ -n "$PGHOST" && "$PGHOST" != /* ]]; then
        psql -h "$PGHOST" -p "$PGPORT" -U "$PSQL_USER" "${args[@]}"
    elif [[ "$(id -un)" == "$PSQL_USER" ]]; then
        psql "${args[@]}"
    else
        sudo -u "$PSQL_USER" psql "${args[@]}"
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
