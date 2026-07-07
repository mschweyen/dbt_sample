WITH raw_kunden AS (
    SELECT
        *
    FROM
        {{ ref('kunden') }}
)
SELECT
    changedate            as change_date,
    vertriebsweg,
    eroeffnungsdatum,
    status,
    region,
    berater,
    vrb_filial_und_betreuernr_an964,
    kunde_id
FROM
    raw_kunden

