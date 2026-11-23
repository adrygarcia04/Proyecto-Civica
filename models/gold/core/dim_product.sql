with source as(
    select
        product_id,
        product_name
    from {{ ref('products') }}
)

select * from source