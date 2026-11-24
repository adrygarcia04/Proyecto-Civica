{{
  config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key=['record_date', 'social_network_id', 'age_range_id', 'gender_id', 'province_id']
  )
}}

with followers as(
    select
        record_date,
        age_range_id,
        gender_id,
        province_id,
        followers_count,
        social_account_id,
        loaded_at_utc
    from {{ ref('followers') }} f
    {% if is_incremental() %}
    where f.loaded_at_utc >= {{ carga_desde('loaded_at_utc') }}
    {% endif %}
)

select
    f.record_date,
    a.social_network_id,
    f.age_range_id,
    f.gender_id,
    f.province_id,
    sum(f.followers_count) as followers_count,
    max(f.loaded_at_utc) as loaded_at_utc
from followers f
inner join {{ ref('social_account') }} a
    on f.social_account_id = a.social_account_id
inner join {{ ref('bank') }} b
    on a.bank_id = b.bank_id
where b.bank_name = 'Incivica Bank'
group by
    f.record_date,
    a.social_network_id,
    f.age_range_id,
    f.gender_id,
    f.province_id