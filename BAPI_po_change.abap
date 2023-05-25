 
" Sample Abap code on BAPI_PO_CHANGE
" DELETING PURCHASE ORDERS
" https://www.erpgreat.com/abap/sample-abap-code-on-bapi-po-change.htm

*&---------------------------------------------------------------------*
*& Report ZMMR_DELETEPO                                               *
*&---------------------------------------------------------------------*
*&  Author                    : Bikash Agarwal
*&  Description               : VTLS PO Change
*&  Program Objective         : Places a DELETION indicator for the PO
*&                              items given in the VTLS data
*&  Remarks                   : NA
*&---------------------------------------------------------------------*

REPORT ZMMR_DELETEPO NO STANDARD PAGE HEADING MESSAGE-ID zisb.

tables : zvtls_sap.

*C-- Types Declarations

TYPES : BEGIN OF tp_flatfile_vtls,
        ebeln(10),
        ebelp type ekpo-ebelp,
        END OF tp_flatfile_vtls.

*=====================================================================
*                   INTERNAL TABLES DECLARATION
*=====================================================================

DATA:  t_flatfile_vtls TYPE tp_flatfile_vtls OCCURS 0 WITH HEADER LINE.

data : begin of t_sapdata occurs 0,
       po like zvtls_sap-posap,
       item like zvtls_sap-itemsap,
       end of t_sapdata.

data : begin of t_flatfile_vtls1 occurs 0,
       po(10),
       item like zvtls_sap-itemsap,
       end of t_flatfile_vtls1.

data : begin of t_update occurs 0,
       mandt like zvtls_sap-mandt,
       povtls like zvtls_sap-povtls,
       itemvtls like zvtls_sap-itemvtls,
       posap like zvtls_sap-posap,
       itemsap like zvtls_sap-itemsap,
       aedat like zvtls_sap-aedat,
       paedt like zvtls_sap-paedt,
       loekz like zvtls_sap-loekz,
       end of t_update.

data : begin of t_poheader occurs 0,
       po like zvtls_sap-posap,
       end of t_poheader.

data : begin of t_poitem occurs 0,
       po like zvtls_sap-posap,
       item like zvtls_sap-itemsap,
       end of t_poitem.

DATA : BEGIN OF T_MESSAGE OCCURS 0,
       MSGTY,
       MSGID(2),
       MSGNO(3),
       MSGTX(100),
       PO like zvtls_sap-povtls,
       item like zvtls_sap-itemvtls,
       END OF T_MESSAGE.

DATA : BEGIN OF t_bapi_poheader OCCURS 0.
        INCLUDE STRUCTURE bapimepoheader.
DATA : END OF t_bapi_poheader.

DATA : BEGIN OF t_bapi_poheaderx OCCURS 0.
        INCLUDE STRUCTURE bapimepoheaderx.
DATA : END OF t_bapi_poheaderx.

DATA : BEGIN OF t_bapi_poitem OCCURS 0.
        INCLUDE STRUCTURE bapimepoitem.
DATA : END OF t_bapi_poitem.

DATA : BEGIN OF t_bapi_poitemx OCCURS 0.
        INCLUDE STRUCTURE bapimepoitemx.
DATA : END OF t_bapi_poitemx.

DATA : BEGIN OF t_bapireturn OCCURS 0.
        INCLUDE STRUCTURE bapiret2.
DATA : END OF t_bapireturn.

*=====================================================================
*                   V A R I A B L E S
*=====================================================================

DATA: w_success(6)  TYPE n,
      w_bklas like t023-bklas,
      w_curryear(4),
      w_begda like sy-datum,
      w_endda like sy-datum,
      w_begyr(4),
      w_endyr(4),
      w_currmon(2),
      w_assetclass like ankt-anlkl,
      w_price type p,
      w_recordsap type i,
      w_povtls(10),
      w_count type i.

DATA:  w_filepath TYPE rlgrap-filename,
       w_rc TYPE sy-subrc,
       w_sscrfields_ucomm1   TYPE sscrfields-ucomm,
       w_file1 TYPE string,
       w_file2 TYPE FILENAME-FILEINTERN.

