<div align="center">

# 🧙 dbt Wizard

**A dimensional analytics layer built with dbt on Databricks Unity Catalog.**

Six raw CSVs land in a Unity Catalog schema. dbt turns them into a tested,
documented star schema you can actually query.

![dbt](https://img.shields.io/badge/dbt-1.12-FF694B?style=for-the-badge&logo=dbt&logoColor=white)
![Databricks](https://img.shields.io/badge/Databricks-Unity_Catalog-FF3621?style=for-the-badge&logo=databricks&logoColor=white)
![Delta Lake](https://img.shields.io/badge/Delta_Lake-00ADD4?style=for-the-badge&logo=delta&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-4479A1?style=for-the-badge&logo=postgresql&logoColor=white)

![models](https://img.shields.io/badge/models-12-0A7BBB?style=flat-square)
![tests](https://img.shields.io/badge/tests-46_passing-2EA44F?style=flat-square)
![build](https://img.shields.io/badge/dbt_build-58%2F58_pass-2EA44F?style=flat-square)
![rows](https://img.shields.io/badge/rows_modelled-42k-6E40C9?style=flat-square)

</div>

---

## What this is

A complete analytics engineering pipeline, end to end:

> **CSV files on a laptop** → **Unity Catalog tables** → **typed staging views** → **dimensional marts** → **tested, queryable star schema**

Nothing is hand-maintained. Change a model, run `dbt build`, and the whole
graph rebuilds with its tests.

---

## Architecture

```mermaid
flowchart LR
    subgraph src["Raw — CSV loaded into Unity Catalog"]
        direction TB
        r1[customers]
        r2[employees]
        r3[stores]
        r4[products]
        r5[orders]
        r6[order_items]
    end

    subgraph stg["Staging — views"]
        direction TB
        v1[stg_customers]
        v2[stg_employees]
        v3[stg_stores]
        v4[stg_products]
        v5[stg_orders]
        v6[stg_order_items]
    end

    subgraph marts["Marts — Delta tables"]
        direction TB
        d1[dim_customers]
        d2[dim_employees]
        d3[dim_stores]
        d4[dim_products]
        f1[fct_orders]
        f2[fct_order_items]
    end

    r1 --> v1 --> d1
    r2 --> v2 --> d2
    r3 --> v3 --> d3
    r4 --> v4 --> d4
    r5 --> v5 --> f1
    r6 --> v6 --> f2
    v6 --> f1
    v5 --> f2

    style src fill:#fff4e6,stroke:#ff9f43,color:#333
    style stg fill:#e6f3ff,stroke:#0a7bbb,color:#333
    style marts fill:#eaffea,stroke:#2ea44f,color:#333
```

### The star schema

```mermaid
erDiagram
    DIM_CUSTOMERS ||--o{ FCT_ORDERS : places
    DIM_STORES    ||--o{ FCT_ORDERS : hosts
    FCT_ORDERS    ||--|{ FCT_ORDER_ITEMS : contains
    DIM_PRODUCTS  ||--o{ FCT_ORDER_ITEMS : "sold as"
    DIM_STORES    ||--o{ DIM_EMPLOYEES : employs
```

---

## The data

Retail transactions across a chain of stores.

| Table | Grain | Rows |
|---|---|---:|
| `customers` | one per customer | 2,000 |
| `employees` | one per employee | 250 |
| `stores` | one per store | 25 |
| `products` | one per product | 500 |
| `orders` | one per order | 10,000 |
| `order_items` | one per order line | 30,021 |

---

## Layers

### 🔹 Staging — `models/staging/`

Thin views over the raw tables. One per source, no joins, no business logic.
This is where the data gets *honest*:

- **`is_active`** arrives as a `STRING` holding `'Y'`/`'N'` → cast to a real **boolean**
- **Money columns** arrive as `DOUBLE` → cast to **`decimal(18,2)`**, because floating-point currency is a bug waiting to happen
- **Emails** lowercased, text fields trimmed

### 🔸 Marts — `models/marts/`

Materialized as Delta tables.

| Model | What it gives you |
|---|---|
| `dim_customers` | Customer attributes + derived `full_name` |
| `dim_employees` | Staff, with their store FK |
| `dim_stores` | Store locations |
| `dim_products` | Catalogue with category and brand |
| `fct_orders` | **One row per order**, with line-item totals rolled up |
| `fct_order_items` | **One row per line**, with order context denormalized on |

`fct_orders` carries two columns worth calling out:

- **`header_vs_lines_diff`** — the order's stated `total_amount` minus the sum of its line amounts. A built-in reconciliation check. *Currently zero across all 10,000 orders.*
- **`is_revenue_order`** — flags the 2,447 `Completed` orders. Cancelled, Pending and Returned rows are **kept**, not silently dropped, so you choose your own denominator.

---

## Data quality

46 tests, running on every `dbt build`:

| Test type | Covers |
|---|---|
| `unique` + `not_null` | Every primary key, all 12 models |
| `relationships` | Every FK — orders→customers, orders→stores, items→orders, items→products, employees→stores |
| `accepted_values` | `order_status`, `payment_method` |

```
Done. PASS=58 WARN=0 ERROR=0 SKIP=0 TOTAL=58
```

Referential integrity holds across the whole graph — no orphan line items, no orders without a customer.

---

## Running it

```bash
# from the dbt project directory
dbt build          # staging + marts + all tests
dbt run            # models only
dbt test           # tests only
dbt docs generate && dbt docs serve   # browse the lineage graph
```

Target: **Databricks SQL warehouse** (serverless), catalog `my_wizard`, schema `wizard_schema`.

---

## Notes for anyone forking this

**The `use catalog` pre-hook isn't optional.** `dbt_project.yml` sets:

```yaml
+pre-hook: "use catalog my_wizard"
```

Without it, `CREATE TABLE` fails with `UC_HIVE_METASTORE_DISABLED_EXCEPTION`.
The connection has no default catalog, so the session falls back to
`hive_metastore` — which is disabled on modern workspaces. Views are unaffected
(they allocate no storage), which makes this fail *only* on the marts layer and
look far more mysterious than it is. Setting a default catalog on the
connection is the cleaner fix.

**`generate_schema_name.sql`** overrides dbt's default behaviour of prefixing
custom schemas with the target schema, so `+schema: wizard_schema` means
exactly that rather than `<target>_wizard_schema`.

---

## Layout

```
.
├── models/
│   ├── staging/        # 6 views + sources.yml + tests
│   └── marts/          # 4 dimensions, 2 facts + tests
├── macros/
│   └── generate_schema_name.sql
└── dbt_project.yml     # catalog/schema pinning, materializations, pre-hook
```

<div align="center">
<sub>Built with dbt Core on Databricks Free Edition.</sub>
</div>
