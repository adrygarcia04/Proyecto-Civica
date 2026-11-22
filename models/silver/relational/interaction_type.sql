with source as(
    select
        interaction_type
    from {{ ref('int_own_interactions') }}
),

sur_key as(
    select
        distinct *,
        {{ dbt_utils.generate_surrogate_key(['interaction_type']) }} as interaction_type_id
    from source
)

select * from sur_key