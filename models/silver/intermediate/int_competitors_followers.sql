with source as(
    select
        account_name,
        loaded_at_utc,
        record_date,
        followers_count,
        social_network
    from {{ ref('stg_competitors') }}
),

modified as(
    select
        *,
        null as age_range_id,
        null as gender_id,
        null as province_id
    from source
),

sur_key as(
    select
        {{ dbt_utils.generate_surrogate_key(['record_date', 'age_range_id', 'gender_id', 'province_id', 'account_name', 'social_network']) }} as followers_id,
        loaded_at_utc,
        record_date,
        age_range_id,
        gender_id,
        province_id,
        {{ dbt_utils.generate_surrogate_key(['account_name', 'social_network']) }} as social_account_id,
        followers_count
    from modified
)

select * from sur_key
