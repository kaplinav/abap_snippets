form before_save.

loop at total.
  "if <action> <> neuer_eintrag and <action> <> aendern.
  if <action> <> neuer_eintrag .
    continue.
  endif.

  field-symbols <field_name> type any.
  assign component 'FIELD_NAME' of structure <vim_total_struc> to <field_name>.
  if sy-subrc eq 0.
    " set value for FIELD_NAME field
  endif.

  read table extract with key <vim_xtotal_key>.
  if sy-subrc = 0.
    extract = total.
    modify extract index sy-tabix.
  endif.

  if total is not initial.
    modify total.
  endif.
endloop.

endform. " before_save.
