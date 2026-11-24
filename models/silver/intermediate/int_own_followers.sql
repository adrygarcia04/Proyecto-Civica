with source1 as(
    select
        loaded_at_utc,
        record_date,
        province,
        age_range,
        gender,
        followers_count,
        social_network
    from {{ ref('stg_own_followers') }}
),

source2 as(
    select
        *
    from {{ ref('int_social_account') }}
    where bank_name = 'Incivica Bank'
),

source1_modified as (
    select
        * exclude(province),
        case lower(trim({{ remove_accents('province') }}))
            when 'guipuzcoa' then 'gipuzkoa'
            when 'islas baleares' then 'illes balears'
            when 'vizcaya' then 'bizkaia'
            else lower(trim({{ remove_accents('province') }}))
        end as province
    from source1
),

enriched as(
    select
        a.*,
        b.account_name
    from source1_modified a
    left join source2 b
        on a.social_network = b.social_network
),

sur_key as(
    select
        {{ dbt_utils.generate_surrogate_key(['record_date', 'age_range', 'gender', 'province', 'account_name', 'social_network']) }} as followers_id,
        loaded_at_utc,
        record_date,
        {{ dbt_utils.generate_surrogate_key(['age_range']) }} as age_range_id,
        {{ dbt_utils.generate_surrogate_key(['gender']) }} as gender_id,
        {{ dbt_utils.generate_surrogate_key(['province']) }} as province_id,
        {{ dbt_utils.generate_surrogate_key(['account_name', 'social_network']) }} as social_account_id,
        followers_count
    from enriched
)

select * from sur_key
