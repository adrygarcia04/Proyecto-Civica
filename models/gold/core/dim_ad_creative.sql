with source as(
    select
        ad_creative_id,
        ad_creative,
        ad_creative_cost_euros
    from {{ ref('ad_creative') }}
)

select * from source