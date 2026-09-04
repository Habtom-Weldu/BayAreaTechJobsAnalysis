"""Run multi-statement .sql analysis files and return DataFrames."""

from pathlib import Path

import pandas as pd
from sqlalchemy import text
from sqlalchemy.engine import Engine


def _strip_line_comments(sql_text: str) -> str:
    """Remove -- comments so statement splitting ignores semicolons in comments."""
    cleaned_lines: list[str] = []
    for line in sql_text.splitlines():
        if "--" in line:
            # Keep only the code before a line comment.
            code, _sep, _comment = line.partition("--")
            cleaned_lines.append(code.rstrip())
        else:
            cleaned_lines.append(line)
    return "\n".join(cleaned_lines)


def _split_statements(sql_text: str) -> list[str]:
    statements: list[str] = []
    for chunk in _strip_line_comments(sql_text).split(";"):
        statement = chunk.strip()
        if statement:
            statements.append(statement)
    return statements


def run_sql_file(engine: Engine, sql_path: str | Path) -> list[pd.DataFrame]:
    """Execute a .sql file and return a DataFrame for each SELECT result."""
    path = Path(sql_path)
    sql_text = path.read_text(encoding="utf-8")
    results: list[pd.DataFrame] = []

    with engine.begin() as conn:
        for statement in _split_statements(sql_text):
            upper = statement.lstrip().upper()
            if upper.startswith("SELECT") or upper.startswith("WITH"):
                results.append(pd.read_sql(text(statement), conn))
            else:
                conn.execute(text(statement))

    return results
