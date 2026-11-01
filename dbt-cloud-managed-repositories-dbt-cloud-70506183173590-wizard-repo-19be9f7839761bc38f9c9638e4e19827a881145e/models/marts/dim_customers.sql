with customers as (

    select * from {{ ref('stg_customers') }}

)

select
    customer_id,
    first_name,
    last_name,
    concat_ws(' ', first_name, last_name) as full_name,
    email,
    phone,
    city,
    province,
    country,
    is_active,
    created_timestamp,
    updated_timestamp

from customers
