{{
  config(
    materialized = 'table',
    schema = 'gold',
    tags = ['seo', 'gsc', 'query', 'gold']
  )
}}

with gsc_aggregated as (

  select
    dt_date,
    str_page,
    str_query,
    str_device,

    sum(int_clicks) as int_clicks,
    sum(int_impressions) as int_impressions,

    cast(
      sum(int_clicks)::numeric
      / nullif(sum(int_impressions), 0)
      as numeric(18, 6)
    ) as flt_ctr,

    cast(
      sum(
        flt_position * int_impressions
      )
      / nullif(sum(int_impressions), 0)
      as numeric(18, 4)
    ) as flt_position

  from {{ ref('gsc__search_console') }}

  group by
    dt_date,
    str_page,
    str_query,
    str_device

)

select
  dt_date,
  str_page,
  str_query,
  str_device,
  int_clicks,
  int_impressions,
  flt_ctr,
  flt_position
from gsc_aggregated