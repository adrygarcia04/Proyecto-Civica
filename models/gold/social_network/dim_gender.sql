with source as(
    select
        gender_id,
        gender
    from {{ ref('gender') }}
)

select * from source