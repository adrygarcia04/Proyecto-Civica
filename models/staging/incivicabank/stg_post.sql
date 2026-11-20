with source as (
    select
        fecha_de_publicacion,
        contenido,
        urls,
        tipo,
        coste_produccion
    from {{ source('incivicabank', 'post') }}
),

renamed as (
    select
        to_timestamp_ntz(fecha_de_publicacion, 'DD/MM/YYYY') as post_date,
        contenido as ad_creative,
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