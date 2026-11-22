with source as(
    select
        banco,
        nombre_abreviado,
        dominio_web
    from {{ ref('social_accounts_web_domains') }}
),

modified as(
    select
        banco as bank_name,
        nombre_abreviado as short_name,
        dominio_web as web_domain
    from source
),

sur_key as(
    select
        {{ dbt_utils.generate_surrogate_key(['bank_name']) }} as bank_id,
        *
    from modified
)

select * from sur_key