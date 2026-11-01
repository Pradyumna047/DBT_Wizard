with employees as (

    select * from {{ ref('stg_employees') }}

)

select
    employee_id,
    store_id,
    first_name,
    last_name,
    concat_ws(' ', first_name, last_name) as full_name,
    email,
    job_title,
    salary,
    is_active,
    created_timestamp,
    updated_timestamp

from employees
