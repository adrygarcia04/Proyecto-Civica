with source as(
    select
        gender
    from {{ ref('stg_own_followers') }}
),

sur_key as(
    select
        distinct *,
        {{ dbt_utils.generate_surrogate_key(['gender']) }} as gender_id
    from source
)

select * from sur_key