with source as (
    select distinct
        traffic_channel_id,
        traffic_channel
    from {{ ref('aux_traffic_channel_source') }}
    where traffic_channel is not null
)

select * from source