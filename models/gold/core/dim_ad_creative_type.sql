with source as(
    select
        ad_creative_type_id,
        ad_creative_type
    from {{ ref('ad_creative_type') }}
)

select * from source