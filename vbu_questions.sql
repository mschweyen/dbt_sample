
-- question: is it okay if 'berater' and 'vrb_betreuernr' dont fit together, like in example below?
------------------------------------------------------------------------------------------------------------------------
select *
from src_kunden
where kunde_id = 'DV2798587'
order by change_date
;
{#+-----------+-----------------+----------------+------+------------------------+------------------+------------+--------------+---------+#}
{#|change_date|vertriebsweg     |eroeffnungsdatum|status|region                  |berater           |vrb_filialnr|vrb_betreuernr|kunde_id |#}
{#+-----------+-----------------+----------------+------+------------------------+------------------+------------+--------------+---------+#}
{#|01.01.2025 |DZ-PrivateBanking|27.12.2024      |aktiv |Region Baden-Württemberg|Henderson, Dainton|012         |900015707     |DV2798587|#}
{#|14.04.2025 |DZ-PrivateBanking|27.12.2024      |aktiv |Region Baden-Württemberg|Hall, Chester     |012         |900015707     |DV2798587|#}
{#|18.06.2025 |DZ-PrivateBanking|27.12.2024      |aktiv |Region Baden-Württemberg|Hall, Chester     |012         |900000000     |DV2798587|#}
{#|29.05.2026 |DZ-PrivateBanking|27.12.2024      |aktiv |Region Baden-Württemberg|Craig, Jessica    |012         |900015505     |DV2798587|#}
{#|30.03.2026 |DZ-PrivateBanking|27.12.2024      |aktiv |Region Baden-Württemberg|Craig, Jessica    |012         |900000000     |DV2798587|#}
{#+-----------+-----------------+----------------+------+------------------------+------------------+------------+--------------+---------+#}

-- INFO: tried to use snapshot functionality, but it does not fit to initial batch load, had to calculate via SQL
------------------------------------------------------------------------------------------------------------------------

-- question: is it okay that cash flows and account states dont fit together, like in example below?
------------------------------------------------------------------------------------------------------------------------

-- question: MART_B: shall previous turnovers from current clients also be considered? or only in terms of actual berater
------------------------------------------------------------------------------------------------------------------------

-- INFO: generated subset of cases where client has multiple versions and beraters, and berater has multiple clients
------------------------------------------------------------------------------------------------------------------------

with k as (
    select
        kunde_id,
        array_agg(berater) as berater_agg
    from dev_default_dwh.dim_kunden
    group by
        kunde_id
    having
        count(*) > 1
    and count(distinct berater) > 1
),
    b as (
      select berater from dev_default_dwh.dim_kunden group by berater having count(distinct kunde_id) > 1
    )
select distinct kunde_id
from k
  join b
   on b.berater in k.berater_agg
;
+---------+
|kunde_id |
+---------+
|CH4683284|
|CH6546121|
|CH9500390|
|LU5131284|
|CH5766279|
|CH3500894|
|CH5699941|
|CH2297373|
|CH6047218|
|CH2625583|
|CH5051891|
|CH5767054|
|CH3364702|
|CH7199019|
+---------+
