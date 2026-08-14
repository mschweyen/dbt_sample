--Bestands (Monatsultimo AuM) Rohdaten aus dem Seed einlesen
with import as
(
	select * from {{ ref('bestaende') }}
),

result as
(
	select
		cast(kunde_id as varchar)          as kunde_id,
		strptime(datum, '%d.%m.%Y')::date  as datum,
		cast(aum as double)                as aum

	from import
)

select * from result
