
methods get_fire_stat2_rng
  returning
    value(r) type CCHRY_STAT2_RANGE.

methods is_fired 
  importing
    pernr type persno
  returning
    value(r) type abap_bool.

method get_fire_stat2_rng.



endmethod. " get_fire_stat2_rng

method is_fired .

data t type persno.

select single pernr
from pa0000
into t
where pernr = pernr
and massn
and stat .

endmethod. " is_fired