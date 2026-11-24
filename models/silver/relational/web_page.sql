with source1 as(
    select
        web_page
    from {{ ref('stg_own_traffic') }}
),

source2 as(
    select
        bank_id,
        web_domain
    from {{ ref('bank') }}
),

source1_modified as(
    select
        distinct *,
        {{ extract_web_domain('web_page') }} as web_domain
    from source1
),

enriched as(
    select
        a.web_page,
        b.bank_id
    from source1_modified a
    left join source2 b
        on a.web_domain=b.web_domain
),

sur_key as(
    select
        *,
        {{ dbt_utils.generate_surrogate_key(['web_page']) }} as web_page_id,
    from enriched
)

select * from sur_key