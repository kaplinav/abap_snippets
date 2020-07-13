" inherited class 
" popup with checkbox field
class popup_sel_sheet definition inheriting from popup.
public section.
" types
" constants
" data definition
" methods
"class-methods h_on_link_click for event link_click of cl_salv_events_table importing row.


protected section.
" types
" constants
" data definition
" methods
methods h_on_link_click for event link_click of cl_salv_events_table importing row.
methods setup redefinition.

private section.
" types
" constants
" data definition
" methods

endclass . " popup_sel_sheet

class popup_sel_sheet implementation .
method setup.

data(events) = m_salv_table->get_event( ).
set handler h_on_link_click for events.
data(columns) = m_salv_table->get_columns( ).

try .
  data column type ref to cl_salv_column_table.
  column ?= columns->get_column( 'COLUMN_NAME' ).
  column->set_cell_type( if_salv_c_cell_type=>checkbox_hotspot ).
  column->set_key( ).
catch cx_salv_not_found into data(e).
  "
endtry.

endmethod. " setup

method h_on_link_click .

m_ref = m_ref.
field-symbols <table> type standard table.
assign m_ref->* to <table>.

types:
begin of t_,
  column_name type abap_bool,
end of t_.
field-symbols <line> type t_.

assign <table>[ row ] to <line>.

if <line> is assigned.
  <line>-column_name = cond #( when <line>-column_name eq abap_true then abap_false else abap_true ).
  m_salv_table->refresh( refresh_mode = if_salv_c_refresh=>full ).
endif.

endmethod . " h_on_link_click
endclass. " popup_sel_sheet
