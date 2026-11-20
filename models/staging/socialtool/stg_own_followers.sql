with source as (
    select
        date,
        province,
        age,
        gender,
        followers,
        _source_file_name
    from {{ source('socialtool', 'own_followers') }}
),

renamed as (
    select
        to_timestamp_ntz(date, 'YYYYMMDD') as record_date,
        province,
        age as age_range,
        gender,
        followers,
        case regexp_substr(_source_file_name, '_(ig|tk|fb|lk)_', 1, 1, 'e', 1)
            when 'ig' then 'instagram'
            when 'tk' then 'tiktok'
            when 'fb' then 'facebook'
            when 'lk' then 'linkedin'
            else null
        end as social_network
    from source
)

select * from renamed