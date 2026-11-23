{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key=['record_date', 'bank_id', 'traffic_channel_id']
    )
}} -- ¿Procede una incremental?

with own_daily as (
    select
        t.activity_date as record_date,
        b.bank_id,
        t.traffic_channel_id,
        count(*) as sessions_count
    from {{ ref('fct_own_web_traffic') }} t
    cross join (
        select bank_id
        from {{ ref('bank') }}
        where bank_name = 'Incivica Bank'
    ) b
    group by t.activity_date, b.bank_id, t.traffic_channel_id
),

competitors_daily as (
    select
        c.record_date,
        c.bank_id,
        m.traffic_channel_id,
        sum(c.sessions_count) as sessions_count
    from {{ ref('competitors_traffic') }} c
    left join {{ ref('int_traffic_channel_source') }} m
        on c.traffic_type_id = m.traffic_type_id
    group by c.record_date, c.bank_id, m.traffic_channel_id
)

select record_date, bank_id, traffic_channel_id, sessions_count from own_daily
union all
select record_date, bank_id, traffic_channel_id, sessions_count from competitors_daily