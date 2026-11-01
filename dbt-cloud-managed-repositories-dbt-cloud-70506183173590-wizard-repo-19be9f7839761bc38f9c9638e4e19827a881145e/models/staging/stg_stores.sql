with source as (

    select * from {{ source('wizard', 'stores') }}

),

renamed as (

    select
        store_id,
        trim(store_name)  as store_name,
        trim(city)        as city,
        trim(province)    as province,
        trim(country)     as country,
        created_timestamp,
        updated_timestamp,
        is_active = 'Y'   as is_active

    from source

)

select * from renamed
