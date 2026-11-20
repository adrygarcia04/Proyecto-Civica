with source as (
    select
        account,
        date,
        followers,
        daily_added_likes,
        daily_added_comments,
        daily_added_shares,
        _source_file_name
    from {{ source('socialtool', 'competitors') }}
),

renamed as (
    select
        lower(trim(account,'@')) as account_name,
        to_timestamp_ntz(date, 'YYYYMMDD') as record_date,
        followers,
        daily_added_likes as likes,
        daily_added_comments as comments,
        daily_added_shares as shares,
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