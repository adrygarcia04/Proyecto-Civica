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
),

sur_key as(
    select
        {{ dbt_utils.generate_surrogate_key(['report_date', 'url', 'interaction_type']) }} as own_interactions_id,
        report_date,
        {{ dbt_utils.generate_surrogate_key(['url']) }} as post_id,
        {{ dbt_utils.generate_surrogate_key(['interaction_type']) }} as interaction_type_id,
        interaction_count
    from source
),

deduplicated as(
    select
        *
    from sur_key
    qualify row_number() over (partition by own_interactions_id order by interaction_count asc) = 1
)

select * from deduplicated