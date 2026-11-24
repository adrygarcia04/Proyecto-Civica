with source as(
    select
        device_id,
        device
    from {{ ref('device') }}
)

select * from source