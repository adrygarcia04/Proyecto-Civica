{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key=['record_date', 'bank_id', 'traffic_channel_id']
    )
}}

with own_traffic as(
    select
        activity_date,
        traffic_channel_id,
        loaded_at_utc
    from {{ ref('fct_daily_own_web_traffic') }} t
    {% if is_incremental() %}
    where t.loaded_at_utc >= {{ carga_desde('loaded_at_utc') }}
    {% endif %}
),

own_daily as (
    select
        t.activity_date as record_date,
        b.bank_id,
        t.traffic_channel_id,
        count(*) as sessions_count,
        max(t.loaded_at_utc) as loaded_at_utc
    from own_traffic t
    cross join (
        select bank_id
        from {{ ref('bank') }}
        where bank_name = 'Incivica Bank'
    ) b
    group by t.activity_date, b.bank_id, t.traffic_channel_id
),

competitors_traffic as(
    select
        record_date,
        bank_id,
        traffic_type_id,
        sessions_count,
        loaded_at_utc
    from {{ ref('competitors_traffic') }} c
    {% if is_incremental() %}
    where c.loaded_at_utc >= {{ carga_desde('loaded_at_utc') }}
    {% endif %}
),

competitors_daily as (
    select
        c.record_date,
        c.bank_id,
        m.traffic_channel_id,
        sum(c.sessions_count) as sessions_count,
        max(c.loaded_at_utc) as loaded_at_utc
    from competitors_traffic c
    left join {{ ref('aux_traffic_channel_source') }} m
        on c.traffic_type_id = m.traffic_type_id
    group by c.record_date, c.bank_id, m.traffic_channel_id
)

select
    record_date,
    bank_id,
    traffic_channel_id,
    sessions_count,
    loaded_at_utc
from own_daily
union all
select
    record_date,
    bank_id,
    traffic_channel_id,
    sessions_count,
    loaded_at_utc
from competitors_daily