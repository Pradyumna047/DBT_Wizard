with source as (

    select * from {{ source('wizard', 'products') }}

),

renamed as (

    select
        product_id,
        trim(product_name)            as product_name,
        trim(category)                as category,
        trim(brand)                   as brand,
        cast(price as decimal(18, 2)) as price,
        created_timestamp,
        updated_timestamp,
        is_active = 'Y'               as is_active

    from source

)

select * from renamed
