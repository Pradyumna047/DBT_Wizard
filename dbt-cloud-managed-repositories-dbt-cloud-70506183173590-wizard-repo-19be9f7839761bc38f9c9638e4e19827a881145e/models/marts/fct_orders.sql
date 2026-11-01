with orders as (

    select * from {{ ref('stg_orders') }}

),

order_items as (

    select * from {{ ref('stg_order_items') }}

),

item_rollup as (

    select
        order_id,
        count(*)                   as line_item_count,
        count(distinct product_id) as distinct_product_count,
        sum(quantity)              as total_quantity,
        sum(line_amount)           as line_amount_total

    from order_items
    group by order_id

),

final as (

    select
        orders.order_id,
        orders.customer_id,
        orders.store_id,
        orders.order_timestamp,
        cast(orders.order_timestamp as date)      as order_date,
        orders.payment_method,
        orders.order_status,
        orders.total_amount,
        coalesce(item_rollup.line_item_count, 0)        as line_item_count,
        coalesce(item_rollup.distinct_product_count, 0) as distinct_product_count,
        coalesce(item_rollup.total_quantity, 0)         as total_quantity,
        coalesce(item_rollup.line_amount_total, 0)      as line_amount_total,
        orders.total_amount
            - coalesce(item_rollup.line_amount_total, 0) as header_vs_lines_diff,
        orders.order_status = 'Completed'          as is_revenue_order,
        orders.is_active

    from orders
    left join item_rollup
        on orders.order_id = item_rollup.order_id

)

select * from final
