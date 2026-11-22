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

source1_modified as(
    select
        post_date,
        year(post_date) as year,
        lower({{ remove_accents('ad_creative') }}) as ad_creative,
        lower({{ remove_accents('url') }}) as url,
        case regexp_substr(url, '.(instagram,tiktok,facebook,linkedin).', 1, 1, 'e', 1)
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
        b.account_name
    from source1_modified a
    left join source2 b
        on a.social_network = b.social_network
),

sur_key as(
    select
        {{ dbt_utils.generate_surrogate_key(['url']) }} as post_id,
        url,
        post_date,
        {{ dbt_utils.generate_surrogate_key(['ad_creative', 'year']) }} as ad_creative_id,
        {{ dbt_utils.generate_surrogate_key(['account_name']) }} as social_account_id
    from enriched
)

select * from sur_key