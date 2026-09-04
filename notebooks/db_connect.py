"""Shared PostgreSQL connection for notebooks."""

import os
from pathlib import Path
from urllib.parse import urlparse, urlunparse

from sqlalchemy import create_engine
from sqlalchemy.engine import Engine


def _load_dotenv() -> None:
    try:
        from dotenv import load_dotenv
    except ImportError:
        return

    env_path = Path(__file__).resolve().parent.parent / ".env"
    # Do not override Compose-injected DATABASE_URL=@db inside containers.
    # On the host, allow .env to replace a stale DATABASE_URL from an old kernel.
    load_dotenv(env_path, override=not _running_in_docker())


def _running_in_docker() -> bool:
    return Path("/.dockerenv").exists()


def _rewrite_docker_hostname_for_host(url: str) -> str:
    """Map Compose hostname 'db' to localhost when running outside Docker."""
    if _running_in_docker():
        return url

    parsed = urlparse(url)
    if parsed.hostname != "db":
        return url

    port = os.environ.get("POSTGRES_PORT") or os.environ.get("PGPORT") or "5433"
    userinfo = ""
    if parsed.username:
        userinfo = parsed.username
        if parsed.password is not None:
            userinfo += f":{parsed.password}"
        userinfo += "@"

    new_netloc = f"{userinfo}localhost:{port}"
    return urlunparse(parsed._replace(netloc=new_netloc))


def get_database_url() -> str:
    """Build a connection URL from DATABASE_URL or local defaults."""
    _load_dotenv()

    # Inside Docker Compose, prefer the container-provided URL (host=db).
    if _running_in_docker() and (url := os.environ.get("DATABASE_URL")):
        return url

    if url := os.environ.get("DATABASE_URL"):
        return _rewrite_docker_hostname_for_host(url)

    user = os.environ.get(
        "PGUSER",
        "postgres" if _running_in_docker() else os.environ.get("USER", "postgres"),
    )
    db = os.environ.get("PGDATABASE", "bayarea_tech_jobs_db")

    if _running_in_docker():
        host = os.environ.get("PGHOST", "db")
        port = os.environ.get("PGPORT", "5432")
        password = os.environ.get("PGPASSWORD", "postgres")
        return f"postgresql+psycopg2://{user}:{password}@{host}:{port}/{db}"

    # Host defaults: Docker-published Postgres port.
    host = os.environ.get("PGHOST", "localhost")
    port = os.environ.get("PGPORT") or os.environ.get("POSTGRES_PORT") or "5433"
    password = os.environ.get("PGPASSWORD", "postgres")
    return f"postgresql+psycopg2://{user}:{password}@{host}:{port}/{db}"


def get_engine() -> Engine:
    return create_engine(get_database_url())
