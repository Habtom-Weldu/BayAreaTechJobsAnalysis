# Bay Area Tech Job Market Analysis

## Project Objective

This project analyzes technology job market trends in the San Francisco Bay Area using labor market data. The goal is to identify high-demand tech occupations, compare salary levels across roles, and understand how employment opportunities vary across different Bay Area counties over time.

The insights from this analysis can help job seekers, career switchers, and data enthusiasts better understand the current tech job landscape.

---

## Key Questions

1. Which technology occupations have the highest employment in the Bay Area?
2. Which technology occupations offer the highest median salaries?
3. How does tech employment vary across Bay Area counties?
4. How have technology job trends changed over time?
5. Which tech occupations are experiencing the fastest growth?

---

## Tools & Technologies

* Python (Pandas)
* Jupyter Notebook
* PostgreSQL
* SQL
* Tableau
* Visual Studio Code
* Git & GitHub
* Docker

---

## Docker Setup

Full guide: [docs/docker-setup.md](docs/docker-setup.md)

Full-stack setup with PostgreSQL and JupyterLab.

```bash
cp .env.example .env
docker compose up --build
```

Services:

- JupyterLab: [http://localhost:8888](http://localhost:8888)
- PostgreSQL: `localhost:5433` (default; avoids conflict with a local Postgres on 5432)

On first startup, Postgres loads schema and data from `sql/` and `data/processed/`.
Data persists in the `postgres_data` Docker volume.

Useful commands:

```bash
# Rebuild and start
docker compose up --build

# Stop containers
docker compose down

# Reset database volume and reload from scratch
docker compose down -v
docker compose up --build

# Manual restore inside running containers
docker compose exec notebook ./scripts/restore_db.sh
```

From your host machine (outside Docker), connect with:

```text
postgresql+psycopg2://postgres:postgres@localhost:5433/bayarea_tech_jobs_db
```

---

## Project Status

- [x] Ask
- [x] Prepare
- [x] Process
- [x] Database Design
- [x] Data Import
- [ ] Analysis
- [ ] Visualization
- [ ] Final Report

---

## Planned Workflow

Data will be processed through the following stages:

Ask → Acquire → Understand Data → Prepare → Process → Analyze → Visualize → Share

---

## Future Sections (to be added)

* Dataset sources
* Data cleaning process
* Database schema
* SQL analysis examples
* Tableau dashboards
* Key findings
