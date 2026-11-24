with source1 as (
    select
        product,
        description,
        begin_date,
        end_date,
        budget_euros,
        task_owner
    from {{ ref('stg_campaign') }}
),

source2 as (
    select
        full_name,
        dbt_scd_id,
        dbt_valid_from,
        dbt_valid_to
    from {{ ref('snap_task_owner') }}
),

source1_distinct as (
    select distinct *
    from source1
),

source1_modified as (
    select
        * exclude(product, task_owner),
        lower({{ remove_accents('product') }}) as product,
        lower(trim({{ remove_accents('task_owner') }})) as task_owner,
        year(begin_date) as year
    from source1_distinct
),

source2_modified as (
    select
        lower(trim({{ remove_accents('full_name') }})) as full_name,
        dbt_scd_id as task_owner_id,
        dbt_valid_from,
        dbt_valid_to
    from source2
),

enriched as (
    select
        a.* exclude(task_owner),
        b.task_owner_id
    from source1_modified a
    left join source2_modified b
        on a.task_owner = b.full_name
        and a.begin_date >= b.dbt_valid_from
        and (a.begin_date < b.dbt_valid_to or b.dbt_valid_to is null)
),

sur_key as (
    select
        {{ dbt_utils.generate_surrogate_key(['description', 'begin_date', 'end_date']) }} as campaign_id,
        description,
        {{ dbt_utils.generate_surrogate_key(['product', 'year']) }} as product_id,
        begin_date,
        end_date,
        budget_euros,
        task_owner_id
    from enriched
)

select * from sur_key