# Docker Setup Guide

This guide explains how this project uses Docker, what each Docker-related file does, and how to run the project on any machine.

---

## What Docker does for this project

Before Docker, you had to install and configure things manually on each machine:

- Python virtual environment
- Jupyter
- PostgreSQL
- database restore scripts
- local user permissions for Postgres

With Docker, two containers run the stack for you:

| Container | Service | What it provides |
|-----------|---------|------------------|
| `db` | PostgreSQL 17 | Database with schema and 89 rows loaded |
| `notebook` | JupyterLab | Python environment for notebooks |

Your project files stay on your machine. Docker mounts them into the containers so edits in Cursor appear immediately inside Jupyter.

---

## Architecture (simple view)

```text
Your machine
├── project folder (bind mount)
│   ├── notebooks/
│   ├── sql/
│   ├── data/processed/
│   └── scripts/
│
└── Docker
    ├── db container
    │   └── postgres_data volume (persistent DB storage)
    │
    └── notebook container
        └── reads/writes project files via /workspace
```

**Bind mount** (`.:/workspace`): your repo folder is shared with the notebook container.

**Named volume** (`postgres_data`): PostgreSQL data files persist even if you stop or rebuild containers.

---

## First-time setup (any machine)

### 1. Install Docker

You need:

- Docker Engine
- Docker Compose

Verify:

```bash
docker --version
docker compose version
```

### 2. Clone the project

```bash
git clone <your-github-repo-url>
cd bayarea-tech-jobs-analysis
```

### 3. Create your local environment file

```bash
cp .env.example .env
```

- `.env.example` is committed to Git (safe template).
- `.env` is **not** committed (local settings, may contain passwords).

### 4. Start the stack

```bash
docker compose up --build
```

What happens:

1. Docker builds the notebook image from `Dockerfile`.
2. Docker pulls the PostgreSQL image.
3. The `db` container starts and waits until healthy.
4. On **first startup only**, Postgres runs `docker/postgres/init/01_restore.sh`.
5. The `notebook` container starts JupyterLab.

### 5. Open the services

| Service | URL / address |
|---------|----------------|
| JupyterLab | http://localhost:8888 |
| PostgreSQL (from your host) | `localhost:5433` |

Port `5433` is used on your machine so Docker Postgres does not conflict with a local Postgres on `5432`.

### 6. Verify the database

```bash
docker compose exec db psql -U postgres -d bayarea_tech_jobs_db \
  -c "SELECT COUNT(*) FROM bay_area_jobs.tech_jobs;"
```

Expected result: **89**

---

## Docker-related files in this project

### `docker-compose.yml`

The main orchestration file. It defines both services and how they connect.

**`db` service highlights:**

```yaml
image: postgres:17
ports:
  - "${POSTGRES_PORT:-5433}:5432"
volumes:
  - postgres_data:/var/lib/postgresql/data
  - ./docker/postgres/init:/docker-entrypoint-initdb.d:ro
  - ./sql:/workspace/sql:ro
  - ./data/processed:/workspace/data/processed:ro
```

- Uses the official Postgres 17 image.
- Maps host port `5433` to container port `5432`.
- Stores DB files in the `postgres_data` volume.
- Mounts init scripts and SQL/CSV for first-time database load.

**`notebook` service highlights:**

```yaml
build: .
volumes:
  - .:/workspace
environment:
  DATABASE_URL: postgresql+psycopg2://postgres:postgres@db:5432/bayarea_tech_jobs_db
depends_on:
  db:
    condition: service_healthy
```

- Builds from `Dockerfile`.
- Mounts your entire repo into `/workspace`.
- Connects to Postgres using hostname `db` (the Docker service name).
- Waits until the database is healthy before starting.

---

### `Dockerfile`

Defines the **notebook container image**.

What it does:

1. Starts from `python:3.12-slim-bookworm`.
2. Installs `postgresql-client` (for running `psql` inside the container).
3. Installs Python packages from `requirements/dev.txt`.
4. Starts JupyterLab on port `8888`.

Example from the file:

```dockerfile
COPY requirements/base.txt requirements/dev.txt requirements/
RUN pip install --no-cache-dir -r requirements/dev.txt

CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", ...]
```

Think of it as: “recipe for the Python/Jupyter environment.”

---

### `.dockerignore`

Tells Docker which files **not** to send when building the image.

Example entries:

```text
.venv/
.git/
.env
data/raw/
```

Why it matters:

- Faster builds
- Smaller build context
- Avoids copying secrets (`.env`) into the image

---

### `.env.example` and `.env`

**`.env.example`** (committed): documents the variables Docker needs.

**`.env`** (local only): your actual values. Docker Compose reads it automatically.

Key variables in this project:

```env
POSTGRES_DB=bayarea_tech_jobs_db
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_PORT=5433
JUPYTER_PORT=8888
DATABASE_URL=postgresql+psycopg2://postgres:postgres@db:5432/bayarea_tech_jobs_db
```

Note the hostname:

- **`db`** → used inside Docker containers
- **`localhost:5433`** → used from your host machine (Cursor, local tools)

---

### `docker/postgres/init/01_restore.sh`

