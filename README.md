# E-commerce Case Study

A complete analyst working of a deliberately dirty e-commerce dataset: data
quality audit, business analysis, and the report a stakeholder would actually
receive. Grew out of session 003 in [sql-notes](https://github.com/collapseindex/sql-notes).

**The dataset is synthetic**, generated for practice with issues planted on
purpose and no answer key. All five findable defects were found; the working
is the point, not the data.

## The one-line result

One month of orders (July 2026, 34 orders after cleaning) shows healthy
contribution overall, but one sales channel returns 57% of its orders and
nets almost nothing, and the deepest-discounted monitors destroy per-order
contribution. Both findings survive their caveats; both come with the data
request that would settle them.

## Structure

| file | what it is |
|---|---|
| [REPORT.md](REPORT.md) | The deliverable: what a DA would hand the Growth Manager |
| [FINDINGS.md](FINDINGS.md) | Every finding with its evidence, verbatim row ids, and disposition |
| [sql/](sql/) | Numbered, runnable queries: load, sweeps, analyses |
| [data/raw/](data/raw/) | The untouched source workbook |

## Reproduce

```bash
pip install duckdb
python -c "import duckdb; con=duckdb.connect(); [con.sql(open(f'sql/{f}').read()) for f in ('00_load.sql',)]"
```

Or open the DuckDB UI and `.read` the sql files in order. Every number in
REPORT.md and FINDINGS.md was computed from `sql/` and independently
recomputed before being written down.
