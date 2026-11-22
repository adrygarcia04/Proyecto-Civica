with source1 as(
    select
        ad_creative,
        ad_creative_type,
        ad_creative_cost_euros
    from {{ ref('stg_post') }}
),

source2 as(
    select
        ad_creative,
        description,
        begin_date,
        end_date
    from {{ ref('stg_campaign') }}
),

source1_distinct as(
    select
        distinct *
    from source1
),

source1_modified as(
    select
        * exclude(ad_creative_type),
        lower({{ remove_accents('ad_creative_type') }}) as ad_creative_type
    from source1_distinct
),

source2_distinct as(
    select
        distinct *
    from source2
),

source2_modified as(
    select * exclude(ad_creative),
    lower({{ remove_accents('ad_creative') }}) as ad_creative
    from source2_distinct
),

enriched as(
    select
        a.*,
        b.* exclude(ad_creative)
    from source1_modified a
    left join source2_modified b
        on a.ad_creative=b.ad_creative
),

sur_key as(
    select
        {{ dbt_utils.generate_surrogate_key(['description', 'begin_date', 'end_date']) }} as campaign_id,
        {{ dbt_utils.generate_surrogate_key(['ad_creative', 'campaign_id']) }} as ad_creative_id,
        ad_creative,
        {{ dbt_utils.generate_surrogate_key(['ad_creative_type']) }} as ad_creative_type_id,
        ad_creative_cost_euros
    from enriched
)

select * from sur_key