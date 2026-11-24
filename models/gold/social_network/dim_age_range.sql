with source as(
    select
        age_range_id,
        age_range
    from {{ ref('age_range') }}
)

select * from source