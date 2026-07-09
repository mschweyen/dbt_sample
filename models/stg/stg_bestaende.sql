WITH raw_bestaende AS (
    SELECT
        *
    FROM
        {{ ref('bestaende') }}
)
SELECT
    date(strptime(datum, '%d.%m.%Y')) as datum,
    aum,
    kunde_id
FROM
    raw_bestaende


