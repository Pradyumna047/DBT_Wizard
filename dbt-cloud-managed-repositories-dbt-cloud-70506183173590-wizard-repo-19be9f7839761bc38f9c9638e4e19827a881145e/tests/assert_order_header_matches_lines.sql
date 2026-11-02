-- An order's stated total_amount must equal the sum of its line amounts.
-- Any returned row is a reconciliation break.

select
    order_id,
    total_amount,
    line_amount_total,
    header_vs_lines_diff

from {{ ref('fct_orders') }}
where abs(header_vs_lines_diff) > 0.01