*=====================================================================
*                   C O N S T A N T S
*=====================================================================

CONSTANTS: c_x              TYPE  c         VALUE 'X',
           c_hyp            TYPE  c         VALUE '-',
           c_err            TYPE  bdc_mart  VALUE 'E'.

CONSTANTS:  c_slash(1)            TYPE c VALUE '/',
            c_hash(1)             TYPE c VALUE '#',
            c_pipe                TYPE c VALUE '|',
            c_1                   TYPE i VALUE 1,
            c_zero                TYPE n VALUE '0',
            c_rg1(3)              TYPE c VALUE 'rg1',
            c_gr3(3)              TYPE c VALUE 'GR3',
            c_gr2(3)              TYPE c VALUE 'GR2',
            c_e(1)                TYPE c VALUE 'E',
            c_filepath(8)         TYPE c VALUE '/interf/',
            c_filetype(10)        TYPE c VALUE 'ASC'.

CONSTANTS : c_bapimepoheaderx   TYPE x030l-tabname
                               VALUE 'bapimepoheaderx',
           c_bapimepoitem      TYPE  x030l-tabname
                               VALUE 'bapimepoitem',
           c_bapimepoaccount   TYPE  x030l-tabname
                               VALUE 'bapimepoaccount',
           c_t_bapi_poheader(15)        TYPE c
                                        VALUE 't_bapi_poheader',
           c_t_bapi_poitem(13)          TYPE c
                                        VALUE 't_bapi_poitem',
           c_t_bapi_poitemx(14)         TYPE c
                                        VALUE 't_bapi_poitemx',
           c_t_bapi_poheaderx(16)       TYPE c
                                        VALUE 't_bapi_poheaderx'.

CLASS cl_abap_char_utilities DEFINITION LOAD.
CONSTANTS:con_tab  TYPE c VALUE cl_abap_char_utilities=>horizontal_tab.

*======================================================================
*                        SELECTION SCREEN
*======================================================================

SELECTION-SCREEN BEGIN OF BLOCK inputpath WITH FRAME TITLE text-001.

SELECTION-SCREEN : BEGIN OF BLOCK blk2 WITH FRAME TITLE text-002.
PARAMETERS : p_fore RADIOBUTTON GROUP rg1
                    USER-COMMAND pc,
             p_back RADIOBUTTON GROUP rg1 DEFAULT 'X'.
SELECTION-SCREEN : END OF BLOCK blk2.

SELECTION-SCREEN : BEGIN OF BLOCK blk1 WITH FRAME TITLE text-003.
PARAMETERS :  p_file1 LIKE rlgrap-filename OBLIGATORY MODIF ID gr2.
PARAMETERS :  p_afile1 LIKE rlgrap-filename OBLIGATORY MODIF ID gr3.
SELECTION-SCREEN : END OF BLOCK blk1.

SELECTION-SCREEN END OF BLOCK inputpath.

*C-- Initialization Event

INITIALIZATION.

  CLEAR w_filepath.
  CONCATENATE c_filepath sy-sysid c_slash sy-mandt c_slash INTO
  w_filepath.

  CONDENSE w_filepath NO-GAPS.

  p_file1 = text-008.

  p_afile1 = text-009.

*======================================================================
*                        SELECTION SCREEN EVENTS
*======================================================================

*C-- Selection Screen Output

AT SELECTION-SCREEN OUTPUT.
  IF p_fore = c_x.
    w_sscrfields_ucomm1 = space.
  ELSE.
    w_sscrfields_ucomm1 = c_rg1.
  ENDIF.

  LOOP AT SCREEN.

*C--Modify selection screen if presentation
*C--or application server radio button is chosen

    IF w_sscrfields_ucomm1 = space.
      IF screen-group1 = c_gr3.
        screen-active = c_zero.
      ENDIF.
    ELSE.

      IF screen-group1 = c_gr2.
        screen-active = c_zero.
      ENDIF.
    ENDIF.

    if screen-name = 'P_AFILE1'.
      screen-input = 0.
    ENDIF.
    MODIFY SCREEN.

  ENDLOOP.

