with products as (

    select * from {{ ref('stg_products') }}

)

select
    product_id,
    product_name,
    category,
    brand,
    price,
    is_active,
    created_timestamp,
    updated_timestamp

from products
