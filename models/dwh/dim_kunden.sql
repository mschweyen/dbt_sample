{{
  config(
    materialized = 'table'
  )
 }}
with src_kunden_ranked as (
  select
    kunde_id,
	vertriebsweg,
	eroeffnungsdatum,
	status,
	region,
	berater,
	vrb_filialnr,
	vrb_betreuernr,
	change_date                 as valid_from,
	lead(change_date) over (
		partition by kunde_id
		order by change_date
	)                           as valid_from_next
  from {{ ref("stg_kunden") }}
),
src_kunden_scd2 as (
  select
    kunde_id,
	vertriebsweg,
	eroeffnungsdatum,
	status,
	region,
	berater,
	vrb_filialnr,
	vrb_betreuernr,
	valid_from,
  coalesce(valid_from_next -1, cast('9999-12-31' as date)) as valid_to,
  case
  when valid_from_next is null then 1 else 0
  end as is_current
from src_kunden_ranked
)
select *
from src_kunden_scd2
order by kunde_id, valid_from
