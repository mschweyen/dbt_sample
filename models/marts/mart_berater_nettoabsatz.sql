--Mart A: Wieviel Nettoabsatz haben die Berater im Zeitverlauf akquiriert? Aggregiere auf Berater Ebene.

with fakten as
(
	select 
		* 
	from {{ ref('fct_kunde_monatsultimo') }}
),

kunde as
(
	select 
		* 
	from {{ ref('dim_kunden') }}
),

--Join on den Surrogatkey: damit hängt jede Faktenzeile an genau der Kundenversion. die am jeweiligen Datum gueltig war 
--inner join, da jede Faktenzeile eine Version haben muss
zuordnung as
(
	select
		k.vrb_filialnr,
		k.vrb_betreuernr,
		f.datum,
		f.kunde_id,
		f.aum,
		f.nettoabsatz

	from fakten f
	inner join kunde k
		on f.kunde_sk = k.kunde_sk
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

--Kumulierter Nettoabsatz je Berater über die Zeit 
select
	vrb_filialnr,
	vrb_betreuernr,
	datum,
	anzahl_kunden,
	aum,
	nettoabsatz,
	sum(nettoabsatz) over w as nettoabsatz_kumuliert

from aggregiert
window w as (partition by vrb_filialnr, vrb_betreuernr order by datum)
order by vrb_filialnr, vrb_betreuernr, datum