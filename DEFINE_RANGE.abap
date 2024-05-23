types:
begin of rng_stru_t,
  sign type ddsign,
  option type ddoption,
  low type any_type,
  high type any_type,
end of rng_stru_t.

types rng_t type standard table of rng_stru_t.
