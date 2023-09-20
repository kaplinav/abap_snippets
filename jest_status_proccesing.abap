class utils definition create private final.
public section.
" interfaces
interfaces if_fsbp_const_range .
" aliases
" types
types:
begin of itab_t,
  objnr type j_objnr,
end of itab_t.

types itab_tt type standard table of itab_t.

" constants
" data definition
" methods
class-methods class_constructor .

class-methods excl_eq_with_del_mark
  changing
    itab type itab_tt.

protected section.
" aliases
" types
" constants
" data definition
" methods

private section.
" aliases
aliases sign_include for if_fsbp_const_range~sign_include.
aliases option_between for if_fsbp_const_range~option_between.
aliases option_equal for if_fsbp_const_range~option_equal.
" types
types:
begin of status_text_t,
  txt04 type j_txt04,
end of status_text_t.

types status_text_tt type standard table of status_text_t with empty key.

types:
begin of stat_rng_t,
  sign type ddsign,
  option type ddoption,
  low type j_status,
  high type j_status,
end of stat_rng_t.

types stat_rng_tt type standard table of stat_rng_t with empty key.
" constants
" data definition
class-data m_excld_stat_rng type stat_rng_tt.
" methods
class-methods get_eq_excld_stat_txts
  returning
    value(r) type status_text_tt.

class-methods get_excld_stat_rng
  importing
    status_texts type status_text_tt
  returning
    value(r) type stat_rng_tt.

class-methods init.

endclass . " utils

class utils implementation .
method class_constructor .

init( ).

endmethod. " class_constructor .

method excl_eq_with_del_mark.

if lines( m_excld_stat_rng ) = 0.
  return.
endif.

loop at itab assigning field-symbol(<f>).
  data idx type sytabix.
  idx = sy-tabix.
  data status type standard table of jstat.

  call function 'STATUS_READ'
    exporting
      objnr = <f>-objnr
    tables
      status = status.

  loop at status assigning field-symbol(<status>).
    if <status>-stat in m_excld_stat_rng.
      delete itab index idx.
    endif.
  endloop.
endloop.

endmethod. " excl_eq_with_del_mark

method get_eq_excld_stat_txts.

data status_text_s type status_text_t.
status_text_s-txt04 = 'МТКУ'.
insert status_text_s into table r.
status_text_s-txt04 = 'СПИС'.
insert status_text_s into table r.
status_text_s-txt04 = 'МТСП'.
insert status_text_s into table r.
status_text_s-txt04 = 'ДМНТ'.
insert status_text_s into table r.

endmethod. " get_eq_excld_stat_txts

method get_excld_stat_rng.

loop at status_texts assigning field-symbol(<f>).
  data jest_status type j_status.
  free jest_status.

  call function 'STATUS_TEXT_CONVERSION'
    exporting
      language = sy-langu
        " 'МТКУ', 'СПИС', 'МТСП', 'ДМНТ', etc.
      txt04 = <f>-txt04
    importing
      status_number = jest_status.

  if jest_status = space.
    continue.
  endif.

  data stat_rng_s type stat_rng_t.
  stat_rng_s-sign = sign_include.
  stat_rng_s-option = option_equal.
  stat_rng_s-low = jest_status.
  insert stat_rng_s into table r.
endloop.

endmethod. " get_excld_stat_rng

method init.

data status_texts type status_text_tt.
status_texts = get_eq_excld_stat_txts( ).
m_excld_stat_rng = get_excld_stat_rng( status_texts ).

endmethod. " init
endclass. " utils
