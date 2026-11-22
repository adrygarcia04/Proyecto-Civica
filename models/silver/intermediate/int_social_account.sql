with source as(
    select
        banco as bank_name,
        instagram,
        tiktok,
        facebook,
        linkedin
    from {{ ref('social_accounts_web_domains') }}
),

unpivot as(
    select
        *
    from source
    unpivot(
        account_name for social_network in (instagram, tiktok, facebook, linkedin)
    )
),

lower as(
    select
        * exclude(social_network, account_name),
        lower(social_network) as social_network,
        lower(trim(account_name,'@')) as account_name
    from unpivot
)

select * from lower