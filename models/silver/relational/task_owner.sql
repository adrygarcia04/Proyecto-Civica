with source as(
    select
        full_name,
        dni,
        birthdate,
        mail,
        department,
        job_title,
        year
    from {{ ref('stg_people') }}
),

sur_key as(
    select
        {{ dbt_utils.generate_surrogate_key(['mail', 'year']) }} as task_owner_id,
        full_name,
        dni,
        birthdate,
        mail,
        department,
        job_title,
        year
    from source
)

select * from sur_key