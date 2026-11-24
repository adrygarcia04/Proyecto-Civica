{{
  config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='competitors_traffic_id'
  )
}}

with source1 as(
    select
        web_domain,
        record_date,
        traffic_type,
        sessions_count,
        loaded_at_utc
    from {{ ref('stg_competitors_traffic') }}
),

source2 as(
    select
        bank_id,
        web_domain
    from {{ ref('bank') }}
),

enriched as(
    select
        a.* exclude(web_domain),
        b.bank_id
    from source1 a
    left join source2 b
        on a.web_domain=b.web_domain
),

modified as(
    select
        * exclude(traffic_type),
        lower({{ remove_accents('traffic_type') }}) as traffic_type,
        null as source
    from enriched
),

sur_key as(
    select
        {{ dbt_utils.generate_surrogate_key(['bank_id', 'record_date', 'traffic_type', 'source']) }} as competitors_traffic_id,
        bank_id,
        record_date,
        {{ dbt_utils.generate_surrogate_key(['traffic_type', 'source']) }} as traffic_type_id,
        sessions_count,
        loaded_at_utc
    from modified
),

deduplicated as(
    select
        * exclude(loaded_at_utc)
    from sur_key
    qualify row_number() over (partition by competitors_traffic_id order by loaded_at_utc desc) = 1
)

select * from deduplicated