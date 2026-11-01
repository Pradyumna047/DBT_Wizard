with source as (

    select * from {{ source('wizard', 'order_items') }}

),

renamed as (

    select
        order_item_id,
        order_id,
        product_id,
        quantity,
        cast(unit_price as decimal(18, 2))  as unit_price,
        cast(line_amount as decimal(18, 2)) as line_amount,
        created_timestamp,
        updated_timestamp,
        is_active = 'Y'                     as is_active

    from source

)

select * from renamed
