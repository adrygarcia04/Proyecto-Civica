with source1 as (
    select
        post_date,
        ad_creative,
        url
    from {{ ref('stg_post') }}
),

source2 as (
    select
        *
    from {{ ref('int_social_account') }}
    where bank_name = 'Incivica Bank'
),

source3 as(
    select
        ad_creative,
        ad_creative_id,
        ad_creative_reference_year
    from {{ ref('ad_creative') }}
),

source1_modified as(
    select
        post_date,
        year(post_date) as year,
        lower({{ remove_accents('ad_creative') }}) as ad_creative,
        lower({{ remove_accents('url') }}) as url,
        case regexp_substr(url, '.(instagram|tiktok|facebook|linkedin).', 1, 1, 'e', 1)
            when 'instagram' then 'instagram'
            when 'tiktok' then 'tiktok'
            when 'facebook' then 'facebook'
            when 'linkedin' then 'linkedin'
            else null
        end as social_network
    from source1
),

enriched as(
    select
        a.*,
        b.account_name,
        c.ad_creative_id
    from source1_modified a
    left join source2 b
        on a.social_network = b.social_network
    left join source3 c
        on a.ad_creative = c.ad_creative
        and a.year = c.ad_creative_reference_year
),

sur_key as(
    select
        {{ dbt_utils.generate_surrogate_key(['url']) }} as post_id,
        url,
        post_date,
        ad_creative_id,
        {{ dbt_utils.generate_surrogate_key(['account_name', 'social_network']) }} as social_account_id
    from enriched
)

select * from sur_key