*C-- Selection Screen VALUE-REQUEST FOR File path

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file1.

  IF p_fore EQ c_x.

    CALL FUNCTION 'F4_FILENAME'
      EXPORTING
        program_name  = syst-cprog
        dynpro_number = syst-dynnr
      IMPORTING
        file_name     = p_file1.
  ENDIF.

*C-- At Start of the Selection Process

START-OF-SELECTION.

  IF p_fore EQ c_x.
    w_file1 = p_file1.
  ELSE.
    w_file2 = p_afile1.
  ENDIF.

  IF p_fore EQ c_x. " Presentaion Server

*C--Validations for the input files

    PERFORM validate_pre_file USING p_file1.

*C-- Load the contents of the input file into the internal table

    PERFORM upload_file TABLES t_flatfile_vtls
                        USING w_file1
                        CHANGING w_rc.

    IF w_rc <> 0.
      MESSAGE s006 DISPLAY LIKE c_e.
    ENDIF.

  ELSE. " Application Server

*C--Validations for the input files

    PERFORM validate_app_file USING  w_file2.

*C-- Load the contents of the input file into the internal table

    PERFORM upload_file_app TABLES t_flatfile_vtls
                            USING w_file2
                            CHANGING w_rc.

  ENDIF.

  loop at t_flatfile_vtls.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = t_flatfile_vtls-ebeln
      IMPORTING
        output = t_flatfile_vtls1-po.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = t_flatfile_vtls-ebelp
      IMPORTING
        output = t_flatfile_vtls1-item.
    append t_flatfile_vtls1.
    clear t_flatfile_vtls1.

  endloop.

  perform get_podata.

  loop at t_poheader.

    perform move_to_bapi.

    perform call_bapi.

  endloop.

  PERFORM STORE_MESSAGES TABLES T_MESSAGE.

*&---------------------------------------------------------------------
*
*&      Form  validate_pre_file
*&---------------------------------------------------------------------
*
*     Routine to validate presentation server file path.
*----------------------------------------------------------------------
*
*      -->fp_name  text
*----------------------------------------------------------------------
*
FORM validate_pre_file USING fp_name TYPE rlgrap-filename.

  DATA : l_result,
         l_filename TYPE string.

  l_filename = fp_name.

  CLEAR l_result.

  CALL METHOD cl_gui_frontend_services=>file_exist
    EXPORTING
      file                 = l_filename
    RECEIVING
      result               = l_result
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      wrong_parameter      = 3
      not_supported_by_gui = 4
      OTHERS               = 5.

  IF sy-subrc <> 0.
    MESSAGE s007 DISPLAY LIKE c_e.
    LEAVE LIST-PROCESSING.
  ELSEIF l_result IS INITIAL.
    MESSAGE s008 DISPLAY LIKE c_e.
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM.                    " validate_pre_file_hdr

*&---------------------------------------------------------------------
*
*&      Form  validate_app_file
*&---------------------------------------------------------------------
*
*       text - Checks if the path entered and filename is correct
*----------------------------------------------------------------------
*
FORM validate_app_file USING  fp_file  TYPE FILENAME-FILEINTERN.

  data : l_fname(60).

  CALL FUNCTION 'FILE_GET_NAME'
    EXPORTING
      LOGICAL_FILENAME = FP_FILE
      OPERATING_SYSTEM = SY-OPSYS
    IMPORTING
      FILE_NAME        = L_FNAME
    EXCEPTIONS
      FILE_NOT_FOUND   = 1
      OTHERS           = 2.
  IF SY-SUBRC = '0'.
    OPEN DATASET  L_FNAME FOR INPUT IN TEXT MODE ENCODING DEFAULT.
    IF sy-subrc NE 0.
      MESSAGE s007 DISPLAY LIKE c_e.
    ELSE.
      CLOSE DATASET l_fname.
    ENDIF.
  ENDIF.

ENDFORM.                    " validate_app_file

*&---------------------------------------------------------------------
*
*&      Form  upload_file
*&---------------------------------------------------------------------
*
*       Routine to upload data from file to tables.
*----------------------------------------------------------------------
*
*      -->P_fp_flatfile
*      -->P_fp_file
*      <--P_fp_rc
*----------------------------------------------------------------------
*

