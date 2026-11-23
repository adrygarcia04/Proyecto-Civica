with source as(
    select
        dbt_scd_id,
        full_name,
        mail,
        department,
        job_title
    from {{ ref('snap_task_owner') }}
)

select * from source