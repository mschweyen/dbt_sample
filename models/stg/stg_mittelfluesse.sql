WITH raw_mittelfluesse AS (
    SELECT
        *
    FROM
        {{ ref('mittelfluesse') }}
)
SELECT
    datum,
    mittelzufluss,
    mittelabfluss,
    kunde_id
FROM
    raw_mittelfluesse



