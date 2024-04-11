
types:
begin of event_t,
  sign type ddsign,
  option type ddoption,
  low type massn,
  high type massn,
end of event_t.

types event_rng_t type standard table of event_t with default key.

methods get_fire_event_rng
  returning
    value(r) type event_rng_t.

methods get_fire_stat2_rng
  returning
    value(r) type cchry_stat2_range.

methods is_fired 
  importing
    pernr type persno
  returning
    value(r) type abap_bool.

method get_fire_event_rng.

data event_stru type event_t.
event_stru-sign = 'I'.
event_stru-option = 'EQ'.
event_stru-low = 'C1'.
insert event_stru into table r.

endmethod. " get_fire_event_rng

method get_fire_stat2_rng.

data stat2_stru type cchrs_stat2_range.
stat2_stru-sign = 'I'.
stat2_stru-option = 'EQ'.
stat2_stru-low = 0.
insert stat2_stru into table r.

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
