with order_items as (

    select * from {{ ref('stg_order_items') }}

),

orders as (

    select * from {{ ref('stg_orders') }}

),

joined as (

    select
        order_items.order_item_id,
        order_items.order_id,
        order_items.product_id,
        orders.customer_id,
        orders.store_id,
        orders.order_timestamp,
        cast(orders.order_timestamp as date) as order_date,
        orders.order_status,
        orders.payment_method,
        order_items.quantity,
        order_items.unit_price,
        order_items.line_amount,
        orders.order_status = 'Completed'    as is_revenue_line

    from order_items
    inner join orders
        on order_items.order_id = orders.order_id

)

select * from joined
