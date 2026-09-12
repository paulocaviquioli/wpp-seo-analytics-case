{{
  config(
    materialized = 'table',
    schema = 'gold',
    tags = ['seo', 'ga4', 'gsc', 'gold']
  )
}}

with ga4_aggregated as (

  select
    dt_date,
    str_page,
    str_device,

    sum(int_sessions) as int_sessions,
    sum(int_conversions) as int_conversions,
    sum(int_engaged_sessions) as int_engaged_sessions,
    sum(flt_revenue) as flt_revenue,

    cast(
      sum(int_engaged_sessions)::numeric
      / nullif(sum(int_sessions), 0)
      as numeric(18, 6)
    ) as flt_engagement_rate,

    cast(
      sum(
        flt_avg_engagement_time_sec * int_sessions
      )
      / nullif(sum(int_sessions), 0)
      as numeric(18, 2)
    ) as flt_avg_engagement_time_sec

  from {{ ref('ga4__sessoes_organicas') }}

  group by
    dt_date,
    str_page,
    str_device

),

gsc_aggregated as (

  select
    dt_date,
    str_page,
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
    str_device

),

combined as (

  select
    coalesce(g.dt_date, s.dt_date) as dt_date,
    coalesce(g.str_page, s.str_page) as str_page,
    coalesce(g.str_device, s.str_device) as str_device,

    g.int_sessions,
    g.int_conversions,
    g.int_engaged_sessions,
    g.flt_revenue,
    g.flt_engagement_rate,
    g.flt_avg_engagement_time_sec,

    s.int_clicks,
    s.int_impressions,
    s.flt_ctr,
    s.flt_position

  from ga4_aggregated g

  full outer join gsc_aggregated s
    on g.dt_date = s.dt_date
   and g.str_page = s.str_page
   and g.str_device = s.str_device

),

final as (

  select
    dt_date,
    str_page,
    str_device,

    coalesce(int_sessions, 0) as int_sessions,
    coalesce(int_conversions, 0) as int_conversions,
    coalesce(int_engaged_sessions, 0) as int_engaged_sessions,

    cast(
      coalesce(flt_revenue, 0)
      as numeric(18, 2)
    ) as flt_revenue,

    flt_engagement_rate,
    flt_avg_engagement_time_sec,

    coalesce(int_clicks, 0) as int_clicks,
    coalesce(int_impressions, 0) as int_impressions,

    flt_ctr,
    flt_position,

    cast(
      int_conversions::numeric
      / nullif(int_sessions, 0)
      as numeric(18, 6)
    ) as flt_conversion_rate,

    cast(
      flt_revenue
      / nullif(int_sessions, 0)
      as numeric(18, 4)
    ) as flt_revenue_per_session

  from combined

)

select
  dt_date,
  str_page,
  str_device,

  int_sessions,
  int_conversions,
  int_engaged_sessions,

  flt_revenue,
  flt_conversion_rate,
  flt_revenue_per_session,

  flt_engagement_rate,
  flt_avg_engagement_time_sec,

  int_clicks,
  int_impressions,
  flt_ctr,
  flt_position

from final