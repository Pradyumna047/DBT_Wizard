-- Each line's amount must equal quantity x unit_price.
-- The same reconciliation as the order header, one grain down.

select
    order_item_id,
    quantity,
    unit_price,
    line_amount,
    line_amount - (quantity * unit_price) as diff

from {{ ref('fct_order_items') }}
where abs(line_amount - (quantity * unit_price)) > 0.01
