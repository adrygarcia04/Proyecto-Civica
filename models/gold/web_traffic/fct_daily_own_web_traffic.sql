{{
  config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='session_id'
  )
}}

with product_by_page_year as (
    select
        web_page_id,
        year,
        min(product_id) as product_id,
        min(client_annual_avg_profit) as client_annual_avg_profit
    from {{ ref('products') }}
    group by web_page_id, year
    having count(distinct product_id) = 1
)

select
    t.session_id,
    to_date(t.accessed_at_utc) as activity_date,
    t.accessed_at_utc,
    t.web_page_id,
    w.web_page as url,
    p.product_id,
    m.traffic_channel_id,
    m.traffic_source_id,
    t.device_id,
    t.duration_sec,
    t.clicks,
    coalesce(t.converted, false) as converted,
    case
        when coalesce(t.converted, false) then p.client_annual_avg_profit
        else 0
    end as estimated_profit_euros
from {{ ref('own_traffic') }} t
left join {{ ref('aux_traffic_channel_source') }} m
    on t.traffic_type_id = m.traffic_type_id
left join {{ ref('web_page') }} w
    on t.web_page_id = w.web_page_id
left join product_by_page_year p
    on t.web_page_id = p.web_page_id
    and to_char(t.accessed_at_utc, 'YYYY') = p.year