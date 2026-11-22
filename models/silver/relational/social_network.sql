with source as(
    select
        social_network
    from {{ ref('int_social_account') }}
),

sur_key as(
    select
        distinct *,
        {{ dbt_utils.generate_surrogate_key(['social_network']) }} as social_network_id
    from source
)

select * from sur_key