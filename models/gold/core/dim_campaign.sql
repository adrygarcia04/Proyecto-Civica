with source as(
    select
        campaign_id,
        description,
        begin_date,
        end_date,
        budget_euros
    from {{ ref('campaign') }}
)

select * from source