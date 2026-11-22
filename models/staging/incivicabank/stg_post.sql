with source as (
    select
        *
    from {{ source('incivicabank', 'post') }}
),

renamed as (
    select
        to_date(fecha_de_publicacion, 'DD/MM/YYYY') as post_date,
        lower({{ remove_accents('contenido')}}) as ad_creative,
        urls,
        tipo as ad_creative_type,
        to_number(translate(coste_produccion, ',.€', '.')) as ad_creative_cost_euros
    from source
),

unpivot as (
    select
        t.post_date,
        t.ad_creative,
        t.ad_creative_type,
        t.ad_creative_cost_euros,
        trim(s.value::string) as url
    from renamed t,
    lateral split_to_table(urls, ',') s
)

select * from unpivot