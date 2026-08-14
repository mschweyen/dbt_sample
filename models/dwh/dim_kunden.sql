--Kunden daten (noch Rohdaten) aus dem Staging einlesen 
with import as 
(
	select * from {{ ref('stg_kunden') }}
),

--Hashing über Kunden Attribute, um die Änderungen anhand des Hash-Werts zu erfassen, anstatt die Attribute einzeln zu vergleichen 
--Coalesce, um Nullwerte zu vermeiden
hashed as 
(
    select
        *,
        md5(concat_ws('|',
            coalesce(vertriebsweg, '?'),
            coalesce(status, '?'),
            coalesce(region, '?'),
            coalesce(berater, '?'),
            coalesce(vrb_filial_und_betreuernr_an964, '?'),
            coalesce(cast(eroeffnungsdatum as varchar), '?')
        )) as attribut_hash
    from import
),

--den attribut_hash mit dem nächsten attribut_hash pro Kunde vergleichen und bei einer Änderung diese erfassen
changes_only as 
(
    select 
		*
    from hashed
	qualify attribut_hash is distinct from lag(attribut_hash) over (partition by kunde_id order by changedate)
),

--Erstellung eines SK, der in der Faktentabelle verwendet wird, um genau zuordnen zu können, welcher Datensatz in der Faktentabelle zu welcher Version desselben Kunden gehört
--gültig_ab ist das changedate, und gültig bis dient dazu, das nächste changedate pro Kunde_id minus ein Tag davor zu ermitteln. 
--default gültig_ab für den aktiven Datensatz jedes Kunden lautet 3000-12-31
scd2 as 
(
    select
        md5(concat_ws('|', kunde_id, cast(changedate as varchar))) as kunde_sk,
        kunde_id,
        vertriebsweg,
        eroeffnungsdatum,
        status,
        region,
        berater,
        vrb_filial_und_betreuernr_an964,
        vrb_filialnr,
        vrb_betreuernr,
        changedate as gueltig_ab,
        coalesce((lead(changedate) over w - interval 1 day)::date,date '3000-12-31') as gueltig_bis,
        case 
			when lead(changedate) over w is null then 1 
			else 0 
		end as is_current
        
    from changes_only
    window w as (partition by kunde_id order by changedate)
)

select * from scd2