with tmp as (
select
--     b.kunde_id as kb, f.kunde_id as kf,
--     b.datum as db, f.datum as df,
    coalesce(b.kunde_id, f.kunde_id) as kunde_id,
    coalesce(b.datum, f.datum)       as datum,
    coalesce(b.aum, 0)               as aum,
    coalesce(f.mittelzufluss, 0)     as mittelzufluss,
    coalesce(f.mittelabfluss, 0)     as mittelabfluss
from {{ ref("stg_mittelfluesse") }} f
  full outer join {{ ref("stg_bestaende") }} b
    on f.kunde_id = b.kunde_id
    and f.datum = b.datum
{#where coalesce(b.kunde_id, f.kunde_id) = 'CH1715106'#}
order by
    coalesce(b.kunde_id, f.kunde_id),
    coalesce(b.datum, f.datum)
)
select
    kunde_id,
    datum,
    aum,
    mittelabfluss,
    mittelzufluss,
    mittelzufluss - mittelabfluss as nettoabsatz
from tmp
