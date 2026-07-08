WITH raw_bestaende AS (
    SELECT
        *
    FROM
        {{ ref('bestaende') }}
)
SELECT
    datum,
    aum,
    kunde_id
FROM
    raw_bestaende


