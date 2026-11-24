with source as(
    select
        province_id,
        province,
        region,
        country_name_es,
        country_name_en
    from {{ ref('province') }}
)

select * from source