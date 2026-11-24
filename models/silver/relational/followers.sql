{{
  config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='followers_id'
  )
}}

with own as (
    select
        *,
        'own_followers' as source_system
    from {{ ref('int_own_followers') }}
    {% if is_incremental() %}
    where loaded_at_utc >= {{ carga_desde('loaded_at_utc', 'own_followers') }}
    {% endif %}
),

competitors as (
    select
        *,
        'competitors' as source_system
    from {{ ref('int_competitors_followers') }}
    {% if is_incremental() %}
    where loaded_at_utc >= {{ carga_desde('loaded_at_utc', 'competitors') }}
    {% endif %}
),

observations as (
    select * from own
    union all by name
    select * from competitors
)

select
    followers_id,
    record_date,
    age_range_id,
    gender_id,
    province_id,
    social_account_id,
    followers_count,
    source_system,
    loaded_at_utc
from observations
qualify row_number() over (
    partition by source_system, followers_id
    order by loaded_at_utc desc, followers_count desc nulls last
) = 1
