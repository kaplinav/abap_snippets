types:
begin of t_source,
  key type i,
end of t_source.

types tt_source type hashed table of t_source with unique key key.

data source type tt_source.

types:
begin of t_target,
  key type i,
end of t_target.

types tt_target type hashed table of t_target with unique key key.

data target type tt_target.

loop at source assigning field-symbol(<source>) .
  read table target with key key = <source>-key transporting no fields.
  if sy-subrc = 0.
    continue.
  endif.

  data s_target type t_target.
  free s_target.
  s_target-key = <source>-key.
  insert s_target into table target.

endloop.
