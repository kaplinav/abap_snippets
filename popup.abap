" general class for custom popup screen
class popup definition .
public section.
" types
" constants
" data definition
" methods

methods constructor
  importing
    im_ref type ref to data .

methods display .

protected section.
" types
" constants
" data definition
data m_ref type ref to data . "read-only.
data m_salv_table type ref to cl_salv_table .
data m_start_column type i value 15.
data m_end_column type i value 70.
data m_start_line type i value 1.
data m_end_line type i value 10.
" methods
methods setup.

endclass . " popup

class popup implementation .
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
  "
endtry.

endmethod. " constructor .

method display .

" redefinition this for tune popup screen
setup( ).

m_salv_table->set_screen_popup(
  start_column = m_start_column
  end_column = m_end_column
  start_line = m_start_line
  end_line = m_end_line ).

m_salv_table->display( ).

endmethod. " display .

method setup.
endmethod. " setup.
endclass. " popup
