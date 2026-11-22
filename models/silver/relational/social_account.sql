with source as(
    select
        *
    from {{ ref('int_social_account') }}
),

sur_key as(
    select
        {{ dbt_utils.generate_surrogate_key(['account_name', 'social_network']) }} as social_account_id,
        account_name,
        {{ dbt_utils.generate_surrogate_key(['bank_name']) }} as bank_id,
        {{ dbt_utils.generate_surrogate_key(['social_network']) }} as social_network_id
    from source
)

select * from sur_key