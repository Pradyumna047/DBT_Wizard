with source as (

    select * from {{ source('wizard', 'orders') }}

),

renamed as (

    select
        order_id,
        customer_id,
        store_id,
        order_timestamp,
        trim(payment_method)                 as payment_method,
        trim(order_status)                   as order_status,
        cast(total_amount as decimal(18, 2)) as total_amount,
        created_timestamp,
        updated_timestamp,
        is_active = 'Y'                      as is_active

    from source

)

select * from renamed
