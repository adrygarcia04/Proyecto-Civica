with source as (
    select
        *
    from {{ source('socialtool', 'own_followers') }}
),

renamed as (
    select
        to_date(date, 'YYYYMMDD') as record_date,
        province,
        age as age_range,
        gender,
        followers as followers_count,
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