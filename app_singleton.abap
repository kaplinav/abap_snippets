class app definition create private final.
public section.
" interfaces
interfaces if_fsbp_const_range .
" types
" constants
" data definition
" methods
methods get_instance
  returning
    value(r) type ref to app.

methods main.

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
data m_instance type ref to app.
" methods

endclass . " app

class app implementation .
method get_instance .

if not m_instance is bound.
  m_instance = new app( ).
endif.

r = m_instance.

endmethod. " get_instance .

" entry point
method main.

endmethod. " main.
endclass. " app
