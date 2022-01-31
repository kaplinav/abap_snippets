" interesting runtime errors list

" runtime error if using this table as result tab
data result_tab2 type standard table of SWHACTOR with empty key.
" no error
data result_tab3 type standard table of SWHACTOR with default key.

call function 'RH_STRUC_GET'
  exporting
    act_otype              = im_otype
    act_objid              = im_objid
    act_wegid              = im_wegid
*   act_int_flag           =
    act_plvar              = im_plvar
    act_begda              = im_date
    act_endda              = im_date
*   act_tdepth             = 0
*   act_tflag              = 'X'
*   act_vflag              = 'X'
    authority_check        = abap_true
*   text_buffer_fill       =
*   buffer_mode            =
* importing
*   act_plvar              =
  tables
    result_tab             = result_tab3
*   result_objec           =
*   result_struc           =
  exceptions
    no_plvar_found         = 1
    no_entry_found         = 2
    others                 = 3 .
