{{
  config(
    materialized = 'table',
    schema = 'gold',
    tags = ['seo', 'dimension', 'query', 'gold']
  )
}}

with queries as (

  select distinct
    str_query
  from {{ ref('seo__query_page_device_daily') }}

),

final as (

  select
    md5(coalesce(str_query, '')) as str_query_key,
    str_query
  from queries
  where str_query is not null

)

select
  str_query_key,
  str_query
from final