with source as(
    select
        bank_id,
        bank_name,
        short_name
    from {{ ref('bank') }}
)

select * from source