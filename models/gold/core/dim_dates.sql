{{
    config(
        pre_hook="alter session set week_start = 0",
        post_hook="alter session unset week_start"
    )
}}

with spine as (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2025-01-01' as date)",
        end_date="cast('2025-12-31' as date)"
    ) }}
),

final as (
    select
        date_day::date as date_day,
        year(date_day) * 10000 + month(date_day) * 100 + day(date_day) as date_id,
        year(date_day) as year,
        quarter(date_day) as quarter,
        month(date_day) as month,
        monthname(date_day) as month_name,
        weekiso(date_day) as iso_week,
        dayofweek(date_day) as day_of_week,
        dayname(date_day) as day_name,
        dayofweek(date_day) in (0, 6) as is_weekend
    from spine
)

select * from final