FORM  upload_file TABLES   fp_flatfile
                  USING    fp_file TYPE string
                  CHANGING fp_rc TYPE sy-subrc.

  IF fp_flatfile[] IS INITIAL.

    CALL FUNCTION 'GUI_UPLOAD'
      EXPORTING
        filename                = fp_file
        filetype                = c_filetype
        has_field_separator     = c_x
      TABLES
        data_tab                = fp_flatfile
      EXCEPTIONS
        file_open_error         = 1
        file_read_error         = 2
        no_batch                = 3
        gui_refuse_filetransfer = 4
        invalid_type            = 5
        no_authority            = 6
        unknown_error           = 7
        bad_data_format         = 8
        header_not_allowed      = 9
        separator_not_allowed   = 10
        header_too_long         = 11
        unknown_dp_error        = 12
        access_denied           = 13
        dp_out_of_memory        = 14
        disk_full               = 15
        dp_timeout              = 16
        OTHERS                  = 17.

    MOVE sy-subrc TO fp_rc.

  ENDIF.

ENDFORM.  " upload_file

*&--------------------------------------------------------------------*
*&      Form  upload_file_app
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->FP_FLATFILEtext
*      -->FP_FILE    text
*      -->FP_RC      text
*---------------------------------------------------------------------*
FORM  upload_file_app TABLES   fp_flatfile
                      USING    fp_file TYPE FILENAME-FILEINTERN
CHANGING fp_rc TYPE sy-subrc.

  DATA: l_string TYPE tedata-data.
  DATA: wa_data_file TYPE tp_flatfile_vtls,
        l_wllength TYPE i,
        FNAME(60).

  CALL FUNCTION 'FILE_GET_NAME'
    EXPORTING
      LOGICAL_FILENAME = FP_FILE
      OPERATING_SYSTEM = SY-OPSYS
    IMPORTING
      FILE_NAME        = FNAME
    EXCEPTIONS
      FILE_NOT_FOUND   = 1
      OTHERS           = 2.

  IF SY-SUBRC = 0.

    OPEN DATASET  FNAME FOR INPUT IN TEXT MODE ENCODING DEFAULT.

    IF sy-subrc NE 0.
* *C-- commented by Bikash
*      MESSAGE s107(yaero_ps) DISPLAY LIKE c_e.
      message e008.
    ELSE.
      DO.

        CLEAR: l_string.

        READ DATASET  FNAME INTO l_string LENGTH l_wllength.
        IF sy-subrc NE 0.
          EXIT.
        ELSE.
          SPLIT l_string AT con_tab INTO   wa_data_file-ebeln
                                           wa_data_file-ebelp.

          APPEND wa_data_file TO fp_flatfile.
        ENDIF.

      ENDDO.

      CLOSE DATASET  FNAME.
    ENDIF.

  ENDIF.

ENDFORM.  " upload_file_app

*&--------------------------------------------------------------------*
*&      Form  get_podata
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
form get_podata.

  select *
  into table t_update
  from zvtls_sap
  for all entries in t_flatfile_vtls1
   where itemvtls = t_flatfile_vtls1-item
  and povtls = t_flatfile_vtls1-po.

  sort t_update by posap itemsap.

  loop at t_update.
    at new posap.
      t_poheader-po = t_update-posap.
      append t_poheader.
      clear t_poheader.
    endat.
    t_poitem-po = t_update-posap.
    t_poitem-item = t_update-itemsap.
    append t_poitem.
    clear t_poitem.
    t_update-paedt = sy-datum.
    t_update-loekz = 'X'.
    modify t_update.
  endloop.

  modify zvtls_sap from table t_update.

endform.                    "get_podata

