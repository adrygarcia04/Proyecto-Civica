{{ config(severity='error', tags=['calidad']) }}

select
    url,
    post_date,
    report_date
from {{ ref('stg_own_interactions') }}
where post_date > report_date