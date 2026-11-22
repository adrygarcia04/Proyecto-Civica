{{
  config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='followres_id'
  )
}}

with source1 as(
    select
        followers_id,
        record_date,
        age_range_id,
        gender_id,
        province_id,
        social_account_id,
        followers_count
    from {{ ref('int_own_followers') }}
),

source2 as(
    select
        followers_id,
        record_date,
        age_range_id,
        gender_id,
        province_id,
        social_account_id,
        followers_count
    from {{ ref('int_competitors_followers') }}
),

unified as(
    select
        *
    from source1

    union all

    select
        *
    from source2
)

select * from unified