{{
  config(
    materialized = 'table',
    schema = 'gold',
    tags = ['seo', 'dimension', 'page', 'gold']
  )
}}

with pages as (

  select distinct
    str_page
  from {{ ref('seo__page_device_daily') }}

  union

  select distinct
    str_page
  from {{ ref('seo__query_page_device_daily') }}

),

final as (

  select
    md5(coalesce(str_page, '')) as str_page_key,
    str_page
  from pages
  where str_page is not null

)

select
  str_page_key,
  str_page
from final