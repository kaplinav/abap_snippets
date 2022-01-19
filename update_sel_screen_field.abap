" update selection screen field

data dynpread type dynpread.
" the name of the field being updated
dynpread-fieldname = 'FIELD_NAME'.
data fieldvalue type i value1.
" the value of the field being updated
dynpread-fieldvalue = fieldvalue.
data dynpfields type standard table of dynpread.
insert dynpread into table dynpfields.

call function 'DYNP_VALUES_UPDATE'
  exporting
    dyname = sy-cprog
    dynumb = sy-dynnr
  tables
    dynpfields = dynpfields.
