types:
begin of rng_stru_t,
  sign type ddsign,
  option type ddoption,
  low type any_type,
  high type any_type,
end of rng_stru_t.

types rng_t type standard table of rng_stru_t.

rng = vakue #( 
  for struc in itab( 
    sign = 'I'
    option = 'EQ'
    low = struc-any_field 
  )
). 

data rng type range of i.
 
i_rng = value #( 
  sign = 'I' option = 'BT' 
    ( low = 1  high = 10 )
    ( low = 21 high = 30 )
    ( low = 41 high = 50 )
  option = 'GE' 
    ( low = 61 )  
).
