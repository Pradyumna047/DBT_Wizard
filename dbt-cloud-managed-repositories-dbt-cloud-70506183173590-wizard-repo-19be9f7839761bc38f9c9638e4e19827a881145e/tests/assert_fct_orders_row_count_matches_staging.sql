-- fct_orders is a left join from stg_orders, so the grain must be preserved.
-- A fan-out or a dropped row shows up here.

with staged as (
    select count(*) as n from {{ ref('stg_orders') }}
),

fact as (
    select count(*) as n from {{ ref('fct_orders') }}
)

select
    staged.n as staging_rows,
    fact.n   as fact_rows

from staged
cross join fact
where staged.n <> fact.n
