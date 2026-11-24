with source as (
    select
        *
    from {{ source('webanalytics', 'own_traffic') }}
),

renamed as (
    select
        id as session_id,
        lower({{ remove_accents('web_page') }}) as web_page,
        accessed_at as accessed_at_utc,
        traffic_type,
        source,
        device,
        duration as duration_sec,
        clicks,
        converted,
        to_timestamp_ntz(convert_timezone('UTC', _loaded_at)) as loaded_at_utc
    from source
)

select * from renamed