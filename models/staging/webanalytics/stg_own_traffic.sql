with source as (
    select
        id,
        web_page,
        accessed_at,
        traffic_type,
        source,
        device,
        duration,
        clicks,
        converted
    from {{ source('webanalytics', 'own_traffic') }}
),

renamed as (
    select
        id as session_id,
        lower({{ remove_accents('web_page') }}),
        accessed_at as accessed_at_utc,
        traffic_type,
        source,
        lower({{ remove_accents('source') }}) as clean_source,
        device,
        duration as duration_sec,
        clicks,
        converted
    from source
)

select * from renamed