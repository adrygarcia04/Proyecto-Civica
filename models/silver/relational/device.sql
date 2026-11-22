with source as(
    select
        device
    from {{ ref('stg_own_traffic') }}
),

modified as(
    select
        distinct *,
        lower({{ remove_accents('device') }}) as pre_id
    from source
),

sur_key as(
    select
        device,
        {{ dbt_utils.generate_surrogate_key(['pre_id']) }} as device_id,
    from modified
)

select * from sur_key