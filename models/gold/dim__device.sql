{{
  config(
    materialized = 'table',
    schema = 'gold',
    tags = ['seo', 'dimension', 'device', 'gold']
  )
}}

with devices as (

  select distinct
    str_device
  from {{ ref('seo__page_device_daily') }}

  union

  select distinct
    str_device
  from {{ ref('seo__query_page_device_daily') }}

),

final as (

  select
    md5(coalesce(str_device, '')) as str_device_key,
    str_device
  from devices
  where str_device is not null

)

select
  str_device_key,
  str_device
from final