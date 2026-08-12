-- Mart A	Wieviel Nettoabsatz haben die Berater im Zeitverlauf akquiriert? Aggregiere auf Berater-Ebene.

select
    k.berater,
    strftime(f.datum, '%Y-%m') as monat,
    sum(nettoabsatz) as sum_nettoabsatz
from {{ ref("fct_bestaende_mittelfluesse") }} f
  join {{ ref("dim_kunden") }} k
    on f.kunde_id = k.kunde_id
    and f.datum between k.valid_from and k.valid_to
group by
    k.berater,
    strftime(f.datum, '%Y-%m')
order by
    k.berater, strftime(f.datum, '%Y-%m')
