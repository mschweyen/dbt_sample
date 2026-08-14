--Mittelfluss Rohdaten aus dem Seed einlesen
with import as
(
	select * from {{ ref('mittelfluesse') }}
),

result as
(
	select
		cast(kunde_id as varchar)          as kunde_id,
		strptime(datum, '%d.%m.%Y')::date  as datum,
		cast(mittelzufluss as double)      as mittelzufluss,
		cast(mittelabfluss as double)      as mittelabfluss

	from import
)

select * from result