with source as (
    select
        mail,
        full_name,
        dni,
        birthdate,
        department,
        job_title,
        report_date
    from {{ ref('stg_people') }}
)

select
    mail,
    full_name,
    dni,
    birthdate,
    department,
    job_title,
    to_timestamp_ntz(convert_timezone('UTC', report_date)) as report_at
from source
where report_date = (
    {% if var('people_report_date', none) is not none %}
        select to_date('{{ var("people_report_date") }}', 'YYYY-MM-DD')
    {% else %}
        select max(report_date) from source
    {% endif %}
)