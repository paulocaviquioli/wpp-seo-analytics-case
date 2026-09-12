{{
  config(
    materialized = 'view',
    schema = 'silver',
    tags = ['gsc', 'seo']
  )
}}

with source_data as (

  select
    cast(
      nullif(trim(date), '')
      as date
    ) as dt_date,

    cast(
      nullif(trim(page), '')
      as {{ dbt.type_string() }}
    ) as str_page,

    cast(
      nullif(trim(query), '')
      as {{ dbt.type_string() }}
    ) as str_query,

    cast(
      nullif(trim(device), '')
      as {{ dbt.type_string() }}
    ) as str_device,

    cast(
      nullif(trim(clicks), '')
      as {{ dbt.type_int() }}
    ) as int_clicks,

    cast(
      nullif(trim(impressions), '')
      as {{ dbt.type_int() }}
    ) as int_impressions,

    cast(
      (
        cast(
          nullif(
            replace(
              replace(trim(ctr), '%', ''),
              ',',
              '.'
            ),
            ''
          )
          as numeric(18, 6)
        ) / 100
      )
      as numeric(18, 6)
    ) as flt_ctr,

    cast(
      nullif(
        replace(trim(position), ',', '.'),
        ''
      )
      as numeric(18, 4)
    ) as flt_position,

    cast(
      _airbyte_extracted_at
      as {{ dbt.type_timestamp() }}
    ) as dt_inserted_at

  from {{ source('bronze', 'GSC___Search_Console') }}

)

select
  dt_date,
  str_page,
  str_query,
  str_device,
  int_clicks,
  int_impressions,
  flt_ctr,
  flt_position,
  dt_inserted_at
from source_data