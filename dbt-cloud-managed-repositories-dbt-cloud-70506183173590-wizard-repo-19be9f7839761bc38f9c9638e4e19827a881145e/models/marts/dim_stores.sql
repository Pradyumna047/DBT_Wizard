with stores as (

    select * from {{ ref('stg_stores') }}

)

select
    store_id,
    store_name,
    city,
    province,
    country,
    is_active,
    created_timestamp,
    updated_timestamp

from stores
