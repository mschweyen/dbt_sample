with tmp as (
select
--     b.kunde_id as kb, f.kunde_id as kf,
--     b.datum as db, f.datum as df,
    coalesce(b.kunde_id, f.kunde_id)                        as kunde_id,
    coalesce(b.datum, f.datum)                              as datum,
    cast(coalesce(b.aum, 0)as decimal(18,2))               as aum,
    cast(coalesce(f.mittelzufluss, 0)as decimal(18,2))     as mittelzufluss,
    cast(coalesce(f.mittelabfluss, 0)as decimal(18,2))     as mittelabfluss

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
{#where kunde_id in (#}
    -- info vbu test subset, generated logic see in vbu_questions.sql
{#'CH4683284','CH6546121','CH9500390','LU5131284',#}
{#'CH5766279','CH3500894','CH5699941','CH2297373',#}
{#'CH6047218','CH2625583','CH5051891','CH5767054',#}
{#'CH3364702','CH7199019'#}
{#    )#}


