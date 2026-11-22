with source as (
    select
        *
    from {{ source('incivicabank', 'campaign') }}
),

renamed as (
    select
        producto as product,
        campagna as description,
        to_date(inicio, 'DD/MM/YYYY') as begin_date,
        to_date(fin, 'DD/MM/YYYY') as end_date,
        to_number(translate(presupuesto, ',.€', '.')) as budget_euros,
        responsable as task_owner,
        redes_sociales as social_networks,
        contenido
    from source
),

unpivot as (
    select
        t.product,
        t.description,
        t.begin_date,
        t.end_date,
        t.budget_euros,
        t.task_owner,
        t.social_networks,
        trim(s.value::string) as ad_creative
    from renamed t,
    lateral split_to_table(contenido, ',') s
)

select * from unpivot