*&--------------------------------------------------------------------*
*&      Form  move_to_bapi
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
form move_to_bapi.

  t_bapi_poheader-po_number = t_poheader-po.

  CLEAR t_bapi_poheaderx.

  PERFORM fill_check_structure USING c_bapimepoheaderx
                                     c_t_bapi_poheader
                                     c_t_bapi_poheaderx
                                     c_x.

  refresh : t_bapi_poitem,t_bapi_poitemx.

  loop at t_poitem where po = t_poheader-po.

    clear t_bapi_poitem.
    t_bapi_poitem-po_item = t_poitem-item.
    t_bapi_poitem-delete_ind = 'X'.

    CLEAR t_bapi_poitemx.

    PERFORM fill_check_structure USING c_bapimepoitem
                                       c_t_bapi_poitem
                                       c_t_bapi_poitemx
                                       c_x.

    t_bapi_poitemx-po_item = t_poitem-item.
    t_bapi_poitemx-po_itemx = c_x.

    APPEND t_bapi_poitem.
    APPEND t_bapi_poitemx.
    clear t_bapi_poitem.
    clear t_bapi_poitemx.

  endloop.

endform.                    "move_to_bapi

*&---------------------------------------------------------------------
*
*&      Form  call_bapi
*&---------------------------------------------------------------------
*
*       This form Routine is used to commit the data records
*----------------------------------------------------------------------*

FORM call_bapi .
  DATA : l_msgty      TYPE c,
         l_msgid(2)   TYPE c,
         l_msgno(3)   TYPE c,
         l_msgtx(100) TYPE c,
         l_errflag    TYPE c.

  CLEAR: t_bapireturn.
  REFRESH: t_bapireturn.

  CALL FUNCTION 'BAPI_PO_CHANGE'
    EXPORTING
      PURCHASEORDER = T_POHEADER-PO
      POHEADER      = T_BAPI_POHEADER
      POHEADERX     = T_BAPI_POHEADERX
    TABLES
      RETURN        = T_BAPIRETURN
      POITEM        = T_BAPI_POITEM
      POITEMX       = T_BAPI_POITEMX.

  READ TABLE t_bapireturn WITH KEY type = c_err TRANSPORTING NO FIELDS.
  IF sy-subrc NE 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = c_x.
  ENDIF.
*C-- Write messages

  WRITE: / 'PO Number', t_poheader-po.
  clear : t_update,w_povtls.
  read table t_update with key posap = t_poheader-po.
  w_povtls = t_update-povtls.

  CLEAR l_errflag.

  LOOP AT t_bapireturn.

    CLEAR: l_msgty, l_msgid, l_msgno, l_msgtx.

    l_msgty = t_bapireturn-type.
    l_msgid = t_bapireturn-id.
    l_msgno = t_bapireturn-number.
    l_msgtx = t_bapireturn-message.

    WRITE: / l_msgty, l_msgid, l_msgno, l_msgtx.

    if l_msgtx cs t_poheader-po.
      w_count = w_count + 1.

      loop at t_update.
        if sy-tabix = w_count.
          t_message-item = t_update-itemvtls.
        endif.
      endloop.

    endif.

    t_message-msgty = l_msgty.
    t_message-msgid = l_msgid.
    t_message-msgno = l_msgno.
    t_message-msgtx = l_msgtx.
    t_message-po = w_povtls.
    append t_message.
    clear t_message.

    IF l_msgty EQ c_err.
      l_errflag = c_x.
    ENDIF.    " l_msgty EQ 'E'
  ENDLOOP.
  ULINE.

  IF l_errflag NE c_x.
    w_success = w_success + 1.
  ENDIF.    " l_errflag NE C_X

endform.                    "call_bapi

*&---------------------------------------------------------------------
*
*&      Form  fill_check_structure
*&---------------------------------------------------------------------
*
*       This form Routine will check whether the specified structure
*       exist/active
*----------------------------------------------------------------------
*

