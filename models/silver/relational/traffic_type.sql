with source1 as(
    select
        traffic_type,
        source
    from {{ ref('stg_own_traffic') }}
),

source2 as(
    select
        traffic_type
    from {{ ref('stg_competitors_traffic') }}
),

source1_modified as(
    select
        distinct *,
        lower({{ remove_accents('traffic_type') }}) as pre_id1,
        lower({{ remove_accents('source') }}) as pre_id2
    from source1
),

source2_modified as(
    select
        distinct *,
        null as source,
        lower({{ remove_accents('traffic_type') }}) as pre_id1,
        null as pre_id2
    from source2
),

unioned as (
    select
        *
    from source1_modified

    union

    select
        *
    from source2_modified
),

sur_key as(
    select
        {{ dbt_utils.generate_surrogate_key(['pre_id1', 'pre_id2']) }} as traffic_type_id,
        traffic_type,
        source
    from unioned
)

select * from sur_key