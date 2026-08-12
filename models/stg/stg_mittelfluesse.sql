WITH raw_mittelfluesse AS (
    SELECT
        *
    FROM
        {{ ref('mittelfluesse') }}
)
SELECT
    date(strptime(datum, '%d.%m.%Y')) as datum,
    mittelzufluss,
    mittelabfluss,
    kunde_id
FROM
    raw_mittelfluesse



