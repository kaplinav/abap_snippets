
tables zpm_unload_is .
constants c_view_name type char30 value 'ZPM_UNLOAD_IS'.

constants:
begin of c_action,
  update type char1 value 'U',
  display type char1 value 'S',
end of c_action.

select-options s_class for zpm_unload_is-class .
select-options s_ver for zpm_unload_is-version .

data sel_tab type c2s_vimsellist_ttype.
free sel_tab.
perform add_sel_criteria changing sel_tab.

data excl_func type /osp/tt_func .
free excl_func.
"perform add_func_to_excl changing excl_func .

" Call SM30 with the restricted key range.
call function 'VIEW_MAINTENANCE_CALL'
  exporting
    " Mode: 'U' = Update, 'S' = Display.
    action = c_action-display
    " Table view name
    view_name = c_view_name
    " Скрыть предупреждение о независимости от манданта
    no_warning_for_clientindep = abap_true
    " Показать критерии выбора
    show_selection_popup = abap_false
  tables
    " Function codes to exclude .
    excl_cua_funct = excl_func
    " Selection options for restricting data.
    dba_sellist = sel_tab "lt_filters
  exceptions
    others = 0.

form add_sel_criteria changing sel_tab type c2s_vimsellist_ttype.

constants c_and type char3 value 'AND'.
data field_name type viewfield .

" Add CLASS column to selection criteria of Table maintenanace view .
field_name = 'CLASS'.

call function 'VIEW_RANGETAB_TO_SELLIST'
  exporting
    fieldname = field_name
    append_conjunction = c_and
  tables
    sellist = sel_tab
    rangetab = s_class.

" Add VERSION column to selection criteria of Table maintenanace view .
field_name = 'VERSION'.

call function 'VIEW_RANGETAB_TO_SELLIST'
  exporting
    fieldname = field_name
    append_conjunction = c_and
  tables
    sellist = sel_tab
    rangetab = s_ver.

endform. " add_sel_criteria

form add_func_to_excl changing excl_func type /osp/tt_func .

" Deactivate New Entries.
" Function Code for New Entries.
"gwa_exclude-function = 'NEWL'.
"APPEND gwa_exclude TO gt_exclude.

" Deactivate Copy.
" Function Code for Copy.
"gwa_exclude-function = 'KOPE'.
"APPEND gwa_exclude TO gt_exclude.

" Deactivate Delete.
" Function Code for Delete.
"gwa_exclude-function = 'DELE'.
"APPEND gwa_exclude TO gt_exclude.

excl_func = value /osp/tt_func(
  " Deactivate New Entries.
  " Function Code for New Entries.
  ( function = 'NEWL' )
  " Deactivate Copy.
  " Function Code for Copy.
  ( function = 'KOPE' )
  " Deactivate Delete.
  " Function Code for Delete.
  ( function = 'DELE' )
).

endform. " add_func_to_excl
