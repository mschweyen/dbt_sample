WITH raw_kunden AS (
    SELECT
        *
    FROM
        {{ ref('kunden') }}
)
SELECT
    date(strptime(changedate, '%d.%m.%Y'))            as change_date,
{#    strptime(changedate, '%d.%m.%Y')            as change_date,#}
    vertriebsweg,
    eroeffnungsdatum,
    status,
    region,
    berater,
{#    vrb_filial_und_betreuernr_an964,#}
    substring(vrb_filial_und_betreuernr_an964, 1, 3) as vrb_filialnr,
    substring(vrb_filial_und_betreuernr_an964, 4, 12) as vrb_betreuernr,
    kunde_id
FROM
    raw_kunden
{#where kunde_id = 'DV2798587'#}
{#and changedate = '29.05.2026'#}
{#                      01.01.2025 14.04.2025 18.06.2025 29.05.2026 30.03.2026#}


