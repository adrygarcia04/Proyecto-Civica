with source as(
    select
        provincia,
        comunidad_ciudad_autonoma,
        pais,
        country
    from {{ ref('provincias') }}
),

modified as(
    select
        distinct provincia as province,
        lower( {{ remove_accents('provincia') }}) as pre_id,
        comunidad_ciudad_autonoma as region,
        pais as country_name_es,
        country as country_name_en
    from source
),

sur_key as(
    select
        * exclude(pre_id),
        {{ dbt_utils.generate_surrogate_key(['pre_id']) }} as province_id
    from modified
)

select * from sur_key