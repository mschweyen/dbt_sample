
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


