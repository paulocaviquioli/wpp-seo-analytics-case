select
    dt_date,
    str_page,
    str_device,
    count(*) as qtd
from {{ ref('seo__page_device_daily') }}
group by
    dt_date,
    str_page,
    str_device
having count(*) > 1