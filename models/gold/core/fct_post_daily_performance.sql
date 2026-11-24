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
        ad_creative_id,
        social_account_id
    from {{ ref('post') }}
),

own_interactions as(
    select
        post_id,
        report_date,
        interaction_type_id,
        interaction_count,
        loaded_at_utc
    from {{ ref('own_interactions') }} i
    {% if is_incremental() %}
    where i.loaded_at_utc >= {{ carga_desde('loaded_at_utc') }}
    {% endif %}
),

interaction_values as (
    select
        i.post_id,
        i.report_date as activity_date,
        t.interaction_type,
        i.interaction_count
    from own_interactions i
    inner join {{ ref('interaction_type') }} t
        on i.interaction_type_id = t.interaction_type_id
),

interactions_pivoted as (
    select
        post_id,
        activity_date,
        coalesce(likes, 0) as likes,
        coalesce(comments, 0) as comments,
        coalesce(shares, 0) as shares,
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

interactions_loaded as (
    select
        post_id,
        report_date as activity_date,
        max(loaded_at_utc) as loaded_at_utc
    from own_interactions
    group by post_id, report_date
),

interactions_daily as (
    select
        p.post_id,
        p.activity_date,
        p.likes,
        p.comments,
        p.shares,
        p.impressions,
        p.reach,
        l.loaded_at_utc
    from interactions_pivoted p
    inner join interactions_loaded l
        on p.post_id = l.post_id
        and p.activity_date = l.activity_date
),

session_sources as (
    select distinct
        traffic_type_id,
        lower(trim({{ remove_accents('source') }})) as post_url
    from {{ ref('traffic_type') }}
    where source is not null
),

own_traffic as(
    select
        traffic_type_id,
        accessed_at_utc,
        converted,
        loaded_at_utc
    from {{ ref('own_traffic') }} s
    {% if is_incremental() %}
    where s.loaded_at_utc >= {{ carga_desde('loaded_at_utc') }}
    {% endif %}
),

traffic_daily as (
    select
        p.post_id,
        to_date(s.accessed_at_utc) as activity_date,
        count(*) as sessions,
        sum(case when s.converted then 1 else 0 end) as conversions
    from own_traffic s
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
    sa.social_network_id,
    c.product_id,
    a.campaign_id,
    i.likes,
    i.comments,
    i.shares,
    i.likes + i.comments + i.shares as engagements,
    i.impressions,
    i.reach,
    coalesce(t.sessions, 0) as sessions,
    coalesce(t.conversions, 0) as conversions,
    case
        when coalesce(t.conversions, 0) = 0 then 0
        else t.conversions * pr.client_annual_avg_profit
    end as estimated_profit_euros,
    c.task_owner_id,
    p.ad_creative_id,
    a.ad_creative_type_id,
    i.loaded_at_utc
from interactions_daily i
inner join posts p
    on i.post_id = p.post_id
left join {{ ref('social_account') }} sa
    on p.social_account_id = sa.social_account_id
left join {{ ref('ad_creative') }} a
    on p.ad_creative_id = a.ad_creative_id
left join {{ ref('campaign') }} c
    on a.campaign_id = c.campaign_id
left join {{ ref('products') }} pr
    on c.product_id = pr.product_id
left join traffic_daily t
    on i.post_id = t.post_id and i.activity_date = t.activity_date