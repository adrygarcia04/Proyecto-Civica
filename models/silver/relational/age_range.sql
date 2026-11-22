with source as(
    select
        age_range
    from {{ ref('stg_own_followers') }}
),

sur_key as(
    select
        distinct *,
        {{ dbt_utils.generate_surrogate_key(['age_range']) }} as age_range_id
    from source
)

select * from sur_key