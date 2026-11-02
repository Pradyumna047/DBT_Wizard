-- No order may carry a negative amount, quantity or line count.

select
    order_id,
    total_amount,
    line_amount_total,
    total_quantity,
    line_item_count

from {{ ref('fct_orders') }}
where total_amount     < 0
   or line_amount_total < 0
   or total_quantity    < 0
   or line_item_count   < 0
