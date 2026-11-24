with source as(
    select
        ad_creative_type
    from {{ ref('stg_post') }}
),

distinct_and_lower as(
    select
        distinct *,
        lower({{ remove_accents('ad_creative_type') }}) as pre_id
    from source
),

sur_key as(
    select
        ad_creative_type,
        {{ dbt_utils.generate_surrogate_key(['pre_id']) }} as ad_creative_type_id
    from distinct_and_lower
)

select * from sur_key