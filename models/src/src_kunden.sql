WITH raw_kunden AS (
    SELECT
        *
    FROM
        {{ ref('kunden') }}
)
SELECT
    changedate            as change_date,
    vrb_filial_und_betreuernr_an964 AS vrb_filial_und_betreuernr_an964
FROM
    raw_kunden

