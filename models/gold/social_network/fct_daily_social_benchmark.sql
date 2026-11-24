{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key=['record_date', 'bank_id', 'social_network_id']
    )
}} -- ¿Procede una incremental?

with accounts as (
    select social_account_id, bank_id, social_network_id
    from {{ ref('social_account') }}
),

followers_daily as (
    select
        f.record_date,
        a.bank_id,
        a.social_network_id,
        sum(f.followers_count) as followers_count
    from {{ ref('followers') }} f
    inner join accounts a
        on f.social_account_id = a.social_account_id
    group by f.record_date, a.bank_id, a.social_network_id
),

interactions as (
    select
        i.report_date as record_date,
        p.social_account_id,
        i.interaction_type_id,
        i.interaction_count
    from {{ ref('own_interactions') }} i
    inner join {{ ref('post') }} p
        on i.post_id = p.post_id

    union all

    select
        record_date,
        social_account_id,
        interaction_type_id,
        interaction_count
    from {{ ref('competitors_interactions') }}
),

interactions_daily as (
    select
        i.record_date,
        a.bank_id,
        a.social_network_id,
        sum(case when t.interaction_type = 'likes' then i.interaction_count else 0 end) as likes,
        sum(case when t.interaction_type = 'comments' then i.interaction_count else 0 end) as comments,
        sum(case when t.interaction_type = 'shares' then i.interaction_count else 0 end) as shares
    from interactions i
    inner join accounts a
        on i.social_account_id = a.social_account_id
    inner join {{ ref('interaction_type') }} t
        on i.interaction_type_id = t.interaction_type_id
    group by i.record_date, a.bank_id, a.social_network_id
),

daily_metrics as (
    select
        coalesce(f.record_date, i.record_date) as record_date,
        coalesce(f.bank_id, i.bank_id) as bank_id,
        coalesce(f.social_network_id, i.social_network_id) as social_network_id,
        f.followers_count,
        coalesce(i.likes, 0) as likes,
        coalesce(i.comments, 0) as comments,
        coalesce(i.shares, 0) as shares
    from followers_daily f
    full outer join interactions_daily i
        on f.record_date = i.record_date
        and f.bank_id = i.bank_id
        and f.social_network_id = i.social_network_id
)

select
    record_date,
    bank_id,
    social_network_id,
    followers_count,
    likes,
    comments,
    shares,
    likes + comments + shares as engagements
from daily_metrics