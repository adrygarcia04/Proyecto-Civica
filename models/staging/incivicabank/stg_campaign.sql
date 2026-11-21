with source as (
    select
        producto,
        campagna,
        inicio,
        fin,
        presupuesto,
        responsable,
        redes_sociales,
        contenido
    from {{ source('incivicabank', 'campaign') }}
),

renamed as (
    select
        producto as product,
        campagna as description,
        to_timestamp_ntz(inicio, 'DD/MM/YYYY') as begin_date,
        to_timestamp_ntz(fin, 'DD/MM/YYYY') as end_date,
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