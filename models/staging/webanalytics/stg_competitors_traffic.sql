with source as (
    select
        domain,
        record_day,
        traffic_type,
        sessions
    from {{ source('webanalytics', 'competitors_traffic') }}
),

renamed as (
    select
        lower({{ remove_accents('domain') }}) as web_domain,
        to_timestamp_ntz(record_day, 'YYYY-MM-DD') as record_date,
        traffic_type,
        sessions as n_sessions
    from source
)

select * from renamed