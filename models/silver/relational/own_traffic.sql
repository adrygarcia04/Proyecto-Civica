{{
  config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='session_id'
  )
}}

with source as(
    select
        session_id,
        web_page,
        accessed_at_utc,
        traffic_type,
        source,
        device,
        duration_sec,
        clicks,
        converted,
        loaded_at_utc
    from {{ ref('stg_own_traffic') }}
),

modified as(
    select
        * exclude(traffic_type, source, device),
        lower({{ remove_accents('traffic_type') }}) as traffic_type,
        lower({{ remove_accents('source') }}) as source,
        lower({{ remove_accents('device') }}) as device
    from source
),

sur_key as(
    select
        session_id,
        {{ dbt_utils.generate_surrogate_key(['web_page']) }} as web_page_id,
        accessed_at_utc,
        {{ dbt_utils.generate_surrogate_key(['traffic_type', 'source']) }} as traffic_type_id,
        {{ dbt_utils.generate_surrogate_key(['device']) }} as device_id,
        duration_sec,
        clicks,
        converted,
        loaded_at_utc
    from modified
),

deduplicated as(
    select
        * exclude(loaded_at_utc)
    from sur_key
    qualify row_number() over (partition by session_id order by loaded_at_utc desc) = 1
)

select * from deduplicated