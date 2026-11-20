with source as (
    select
        post_date,
        social_network,
        url,
        likes,
        comments,
        shares,
        impressions,
        reach,
        _source_file_name
    from {{ source('socialtool', 'own_interactions') }}
),

renamed as (
    select
        to_timestamp_ntz(post_date, 'YYYYMMDD') as post_date,
        lower(social_network) as social_network,
        lower({{ remove_accents('url') }}) as url,
        likes,
        comments,
        shares,
        impressions,
        reach,
        to_timestamp_ntz(
            regexp_substr(_source_file_name, '_(\\d{8})_report', 1, 1, 'e', 1),
            'YYYYMMDD'
        ) as report_date
    from source
)

select * from renamed