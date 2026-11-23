{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key=['post_id', 'activity_date']
    )
}}

with posts as (
    select
        post_id,
        url,
        ad_creative_id
    from {{ ref('post') }}
),

interaction_values as (
    select
        i.post_id,
        i.report_date as activity_date,
        t.interaction_type,
        i.interaction_count
    from {{ ref('own_interactions') }} i
    inner join {{ ref('interaction_type') }} t
        on i.interaction_type_id = t.interaction_type_id
),

interactions_daily as (
    select
        post_id,
        activity_date,
        likes,
        comments,
        shares,
        impressions,
        reach
    from interaction_values
    pivot (
        max(interaction_count) for interaction_type in (
            'likes' as likes,
            'comments' as comments,
            'shares' as shares,
            'impressions' as impressions,
            'reach' as reach
        )
    )
),

session_sources as (
    select distinct
        traffic_type_id,
        lower(trim({{ remove_accents('source') }})) as post_url
    from {{ ref('traffic_type') }}
    where source is not null
),

traffic_daily as (
    select
        p.post_id,
        to_date(s.accessed_at_utc) as activity_date,
        count(*) as sessions,
        sum(case when s.converted then 1 else 0 end) as conversions
    from {{ ref('own_traffic') }} s
    inner join session_sources src
        on s.traffic_type_id = src.traffic_type_id
    inner join posts p
        on src.post_url = p.url
    group by p.post_id, to_date(s.accessed_at_utc)
)

select
    i.post_id,
    p.url,
    i.activity_date,
    c.product_id,
    a.campaign_id,
    i.likes,
    i.comments,
    i.shares,
    i.impressions,
    i.reach,
    coalesce(t.sessions, 0) as sessions,
    coalesce(t.conversions, 0) as conversions,
    case
        when coalesce(t.conversions, 0) = 0 then 0
        else t.conversions * pr.client_annual_avg_profit
    end as estimated_profit_euros,
    c.task_owner_id,
    p.ad_creative_id
from interactions_daily i
inner join posts p
    on i.post_id = p.post_id
left join {{ ref('ad_creative') }} a
    on p.ad_creative_id = a.ad_creative_id
left join {{ ref('campaign') }} c
    on a.campaign_id = c.campaign_id
left join {{ ref('products') }} pr
    on c.product_id = pr.product_id
left join traffic_daily t
    on i.post_id = t.post_id and i.activity_date = t.activity_date