select 'stg_people' as origen, report_date as fecha, count(*) as filas
from {{ ref('stg_people') }}
group by report_date

union all

select 'entrada_snapshot' as origen, cast(report_at as date) as fecha, count(*) as filas
from {{ ref('stg_people') }}
group by cast(report_at as date)

order by origen, fecha