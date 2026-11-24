with source as(
    select
        url,
        likes,
        comments,
        shares,
        impressions,
        reach,
        loaded_at_utc,
        report_date
    from {{ ref('stg_own_interactions') }}
),

unpivot as(
    select
        *
    from source
    unpivot(
        interaction_count for interaction_type in (likes, comments, shares, impressions, reach)
    )
),

lower as(
    select
        * exclude(interaction_type),
        lower(interaction_type) as interaction_type
    from unpivot
)

select * from lower
