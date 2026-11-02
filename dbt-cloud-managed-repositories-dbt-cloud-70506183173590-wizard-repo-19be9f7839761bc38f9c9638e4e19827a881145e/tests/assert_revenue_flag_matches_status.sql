-- is_revenue_order is derived from order_status, so the two must never disagree.

select
    order_id,
    order_status,
    is_revenue_order

from {{ ref('fct_orders') }}
where is_revenue_order is null
   or is_revenue_order <> (order_status = 'Completed')
