with source as(
    select
        *
    from {{ source('incivicabank', 'products') }}
),

renamed as (
    select
        producto as product_name,
        lower({{ remove_accents('url_producto')}}) as url,
        to_number(translate(beneficio_anual_medio_por_cliente, ',.€', '.')) as client_annual_avg_profit,
        regexp_substr(_source_file_name, '[0-9]{4}') as year
    from source
)

select * from renamed