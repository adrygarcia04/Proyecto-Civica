with source as(
    select
        product_name,
        url,
        client_annual_avg_profit,
        year
    from {{ ref('stg_products') }}
),

modified as(
    select
        *,
        lower({{ remove_accents('product_name') }}) as pre_id
    from source
),

sur_key as(
    select
        {{ dbt_utils.generate_surrogate_key(['pre_id', 'year']) }} as product_id,
        product_name,
        {{ dbt_utils.generate_surrogate_key(['url']) }} as web_page_id,
        client_annual_avg_profit,
        year
    from modified
)

select * from sur_key