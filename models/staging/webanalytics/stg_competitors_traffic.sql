with source as (
    select
        *
    from {{ source('webanalytics', 'competitors_traffic') }}
),

renamed as (
    select
        lower({{ remove_accents('web_domain') }}) as web_domain,
        to_date(record_day, 'YYYY-MM-DD') as record_date,
        traffic_type,
        sessions as sessions_count,
        to_timestamp_ntz(convert_timezone('UTC', _loaded_at)) as loaded_at_utc
    from source
)

select * from renamed