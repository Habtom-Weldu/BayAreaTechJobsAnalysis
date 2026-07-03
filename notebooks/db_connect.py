"""Shared PostgreSQL connection for notebooks."""

import os
from pathlib import Path

from sqlalchemy import create_engine
from sqlalchemy.engine import Engine


def _load_dotenv() -> None:
    try:
        from dotenv import load_dotenv
    except ImportError:
        return

    load_dotenv(Path(__file__).resolve().parent.parent / ".env")


def get_database_url() -> str:
    """Build a connection URL from DATABASE_URL or local defaults."""
    _load_dotenv()

    if url := os.environ.get("DATABASE_URL"):
        return url

    user = os.environ.get("PGUSER", os.environ.get("USER", "postgres"))
    db = os.environ.get("PGDATABASE", "bayarea_tech_jobs_db")
    host = os.environ.get("PGHOST", "/var/run/postgresql")

    # Unix socket (peer auth): no password required after setup_db_access.sh
    if host.startswith("/"):
        return f"postgresql+psycopg2://{user}@/{db}?host={host}"

    port = os.environ.get("PGPORT", "5432")
    password = os.environ.get("PGPASSWORD", "")
    auth = f"{user}:{password}" if password else user
    return f"postgresql+psycopg2://{auth}@{host}:{port}/{db}"


def get_engine() -> Engine:
    return create_engine(get_database_url())
