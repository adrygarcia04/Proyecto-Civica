with source as (
    select
        *
    from {{ source('incivicabank', 'people') }}
),

renamed as (
    select
        nombre as full_name,
        dni,
        to_date(fecha_de_nacimiento, 'DD/MM/YYYY') as birthdate,
        lower({{ remove_accents('correo') }}) as mail,
        area as department,
        puesto as job_title,
        regexp_substr(_source_file_name, '[0-9]{4}') as year
    from source
)

select * from renamed