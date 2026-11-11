# sql-practice

SQL practice: window functions, CTEs and execution plans on PostgreSQL 16 and DuckDB.
The data is a generated, deterministic e-commerce dataset (`init/01_seed.sql`, ~300k rows).
Exercises are grouped by week (`week01/`, `week02/`, ...), notes live in `notes/`.

## Run

```bash
docker compose up -d
docker compose exec postgres psql -U de -d practice
```