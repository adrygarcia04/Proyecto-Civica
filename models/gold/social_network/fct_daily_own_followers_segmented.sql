{{
  config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key=['record_date', 'social_network_id', 'age_range_id', 'gender_id', 'province_id']
  )
}} -- Aquí quizás renta una vista sobre followers directamente

select
    f.record_date,
    a.social_network_id,
    f.age_range_id,
    f.gender_id,
    f.province_id,
    sum(f.followers_count) as followers_count
from {{ ref('followers') }} f
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