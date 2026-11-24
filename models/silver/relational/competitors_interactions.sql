{{
  config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='competitors_interactions_id'
  )
}}

with source as(
    select
        loaded_at_utc,
        account_name,
        record_date,
        likes,
        comments,
        shares,
        social_network
    from {{ ref('stg_competitors') }}
    {% if is_incremental() %}
    where loaded_at_utc >= {{ carga_desde('loaded_at_utc') }}
    {% endif %}
),

unpivot as(
    select
        *
    from source
    unpivot(
        interaction_count for interaction_type in (likes, comments, shares)
    )
),

lower as(
    select
        * exclude(interaction_type),
        lower(interaction_type) as interaction_type
    from unpivot
),

sur_key as(
    select
        {{ dbt_utils.generate_surrogate_key(['account_name', 'social_network', 'record_date', 'interaction_type']) }} as competitors_interactions_id,
        {{ dbt_utils.generate_surrogate_key(['account_name', 'social_network']) }} as social_account_id,
        record_date,
        {{ dbt_utils.generate_surrogate_key(['interaction_type']) }} as interaction_type_id,
        interaction_count,
        loaded_at_utc
    from lower
),

deduplicated as(
    select
        *
    from sur_key
    qualify row_number() over (partition by competitors_interactions_id order by loaded_at_utc desc, interaction_count desc nulls last) = 1
)

select * from deduplicated
