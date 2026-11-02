-- A line must sell at least one unit, at a non-negative price.

select
    order_item_id,
    quantity,
    unit_price,
    line_amount

from {{ ref('fct_order_items') }}
where quantity   <= 0
   or unit_price  < 0
   or line_amount < 0