Runs **once**, only when the `postgres_data` volume is created for the first time.

It performs the same steps as the manual restore:

1. Run `sql/schema.sql` (create schema and tables)
2. Load `data/processed/bay_area_tech_jobs.csv` into staging
3. Run `sql/import_bay_area_tech_jobs.sql` (insert into `tech_jobs`)

After that, the database persists in the Docker volume. Restarting containers does **not** re-run this script unless you delete the volume.

---

### `scripts/restore_db.sh`

Manual restore script. Works in two modes:

**Local (non-Docker):**

```bash
./scripts/restore_db.sh
```

Uses Unix socket + `sudo -u postgres` when needed.

**Inside Docker:**

```bash
docker compose exec notebook ./scripts/restore_db.sh
```

Uses TCP connection to the `db` service (`PGHOST=db` is set in `docker-compose.yml`).

Use this when you want to reload data without deleting the entire volume.

---

### `notebooks/db_connect.py`

Shared helper for notebooks to connect to Postgres.

It reads `DATABASE_URL` from the environment (set by Docker Compose) or falls back to local defaults.

In Docker, notebooks use:

```text
postgresql+psycopg2://postgres:postgres@db:5432/bayarea_tech_jobs_db
```

Example in a notebook:

```python
from db_connect import get_engine
import pandas as pd

engine = get_engine()
df = pd.read_sql("SELECT * FROM bay_area_jobs.tech_jobs LIMIT 10", engine)
df
```

---

## Common commands (practical examples)

### Start in the background

```bash
docker compose up -d
```

### View running containers

```bash
docker compose ps
```

### View logs

```bash
docker compose logs -f
docker compose logs -f db
docker compose logs -f notebook
```

### Stop containers

```bash
docker compose down
```

### Rebuild after changing Dockerfile or requirements

```bash
docker compose up --build
```

### Reset database completely (fresh 89-row reload)

```bash
docker compose down -v
docker compose up --build
```

`-v` deletes the `postgres_data` volume, so Postgres runs the init script again.

### Manual restore (keep volume, reload data)

```bash
docker compose exec notebook ./scripts/restore_db.sh
```

### Open a shell inside the notebook container

```bash
docker compose exec notebook bash
```

### Connect to Postgres from your host

```bash
psql -h localhost -p 5433 -U postgres -d bayarea_tech_jobs_db
```

Password: value of `POSTGRES_PASSWORD` in your `.env` (default: `postgres`).

---

## How data persistence works

| Data | Storage | Survives `docker compose down`? | Survives `docker compose down -v`? |
|------|---------|----------------------------------|--------------------------------------|
| Notebooks, SQL, scripts | Your repo folder | Yes | Yes |
| PostgreSQL tables | `postgres_data` volume | Yes | **No** (volume deleted) |
| Python packages in notebook | Docker image | Yes (until rebuild) | Yes (until rebuild) |

**Rule of thumb:**

- Stop containers → data stays
- Delete volume (`-v`) → database reset, init script runs again

---

## Moving to another machine

On a new laptop or VM:

```bash
git clone <your-github-repo-url>
cd bayarea-tech-jobs-analysis
cp .env.example .env
docker compose up --build
```

Then open:

- http://localhost:8888
- run notebooks from `notebooks/`

No need to install Postgres or Python locally for the Docker workflow.

---

## Troubleshooting

### Port already in use

If `8888` or `5433` is taken, change in `.env`:

```env
JUPYTER_PORT=8889
POSTGRES_PORT=5434
```

Then restart:

```bash
docker compose down
docker compose up --build
```

### Database is empty after restart

The init script only runs on a **new** volume. Either:

```bash
docker compose down -v
docker compose up --build
```

or:

```bash
docker compose exec notebook ./scripts/restore_db.sh
```

### Notebook cannot connect to database

Inside Docker notebooks, the host must be **`db`**, not `localhost`:

```text
postgresql+psycopg2://postgres:postgres@db:5432/bayarea_tech_jobs_db
```

From Cursor on your host machine, use:

```text
postgresql+psycopg2://postgres:postgres@localhost:5433/bayarea_tech_jobs_db
```

### Check container health

```bash
docker compose ps
docker compose logs db
```

The `db` service should show `(healthy)`.

---

## Quick reference

| Goal | Command |
|------|---------|
| First start | `docker compose up --build` |
| Start in background | `docker compose up -d` |
| Stop | `docker compose down` |
| Reset DB | `docker compose down -v && docker compose up --build` |
| Reload data | `docker compose exec notebook ./scripts/restore_db.sh` |
| Check row count | `docker compose exec db psql -U postgres -d bayarea_tech_jobs_db -c "SELECT COUNT(*) FROM bay_area_jobs.tech_jobs;"` |

---

## Related files (not Docker-specific but used by Docker)

| File | Role |
|------|------|
| `sql/schema.sql` | Creates database schema and tables |
| `sql/import_bay_area_tech_jobs.sql` | Loads staging data into `tech_jobs` |
| `data/processed/bay_area_tech_jobs.csv` | Source data (89 rows) |
| `requirements/base.txt` | Core Python dependencies |
| `requirements/dev.txt` | Extra notebook tools (includes `-r base.txt`) |
