--Bestaende und Mittelfluesse aus dem Staging sowie die historisierte Kunden Daten aus dim_kunden einlesen
with bestaende as
(
	select * from {{ ref('stg_bestaende') }}
),

mittelfluesse as
(
	select * from {{ ref('stg_mittelfluesse') }}
),

kunde as
(
	select * from {{ ref('dim_kunden') }}
),

--Kennzahlen zusammenfuehren; bestaende ist die fuehrende Tabelle, (Hinweis: Zu jedem Kunden in mittelfluesse existiert ein entsprechender Eintrag in bestaende.)
--Left Join, damit auch Kundenmonate ohne Mittelfluss erhalten bleiben
kennzahlen as
(
	select
		b.kunde_id,
		b.datum,
		b.aum,
		coalesce(m.mittelzufluss, 0) as mittelzufluss,
		coalesce(m.mittelabfluss, 0) as mittelabfluss,
		coalesce(m.mittelzufluss, 0) - coalesce(m.mittelabfluss, 0) as nettoabsatz

	from bestaende b
	left join mittelfluesse m
		on  
			b.kunde_id = m.kunde_id and 
			b.datum = m.datum
),

--Zeitpunktgenaue Zuordnung der gültigen Kundenversion über das SCD2 Intervallen
--Damit hängt jede Faktenzeile an dem Datensatz, der am jeweiligen Monatsultimo gültig war
mit_dimension as
(
	select
		k.kunde_sk,
		f.kunde_id,
		f.datum,
		f.aum,
		f.mittelzufluss,
		f.mittelabfluss,
		f.nettoabsatz

	from kennzahlen f
	left join kunde k
		on  f.kunde_id = k.kunde_id
		and f.datum between k.gueltig_ab and k.gueltig_bis
)

select * from mit_dimension