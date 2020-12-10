class alv_screen definition .
public section.
" interfaces
interfaces if_fsbp_const_range .
" types
" constants
" data definition
" methods
methods constructor
  importing
    im_ref type ref to data.

methods display.

protected section.
" types
" constants
" data definition
" methods

private section.
" aliases
aliases sign_include for if_fsbp_const_range~sign_include.
aliases option_equal for if_fsbp_const_range~option_equal.
" types
" constants
" data definition
data m_ref type ref to data.
data m_salv_table type ref to cl_salv_table .
" methods
methods set_display_settings.
methods set_layout.
methods set_optimize.
methods set_texts.
methods set_toolbar.
methods tune.

endclass . " alv_screen

class alv_screen implementation .
method constructor .

m_ref = im_ref.
field-symbols <table> type standard table.
assign im_ref->* to <table>.

try .

  cl_salv_table=>factory(
    importing
      r_salv_table = m_salv_table
    changing
      t_table = <table> ).

catch cx_salv_msg into data(e).
endtry.

endmethod. " constructor .

method display.

tune( ).
m_salv_table->display( ).

endmethod. " display.

method set_display_settings.

data(display_settings) = m_salv_table->get_display_settings( ).
display_settings->set_striped_pattern( if_salv_c_bool_sap=>true ).
display_settings->set_list_header( 'Просмотр изменений значений признаков ТМ' ).

endmethod. " set_display_settings.

method set_layout.

data layout_key type salv_s_layout_key.
layout_key-report = sy-repid.

data(layout_settings) = m_salv_table->get_layout( ).
layout_settings->set_key( layout_key ).
layout_settings->set_save_restriction( if_salv_c_layout=>restrict_none ).
layout_settings->set_default( if_salv_c_bool_sap=>true ).

endmethod. " set_layout.

method set_optimize.

data(columns) = m_salv_table->get_columns( ).
columns->set_optimize( ).

endmethod. " set_optimize.

method set_texts.

data(columns) = m_salv_table->get_columns( ).
data column type ref to cl_salv_column_table.

" text length
" short 10
" medium 20
" long 40

try .
  column ?= columns->get_column( 'BUKRS' ).
  column->set_short_text( 'ФилиалМРСК' ).
  column->set_medium_text( 'Филиал МРСК' ).
  column->set_long_text( 'Филиал МРСК' ).
catch cx_salv_not_found into data(e).
endtry.

try .
  column ?= columns->get_column( 'STORT' ).
  column->set_short_text( 'РЭС,служба' ).
  column->set_medium_text( 'РЭС, служба' ).
  column->set_long_text( 'РЭС, служба' ).
catch cx_salv_not_found into e.
endtry.

try .
  column ?= columns->get_column( 'TXTBZ' ).
  column->set_short_text( 'НазвКласса' ).
  column->set_medium_text( 'Название Класса' ).
  column->set_long_text( 'Название Класса' ).
catch cx_salv_not_found into e.
endtry.

try .
  column ?= columns->get_column( 'ATNAM' ).
  column->set_short_text( 'Признак' ).
  column->set_medium_text( 'Признак' ).
  column->set_long_text( 'Признак' ).
catch cx_salv_not_found into e.
endtry.

try .
  column ?= columns->get_column( 'AENAM' ).
  column->set_short_text( 'Пользоват.' ).
  column->set_medium_text( 'Пользователь' ).
  column->set_long_text( 'Пользователь' ).
catch cx_salv_not_found into e.
endtry.

try .
  column ?= columns->get_column( 'ATWRT_OLD' ).
  column->set_short_text( 'СтароеЗнач' ).
  column->set_medium_text( 'СтароеЗнач.Признака' ).
  column->set_long_text( 'Старое Значение Признака' ).
catch cx_salv_not_found into e.
endtry.

try .
  column ?= columns->get_column( 'ATWRT_NEW' ).
  column->set_short_text( 'НовоеЗнач' ).
  column->set_medium_text( 'НовоеЗнач.Признака' ).
  column->set_long_text( 'Новое Значение Признака' ).
catch cx_salv_not_found into e.
endtry.

endmethod. " set_texts.

method set_toolbar.

data(functions) = m_salv_table->get_functions( ).
functions->set_all( if_salv_c_bool_sap=>true ).

endmethod. " set_toolbar.

method tune.

set_layout( ).
set_optimize( ).
set_texts( ).
set_toolbar( ).
set_display_settings( ).

endmethod. " tune.
endclass. " alv_screen
