*&---------------------------------------------------------------------*
*&  class app
*&---------------------------------------------------------------------*

class app definition create private final. 
public section.
" interfaces
interfaces if_fsbp_const_range .
" aliases
" types
" constants
" data definition
" methods
class-methods main .

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
" constants
" data definition
" methods
endclass . " app

class app implementation .
" entry point
method main .
endmethod. " main
endclass. " app
