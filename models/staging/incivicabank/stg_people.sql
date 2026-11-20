with source as (
    select
        nombre,
        dni,
        fecha_de_nacimiento,
        correo,
        area,
        puesto,
        sueldo_anual_bruto,
        iban
    from {{ source('incivicabank', 'people') }}
),

renamed as (
    select
        nombre as full_name,
        dni,
        to_timestamp_ntz(fecha_de_nacimiento, 'DD/MM/YYYY') as birthdate,
        lower({{ remove_accents('correo') }}) as mail,
        area as department,
        puesto as job_title,
        to_number(translate(sueldo_anual_bruto, ',.€', '.')) as annual_salary_euros,
        iban as bank_account
    from source
)

select * from renamed