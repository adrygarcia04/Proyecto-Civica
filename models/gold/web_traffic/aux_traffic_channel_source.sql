{{ config(materialized='ephemeral') }}

with labels as (
    select
        traffic_type_id,
        lower(trim({{ remove_accents('traffic_type') }})) as traffic_channel,
        case lower(regexp_substr(trim(source),'^(https?://|//)?([a-z0-9-]+[.])*(instagram|facebook|linkedin|tiktok)[.]com([:/?#]|$)',1, 1, 'ie', 3))
            when 'instagram' then 'Instagram'
            when 'facebook' then 'Facebook'
            when 'linkedin' then 'LinkedIn'
            when 'tiktok' then 'TikTok'
            else source
        end as traffic_source
    from {{ ref('traffic_type') }}
),

lookup as (
    select
        traffic_type_id,
        traffic_channel,
        min(traffic_source) as traffic_source
    from labels
    group by traffic_type_id, traffic_channel
)

select
    traffic_type_id,
    {{ dbt_utils.generate_surrogate_key(['traffic_channel']) }} as traffic_channel_id,
    traffic_channel,
    case when traffic_source is not null then
        {{ dbt_utils.generate_surrogate_key(['traffic_source']) }}
    end as traffic_source_id,
    traffic_source
from lookup