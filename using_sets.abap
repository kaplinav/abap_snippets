" Types of Sets:
"   1. Basis Sets.
"   2. Data Sets.
"   3. Single-dimension Sets.
"   4. Multi-dimension Sets.

" Example: Maintain List of User using sets and check these user details in abap program.

" Maintaining Sets:
"    Creation of Sets:
" Go to Transaction Code GS01; put your Set name which you want to create

" Important Transaction Code for Sets:
"   GS01 Create set
"   GS02 Change Set
"   GS03 Display Set
"   GS04 Delete set
"   GS07 Exports sets
"   GS08 Import sets
"   GS09 Copy sets from client

" See more 
" https://blogs.sap.com/2013/08/16/using-sets-in-abap-program/

constants:
begin of c_set_name,
  fi_hkont_mm type setnamenew value 'FI_HKONT_MM',
end of c_set_name.

types set_values_tt type standard table of rgsb4.

form get_set_values using p_set_name type setnamenew 
                 changing ch_set_values type set_values_tt.

if p_set_name = space.
  return.
endif.

" or you can using the G_SET_FETCH function
call function 'G_SET_GET_ALL_VALUES'
  exporting
*   CLIENT                      = ' '
*   FORMULA_RETRIEVAL           = ' '
*   LEVEL                       = 0
    setnr                       = p_set_name
*   VARIABLES_REPLACEMENT       = ' '
*   TABLE                       = ' '
    class                       = '0000'
*   NO_DESCRIPTIONS             = 'X'
*   NO_RW_INFO                  = 'X'
*   DATE_FROM                   =
*   DATE_TO                     =
*   FIELDNAME                   = ' '
  tables
    set_values                  = ch_set_values
* EXCEPTIONS
*   SET_NOT_FOUND               = 1
*   OTHERS                      = 2
          .

if sy-subrc <> 0.
* Implement suitable error handling here
endif.

endform. " get_set_values .

types:
begin of hkont_rng_t,
    sign type ddsign,
    option type ddoption,
    low type hkont,
    high type hkont,
end of hkont_rng_t.

types hkont_rng_tt type standard table of hkont_rng_t .

form get_hkont_rng_by_set using p_set type set_values_tt 
                       changing ch_rng type hkont_rng_tt.

field-symbols <f> type set_values_t.
loop at p_set assigning <f>.
    data rng_s type hkont_rng_t.
    
    if <f>-from <> space and <f>-to <> space .
        rng_s-sign = if_fsbp_const_range=>sign_include.
        rng_s-option = if_fsbp_const_range=>option_between.
        rng_s-low = <f>-from.
        rng_s-high = <f>-to. 
    endif.

    insert rng_s into table ch_rng.
endloop. " p_set
    
endform. " get_hkont_rng . 
