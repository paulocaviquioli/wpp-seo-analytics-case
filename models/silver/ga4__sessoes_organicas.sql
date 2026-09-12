{{
  config(
    materialized = 'view',
    schema = 'silver',
    tags = ['ga4', 'seo']
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
      nullif(trim(device), '')
      as {{ dbt.type_string() }}
    ) as str_device,

    cast(
      nullif(trim(channel), '')
      as {{ dbt.type_string() }}
    ) as str_channel,

    cast(
      nullif(trim(sessions), '')
      as {{ dbt.type_int() }}
    ) as int_sessions,

    cast(
      nullif(trim(conversions), '')
      as {{ dbt.type_int() }}
    ) as int_conversions,

    cast(
      nullif(trim(engaged_sessions), '')
      as {{ dbt.type_int() }}
    ) as int_engaged_sessions,

    cast(
      nullif(
        replace(trim(revenue), ',', '.'),
        ''
      )
      as numeric(18, 2)
    ) as flt_revenue,

    cast(
      (
        cast(
          nullif(
            replace(
              replace(trim(engagement_rate), '%', ''),
              ',',
              '.'
            ),
            ''
          )
          as numeric(18, 6)
        ) / 100
      )
      as numeric(18, 6)
    ) as flt_engagement_rate,

    cast(
      nullif(
        replace(trim(avg_engagement_time_sec), ',', '.'),
        ''
      )
      as numeric(18, 2)
    ) as flt_avg_engagement_time_sec,

    cast(
      _airbyte_extracted_at
      as {{ dbt.type_timestamp() }}
    ) as dt_inserted_at

  from {{ source('bronze', 'GA4___Sessoes_organicas') }}

)

select
  dt_date,
  str_page,
  str_device,
  str_channel,
  int_sessions,
  int_conversions,
  int_engaged_sessions,
  flt_revenue,
  flt_engagement_rate,
  flt_avg_engagement_time_sec,
  dt_inserted_at
from source_data