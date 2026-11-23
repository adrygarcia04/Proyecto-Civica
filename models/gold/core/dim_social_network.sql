with source as (
    select
        social_network_id,
        case social_network
            when 'instagram' then 'Instagram'
            when 'facebook' then 'Facebook'
            when 'linkedin' then 'LinkedIn'
            when 'tiktok' then 'TikTok'
            else social_network
        end as social_network
    from {{ ref('social_network') }}
)

select * from source