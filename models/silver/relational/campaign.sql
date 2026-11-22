with source1 as(
    select
        product,
        description,
        begin_date,
        end_date,
        budget_euros,
        task_owner
    from {{ ref('stg_campaign') }}
),

source2 as(
    select
        full_name,
        mail
    from {{ ref('stg_people') }}
),

source1_distinct as(
    select
        distinct *
    from source1
),

source1_modified as(
    select
        * exclude(product, task_owner),
        lower({{ remove_accents('product') }}) as product,
        lower({{ remove_accents('task_owner') }}) as task_owner,
        year(begin_date) as year,
    from source1_distinct
),

source2_modified as(
    select
        lower({{ remove_accents('full_name') }}) as full_name,
        mail
    from source2
),

enriched as(
    select
        a.* exclude(task_owner),
        b.mail
    from source1_modified a
    left join source2_modified b
        on a.task_owner=b.full_name
),

sur_key as(
    select
        {{ dbt_utils.generate_surrogate_key(['description', 'begin_date', 'end_date']) }} as campaign_id,
        description,
        {{ dbt_utils.generate_surrogate_key(['product', 'year']) }} as product_id,
        begin_date,
        end_date,
        budget_euros,
        {{ dbt_utils.generate_surrogate_key(['mail', 'year']) }} as task_owner_id
    from enriched
)

select * from sur_key