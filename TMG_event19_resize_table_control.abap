" In event 19 "19  After initializing global variables, field symbols, etc."
form resize_table_control.

utils=>resize_table_control(
  im_table     = conv string( x_header-viewname )
  im_maint_fg  = conv string( x_header-area )
  im_dynpro_no = conv syst_dynnr( x_header-liste )
  im_width     = utils=>c_width-screen_103 ).

endform. " resize_table_control.

" In class utils
class utils definition abstract final.
public section.
" interfaces
" aliases
" types
" constants
constants:
begin of c_width,
  screen_103 type i value 200,
end of c_width.
" data definition
" methods

class-methods resize_table_control
  importing
    im_table type string
    im_maint_fg type string
    im_dynpro_no type syst_dynnr
    im_width type i.

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
" methods
endclass . " utils

class utils implementation .
method resize_table_control .

if im_width > 255.
  return.
endif.

data:
begin of s_dynpro_descr,
  prog type progname,
  dynpro type char4,
end of s_dynpro_descr.

s_dynpro_descr-prog = |SAPL{ im_maint_fg }|.
s_dynpro_descr-dynpro = im_dynpro_no.
data fnam type fnam_____4.
fnam = |TCTRL_{ im_table }|.

data h type d020s.
data f type standard table of d021s.
data e type standard table of d022s.
data m type standard table of d023s.
import dynpro h f e m id s_dynpro_descr.

data s_f type d021s.
read table f into s_f with key fnam = fnam.
if sy-subrc <> 0.
  return.
endif.

if h-noco > im_width.
  return.
endif.

h-noco = im_width.

" convert to hexa
data lv_crmt_ei_kb_id type crmt_ei_kb_id.
lv_crmt_ei_kb_id = im_width - 2.

call function 'CRM_EI_KB_CONV_DEC_TO_HEX'
  exporting
    iv_decimal = lv_crmt_ei_kb_id
  importing
    ev_hex     = lv_crmt_ei_kb_id.

if lv_crmt_ei_kb_id+30(2) IS INITIAL.
  return.
endif.

s_f-leng = lv_crmt_ei_kb_id+30(2). " '9B'. " 155 em hexa
modify f from s_f index sy-tabix transporting leng.

if sy-subrc <> 0.
  return.
endif.

export dynpro h f e m id s_dynpro_descr.

data m1 type string.
data l1 TYPE string.
data w1 TYPE string.
generate dynpro h f e m id s_dynpro_descr message m1 line l1 word w1.

endmethod. " resize_table_control .
endclass. " utils
