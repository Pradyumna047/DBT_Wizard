with source as (

    select * from {{ source('wizard', 'employees') }}

),

renamed as (

    select
        employee_id,
        store_id,
        trim(first_name)                as first_name,
        trim(last_name)                 as last_name,
        lower(trim(email))              as email,
        trim(job_title)                 as job_title,
        cast(salary as decimal(18, 2))  as salary,
        created_timestamp,
        updated_timestamp,
        is_active = 'Y'                 as is_active

    from source

)

select * from renamed
