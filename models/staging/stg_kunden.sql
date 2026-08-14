--Kunden-Rohdaten aus dem Seed einlesen
with import as
(
	select * from {{ ref('kunden') }}
),

-- vrb_filialnr = Zeichen 1-3 , vrb_betreuernr = Zeichen 4-12 
result as
(
	select
		cast(kunde_id as varchar)                     as kunde_id,
		strptime(changedate, '%d.%m.%Y')::date        as changedate,
		strptime(eroeffnungsdatum, '%d.%m.%Y')::date  as eroeffnungsdatum,
		vertriebsweg,
		status,
		region,
		berater,
		vrb_filial_und_betreuernr_an964,
		substr(vrb_filial_und_betreuernr_an964, 1, 3) as vrb_filialnr,
		substr(vrb_filial_und_betreuernr_an964, 4, 9) as vrb_betreuernr

	from import
)

select * from result