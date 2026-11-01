with source as (

    select * from {{ source('wizard', 'customers') }}

),

renamed as (

    select
        customer_id,
        trim(first_name)      as first_name,
        trim(last_name)       as last_name,
        lower(trim(email))    as email,
        trim(phone)           as phone,
        trim(city)            as city,
        trim(province)        as province,
        trim(country)         as country,
        created_timestamp,
        updated_timestamp,
        is_active = 'Y'       as is_active

    from source

)

select * from renamed
