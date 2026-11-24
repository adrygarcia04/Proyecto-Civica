{{
  config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='own_interactions_id'
  )
}}

with source as(
    select
        *
    from {{ ref('int_own_interactions') }}
    {% if is_incremental() %}
    where loaded_at_utc >= {{ carga_desde('loaded_at_utc') }}
    {% endif %}
),

sur_key as(
    select
        {{ dbt_utils.generate_surrogate_key(['report_date', 'url', 'interaction_type']) }} as own_interactions_id,
        report_date,
        {{ dbt_utils.generate_surrogate_key(['url']) }} as post_id,
        {{ dbt_utils.generate_surrogate_key(['interaction_type']) }} as interaction_type_id,
        interaction_count,
        loaded_at_utc
    from source
),

deduplicated as(
    select
        *
    from sur_key
    qualify row_number() over (partition by own_interactions_id order by loaded_at_utc desc, interaction_count desc nulls last) = 1
)

select * from deduplicated