FORM fill_check_structure  USING    fp_tabname TYPE any
                                    fp_orgtabname TYPE any
                                    fp_chktabname TYPE any
                                    fp_check TYPE c.

  FIELD-SYMBOLS : <fs_chk>, <fs_org>.

  DATA:    l_char1(61)  TYPE c,
           l_char2(61)  TYPE c.

  DATA:    BEGIN OF tl_nametab OCCURS 60.
          INCLUDE STRUCTURE x031l.
  DATA:    END OF tl_nametab.

  REFRESH tl_nametab.
  CALL FUNCTION 'RFC_GET_NAMETAB'
    EXPORTING
      tabname          = fp_tabname
    TABLES
      nametab          = tl_nametab
    EXCEPTIONS
      table_not_active = 1
      OTHERS           = 2.
  IF sy-subrc <> 0.
    CLEAR tl_nametab.
  ENDIF.

  LOOP AT tl_nametab.
    CLEAR: l_char1, l_char2.
    CONCATENATE fp_chktabname c_hyp tl_nametab-fieldname INTO l_char1.
    ASSIGN (l_char1) TO <fs_chk>.
    CONCATENATE fp_orgtabname c_hyp tl_nametab-fieldname INTO l_char2.
    ASSIGN (l_char2) TO <fs_org>.
    IF <fs_org> IS NOT INITIAL.
      <fs_chk> = fp_check.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " fill_check_structure

*&--------------------------------------------------------------------*
*&      Form  STORE_MESSAGES
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->FP_MESSAGEStext
*---------------------------------------------------------------------*
FORM STORE_MESSAGES TABLES FP_MESSAGES STRUCTURE T_MESSAGE.

  DATA: wl_output_data LIKE t_MESSAGE.
  DATA: l_catstr TYPE string.
  DATA: l_fieldvalue TYPE string.
  DATA: l_index TYPE i VALUE 1.
  DATA: L_FNAME(60).

  FIELD-SYMBOLS <fs>.

  CLEAR l_catstr.

  CALL FUNCTION 'FILE_GET_NAME'
    EXPORTING
      LOGICAL_FILENAME = '/USR/SAP/VTLS/POCHANGE/LOG'
      OPERATING_SYSTEM = SY-OPSYS
    IMPORTING
      FILE_NAME        = L_FNAME
    EXCEPTIONS
      FILE_NOT_FOUND   = 1
      OTHERS           = 2.

  IF SY-SUBRC = '0'.
    IF fp_messages[] IS NOT INITIAL.

      OPEN DATASET L_FNAME FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.

      IF sy-subrc NE 0.

        LEAVE LIST-PROCESSING.

      ELSE.

        LOOP AT fp_messages INTO wl_output_data.

          DO.

           ASSIGN COMPONENT l_index OF STRUCTURE wl_output_data TO <fs>.

            IF sy-subrc <> 0.

              EXIT.

            ENDIF.

            MOVE <fs> TO l_fieldvalue.

            IF l_catstr IS NOT INITIAL.

              CONCATENATE l_catstr l_fieldvalue INTO l_catstr SEPARATED
              BY con_tab.

            ELSE.

              MOVE l_fieldvalue TO l_catstr.

            ENDIF.

            l_index = l_index + c_1.

            CLEAR l_fieldvalue.

            CLEAR <fs>.

          ENDDO.

          l_index = c_1.

          TRANSFER l_catstr TO L_FNAME .

          CLEAR wl_output_data.

          CLEAR l_catstr.

        ENDLOOP.

        CLOSE  DATASET L_FNAME.

      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    "STORE_MESSAGES

" https://www.erpgreat.com/abap/sample-abap-code-on-bapi-po-change.htm

"ABAP Tips

"Related ABAP Topics:
"Example of using BAPI_MATERIAL_SAVEDATA
"BAPI to Copy Materials from one Plant to Another

"Get help for your ABAP problems
"Do you have a ABAP Question?

"SAP Books
"SAP Certification, Interview Questions, Functional, Basis Administration and ABAP Programming Reference Books

"More ABAP Tips

"ABAP Programming Tips and Tricks
"ABAP Functions Examples - ABAP Questions - BAPI Programming Tips

"BDC Programming Tips - Sapscripts Tips - Smartforms Tips
"Main Index
"SAP Basis, ABAP Programming and Other IMG Stuff
"http://www.erpgreat.com
"All the site contents are Copyright © www.erpgreat.com and the content authors. All rights reserved.
"All product names are trademarks of their respective companies.  The site www.erpgreat.com is in no way affiliated with SAP AG.
"Every effort is made to ensure the content integrity.  Information used on this site is at your own risk.
" The content on this site may not be reproduced or redistributed without the express written permission of
"www.erpgreat.com or the content authors.
