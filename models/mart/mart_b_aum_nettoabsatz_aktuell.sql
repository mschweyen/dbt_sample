
-- MART_B
-- Mart B	Der Berater benötigt eine Übersicht wie sich AuM und Nettoabsatz seines aktuelles Kundenbuch entwickelt haben.
------------------------------------------------------------------------------------------------------------------------

select
    k.berater,
    strftime(f.datum, '%Y-%m') as monat,
    array_agg(f.kunde_id)         as kunde_agg,
    sum(aum)            as sum_aum,
    sum(nettoabsatz) as sum_nettoabsatz
from {{ ref("fct_bestaende_mittelfluesse") }} f
  join {{ ref("dim_kunden") }} k
    on f.kunde_id = k.kunde_id
{#--     and f.datum between k.valid_from and k.valid_to#}
{#-- depends on: needed statistics over whole time or only since his activity#}
    and k.is_current = 1
{#where berater in (    'Stewart, Sam'  )#}
group by
    k.berater,
    strftime(f.datum, '%Y-%m')
order by
    k.berater,
    strftime(f.datum, '%Y-%m')

