#!/usr/bin/env bash
# Grant the current Linux user read access to bay_area_jobs via Unix socket.
# Run once after restore_db.sh so notebooks can connect without a password.
#
# Usage: ./scripts/setup_db_access.sh

set -euo pipefail

OS_USER="$(id -un)"
DB_NAME="${DB_NAME:-bayarea_tech_jobs_db}"
PSQL_USER="${PSQL_USER:-postgres}"

run_psql() {
    if [[ "$(id -un)" == "$PSQL_USER" ]]; then
        psql "$@"
    else
        sudo -u "$PSQL_USER" psql "$@"
    fi
}

echo "==> Granting PostgreSQL role '${OS_USER}' read access to ${DB_NAME}"

run_psql -d postgres -v ON_ERROR_STOP=1 <<EOF
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '${OS_USER}') THEN
    CREATE ROLE ${OS_USER} LOGIN;
  END IF;
END
\$\$;
GRANT CONNECT ON DATABASE ${DB_NAME} TO ${OS_USER};
EOF

run_psql -d "$DB_NAME" -v ON_ERROR_STOP=1 <<EOF
GRANT USAGE ON SCHEMA bay_area_jobs TO ${OS_USER};
GRANT SELECT ON ALL TABLES IN SCHEMA bay_area_jobs TO ${OS_USER};
ALTER DEFAULT PRIVILEGES IN SCHEMA bay_area_jobs
  GRANT SELECT ON TABLES TO ${OS_USER};
EOF

echo "==> Done. Notebooks connect via Unix socket as '${OS_USER}' (no password)."
