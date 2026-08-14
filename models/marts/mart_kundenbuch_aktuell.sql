--Mart B: Der Berater benötigt eine Übersicht wie sich AuM und Nettoabsatz seines aktuelles Kundenbuch entwickelt haben.
--Sicht auf das Aktuelle Kundenbuch: es sind die Kunden, die dem Berater aktuell zugeordnet sind (is_current = 1). 
with fakten as
(
	select 
		* 
	from {{ ref('fct_kunde_monatsultimo') }}
),

aktuelles_kundenbuch as
(
	select 
		* 
	from {{ ref('dim_kunden') }}
	where is_current = 1
),

--Join on kunde_id statt kunde_sk: damit die gesamte Historie des Kunden am aktuellen Berater hängt
zuordnung as
(
	select
		k.vrb_filialnr,
		k.vrb_betreuernr,
		k.region,
		f.datum,
		f.kunde_id,
		f.aum,
		f.nettoabsatz

	from fakten f
	inner join aktuelles_kundenbuch k
		on f.kunde_id = k.kunde_id
),

--Aggregation auf Berater und Monatsebene
aggregiert as
(
	select
		vrb_filialnr,
		vrb_betreuernr,
		datum,
		count(distinct kunde_id) as anzahl_kunden,
		sum(aum) as aum,
		sum(nettoabsatz) as nettoabsatz

	from zuordnung
	group by 1, 2, 3
)

--kumulierter Nettoabsatz sowie AuM Veränderung zum Vormonat : lag()
select
	vrb_filialnr,
	vrb_betreuernr,
	datum,
	anzahl_kunden,
	aum,
	aum - lag(aum) over w as aum_delta,
	nettoabsatz,
	sum(nettoabsatz) over w as nettoabsatz_kumuliert

from aggregiert
window w as (partition by vrb_filialnr, vrb_betreuernr order by datum)
order by vrb_filialnr, vrb_betreuernr, datum