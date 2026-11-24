with source as (
    select distinct
        traffic_source_id,
        traffic_source
    from {{ ref('aux_traffic_channel_source') }}
    where traffic_source is not null
)

select * from source