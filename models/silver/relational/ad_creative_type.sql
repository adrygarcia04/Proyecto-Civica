with source as(
    select
        ad_creative_type,
    from {{ ref('stg_post') }}
),

sur_key as(
    select
        distinct *,
        {{ dbt_utils.generate_surrogate_key(['ad_creative_type']) }} as ad_creative_type_id
    from source
)

select * from sur_key