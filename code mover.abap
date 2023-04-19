*  _______ _______ _______ _______ _______ _______ ______  _______ _______ ______   _______
* |   _   |  _    |   _   |       |       |   _   |      ||   _   |  _    |    _ | |   _   |
* |  |_|  | |_|   |  |_|  |    _  |       |  |_|  |  _    |  |_|  | |_|   |   | || |  |_|  |
* |       |       |       |   |_| |       |       | | |   |       |       |   |_||_|       |
* |       |  _   ||       |    ___|      _|       | |_|   |       |  _   ||    __  |       |
* |   _   | |_|   |   _   |   |   |     |_|   _   |       |   _   | |_|   |   |  | |   _   |
* |__| |__|_______|__| |__|___|   |_______|__| |__|______||__| |__|_______|___|  |_|__| |__|
*                                                                        www.abapcadabra.com
*-------------------------------------------------------------------------------------------
* program          : ZABAPCADABRA_CODE_MOVER
* title            : AbapcadabrA code mover, upload and download reports with texts
* functional area  : Development tool
* environment      : 4.7
* program Function : Utility tool to upload and download reports and includes with text, menu
*                    and dynpro settings. To be used on a development system ONLY. The setup will
*                    place a series of source code files (.abap.txt) and textfiles (.text.txt) in a
*                    project directory on the front-end (PC). A project file (.project.txt) can be
*                    added which holds a list of source codes for your project. The report
*                    can be instructed to read the project file.
* Documentation    : Search for "Code mover" on AbapcadabrA.com
* Previous version : This is the initial version
* Developer name   : Wim Maasdam
* Development date : 23/02/2017
* Version          : 0.1
*-------------------------------------------------------------------------------------------
* Change list:
*   Date       Description
*   23/02/2017 Initial release
*   23/02/2018 (No really!) added logging, dynpro import and compare functionality,
*              less is more on the selection screen. Hidden delete function.
*   11/03/2018 Support for transformations, download and upload.
*-------------------------------------------------------------------------------------------
REPORT zabapcadabra_code_mover.

*----------------------------------------------------------------------
*  CLASS lcl_logging - the message logging and error logging for this
*  interface is done in the Business Application Log (trx. SLG0, SLG1).
*  The log is displayed at the end of the report run. Logs can also
*  be saved (options on the selection screen are available).
*----------------------------------------------------------------------
CLASS lcl_logging DEFINITION FINAL.

  PUBLIC SECTION.

    CLASS-DATA:
      go_log TYPE REF TO cl_ishmed_bal,
      gv_errors_were_logged TYPE boolean VALUE space,
      gv_numcount type n length 8.

    CLASS-METHODS:
      initialize IMPORTING object TYPE balobj_d DEFAULT 'ALERT'
        subobject TYPE balsubobj DEFAULT 'PROCESSING'
        extid TYPE any DEFAULT '',
      set_subject IMPORTING subject TYPE any,
      set_message IMPORTING message TYPE any OPTIONAL
       par1 TYPE any DEFAULT space
       par2 TYPE any DEFAULT space
       par3 TYPE any DEFAULT space
       msgty TYPE symsgty DEFAULT 'I'
       PREFERRED PARAMETER message,
      set_error IMPORTING message TYPE any OPTIONAL
       par1 TYPE any DEFAULT space
       par2 TYPE any DEFAULT space
       PREFERRED PARAMETER message,
      set_syst,
      set_bapiret2 IMPORTING bapiret type bapiret2,
      set_bdcmsgcoll IMPORTING bdc_message type BDCMSGCOLL,
      set_predefined IMPORTING codeword TYPE any.

ENDCLASS.                    "lcl_logging DEFINITION

*----------------------------------------------------------------------
*  CLASS lcl_logging IMPLEMENTATION
*----------------------------------------------------------------------
CLASS lcl_logging IMPLEMENTATION.

  METHOD initialize.
    data: lv_EXTID type BALNREXT.
    TRY.
        if not EXTID is initial.
          move EXTID to lv_EXTID.

          CREATE OBJECT go_log
            EXPORTING
              i_object    = object
              i_subobject = subobject
              i_extid     = lv_EXTID
              i_repid     = sy-repid.

        else.

          CREATE OBJECT go_log
            EXPORTING
              i_object    = object
              i_subobject = subobject
              i_repid     = sy-repid.

        endif.
      CATCH cx_ishmed_log.                              "#EC NO_HANDLER
* No actual processing here
    ENDTRY.
  ENDMETHOD.                    "initialize
  METHOD set_subject.
    DATA: lv_subject TYPE c LENGTH 100.

    lv_subject = subject.
*    concatenate '==>' lv_subject into lv_subject SEPARATED BY space.
    TRANSLATE lv_subject TO UPPER CASE.
    TRY.
        go_log->add_free_text( EXPORTING
            i_msg_type     = 'W'
            i_text         = lv_subject ).
      CATCH cx_ishmed_log.                              "#EC NO_HANDLER
* No actual logic on catch
    ENDTRY.
  ENDMETHOD.                    "set_subject

  METHOD set_message. " importing message type any, par1, par2
    DATA: lv_message TYPE c LENGTH 300,
          lv_par1 type c length 110,
          lv_par2 type c length 110,
          lv_par3 type c length 110.

    lv_message = message.
    lv_par1 = par1.
    lv_par2 = par2.
    lv_par3 = par3.
    REPLACE '&' WITH lv_par1 INTO lv_message. CONDENSE lv_message.
    REPLACE '&' WITH lv_par2 INTO lv_message. CONDENSE lv_message.
    REPLACE '&' WITH lv_par3 INTO lv_message. CONDENSE lv_message.
    TRY.
        go_log->add_free_text( EXPORTING
            i_msg_type     = msgty
            i_text         = lv_message ).
      CATCH cx_ishmed_log.                              "#EC NO_HANDLER
* No actual logic on catch
    ENDTRY.
  ENDMETHOD.                    "set_message

  METHOD set_error. " importing message type any, par1, par2
    DATA: lv_message TYPE c LENGTH 100,
          lv_par1 type c length 50,
          lv_par2 type c length 50.

    lv_message = message.
    lv_par1 = par1.
    lv_par2 = par2.
    REPLACE '&' WITH lv_par1 INTO lv_message.
    REPLACE '&' WITH lv_par2 INTO lv_message.
    CONDENSE lv_message.
    TRY.
        go_log->add_free_text( EXPORTING
            i_msg_type     = 'E'
            i_text         = lv_message ).
        lcl_logging=>gv_errors_were_logged = abap_true.
      CATCH cx_ishmed_log.                              "#EC NO_HANDLER
* No actual logic on catch
    ENDTRY.
  ENDMETHOD.                    "set_error

  METHOD set_syst.

    if sy-msgty = 'E'.
      lcl_logging=>gv_errors_were_logged = abap_true.
    endif.

    TRY.
        go_log->ADD_MSG( I_type = sy-msgty I_ID = sy-msgid I_NUMBER = sy-msgno
          I_MESSAGE_V1 = sy-msgv1
          I_MESSAGE_V2 = sy-msgv2
          I_MESSAGE_V3 = sy-msgv3
          I_MESSAGE_V4 = sy-msgv4 ).
      CATCH cx_ishmed_log.                              "#EC NO_HANDLER
* No actual logic on catch
    ENDTRY.

  ENDMETHOD.

  METHOD set_bapiret2.

    if bapiret-type = 'E'.
      lcl_logging=>gv_errors_were_logged = abap_true.
    endif.

    TRY.
        go_log->ADD_MSG( I_type = bapiret-type I_ID = bapiret-id I_NUMBER = bapiret-number
          I_MESSAGE_V1 = bapiret-message_v1
          I_MESSAGE_V2 = bapiret-message_v2
          I_MESSAGE_V3 = bapiret-message_v3
          I_MESSAGE_V4 = bapiret-message_v4  ).
      CATCH cx_ishmed_log.                              "#EC NO_HANDLER
* No actual logic on catch
    ENDTRY.

  ENDMETHOD.

  METHOD set_BDCMSGCOLL.
    data: lv_msgnr TYPE SYMSGNO.

    if bdc_message-msgtyp = 'E'.
      lcl_logging=>gv_errors_were_logged = abap_true.
    endif.

    lv_msgnr = bdc_message-msgnr.
    TRY.
        go_log->ADD_MSG( I_type = bdc_message-msgtyp I_ID = bdc_message-MSGID I_NUMBER = lv_msgnr
          I_MESSAGE_V1 = bdc_message-MSGV1
          I_MESSAGE_V2 = bdc_message-MSGV2
          I_MESSAGE_V3 = bdc_message-MSGV3
          I_MESSAGE_V4 = bdc_message-MSGV4 ).
      CATCH cx_ishmed_log.                              "#EC NO_HANDLER
* No actual logic on catch
    ENDTRY.

  ENDMETHOD.

  METHOD set_predefined.
    data: begin of lw_message,
            msgty type sy-msgty,
            msgid type sy-msgid,
            msgno type sy-msgno,
          end of lw_message,
          lv_rest type string.

    lw_message-msgty = codeword(1).
    lw_message-msgno = codeword+1(3).
    split codeword at '(' into lv_rest lw_message-msgid.
    split lw_message-msgid at ')' into lw_message-msgid lv_rest.

    TRY.
        go_log->ADD_MSG( I_type = lw_message-msgty I_ID = lw_message-msgid I_NUMBER = lw_message-msgno ).
      CATCH cx_ishmed_log.                              "#EC NO_HANDLER
* No actual logic on catch
    ENDTRY.

  ENDMETHOD.

ENDCLASS.                    "lcl_logging IMPLEMENTATION
*----------------------------------------------------------------------*
*       CLASS lcl_codemover DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_codemover DEFINITION.
  PUBLIC SECTION.
    CONSTANTS: co_supported_languages TYPE c LENGTH 50 VALUE 'N,D,E,F,I,S',
               co_initial TYPE icon-id VALUE '@P7@',
               co_ok TYPE icon-id VALUE ICON_OKAY,
               co_ok_latest TYPE icon-id VALUE ICON_EXECUTE_OBJECT,
               co_semi_ok TYPE icon-id VALUE '@5D@',
               co_not_ok TYPE icon-id VALUE ICON_CANCEL,
               co_carte_blanche TYPE icon-id VALUE '@7A@',
               co_carte_in TYPE icon-id VALUE '@78@',
               co_carte_out TYPE icon-id VALUE '@79@',
               co_carte_noir TYPE icon-id VALUE '@77@'.

    CONSTANTS: lco_stars type c length 64 VALUE
    '****************************************************************',
               lco_comment1 type c length 64 VALUE
    '*   THIS FILE IS GENERATED BY THE SCREEN PAINTER.              *',
               lco_comment2 type c length 64 VALUE
    '*   NEVER CHANGE IT MANUALLY, PLEASE !                         *',
               lco_dynpro_text type c length 8 VALUE '%_DYNPRO',
               lco_header_text type c length 8 VALUE '%_HEADER',
               lco_params_text type c length 8 VALUE '%_PARAMS',
               lco_descript_text type c length 13 VALUE '%_DESCRIPTION',
               lco_fields_text type c length 8 VALUE '%_FIELDS',
               lco_flowlogic_text type c length 11 VALUE '%_FLOWLOGIC'.

    TYPES: BEGIN OF ty_textpool,
             id TYPE textpoolid,
             key TYPE textpoolky,
             entry TYPE textpooltx,
             length TYPE c LENGTH 12,
           END OF ty_textpool,
           ty_transformations type table of CXSLTDESC.

    CLASS-DATA:
      gv_project TYPE char50,
      gv_path TYPE string,
      gv_package TYPE tadir-devclass,
      gv_transport TYPE tadir-korrnum,
      gt_project_file TYPE STANDARD TABLE OF string,
      gv_string TYPE string,
      BEGIN OF gw_report_status,
        icon_overall TYPE icon-id,
        icon_sap TYPE icon-id,
        date_SAP type d,
        time_SAP type t,
        datetime_SAP_text type c length 30,
        title_SAP type sy-title,
        icon_compare TYPE icon-id,
        icon_front TYPE icon-id,
        date_front type d,
        time_front type t,
        datetime_front_text type c length 30,
        title_front type sy-title,
        icon_info type c length 30,
        title type sy-title,
        additional type string,
      END OF gw_report_status,
      gv_skip_controls type boolean,
      BEGIN OF gw_proceslog,
        processed TYPE n LENGTH 2,
        message TYPE c LENGTH 90,
      END OF gw_proceslog,
      gt_file_table type standard table of FILE_INFO,
      gw_file_info type file_info.

    CLASS-METHODS:
      analyze_source IMPORTING source TYPE sy-repid,
      compose_dirlisting importing path type any,
      coding_download IMPORTING source TYPE sy-repid,
      dynpro_download IMPORTING source TYPE sy-repid,
      status_download IMPORTING source TYPE sy-repid,
      source_transformations IMPORTING source TYPE sy-repid CHANGING transformations type ty_transformations,
      transformation_download IMPORTING transformation TYPE cxsltdesc,
      coding_compare IMPORTING source TYPE sy-repid RETURNING value(result) type string,
      coding_upload IMPORTING source TYPE sy-repid,
      dynpro_upload IMPORTING filename TYPE string exceptions not_executed,
      status_upload IMPORTING source TYPE sy-repid filename TYPE string,
      transformation_upload IMPORTING transformation TYPE cxsltdesc,
      title_extract IMPORTING source TYPE sy-repid RETURNING value(title) type sy-title,
      project_file IMPORTING action TYPE any,
      delete_tmp_object IMPORTING source TYPE sy-repid,
      is_production_system RETURNING value(is_production) TYPE boolean.

ENDCLASS.                    "lcl_codemover DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_codemover IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_codemover IMPLEMENTATION.

  METHOD analyze_source.
    DATA: lv_filename TYPE string,
          BEGIN OF lw_status,
            upload_allowed TYPE boolean,
            download_allowed TYPE boolean,
          END OF lw_status,
          lv_devclass TYPE tadir-devclass,
          lv_state TYPE progdir-state,
          lv_subc TYPE trdir-subc, "Program type
          begin of lw_age,
            sdate type trdir-sdate,
            stime type trdir-stime,
            idate type trdir-idate,
            itime type trdir-itime,
          end of lw_age,
          lw_TRDIRT type TRDIRT.

    CLEAR: gw_report_status, lw_status.

    define additional.
      if gw_report_status-additional is initial.
        gw_report_status-additional = &1.
      else.
        concatenate gw_report_status-additional &1
          into gw_report_status-additional SEPARATED BY ';'.
      endif.
    end-of-definition.

    gw_report_status-icon_sap = co_initial.
    gw_report_status-icon_front = co_initial.
    gw_report_status-icon_overall = co_initial.
    lw_status-upload_allowed = abap_true.
    lw_status-download_allowed = abap_true.

    IF source IS INITIAL.
      lw_status-download_allowed = abap_false.
      lw_status-upload_allowed = abap_false.
    ELSE.
***-----------------------------
*** SAP source
***-----------------------------
* Determine whether report exists:
      SELECT SINGLE subc sdate stime idate itime FROM trdir
        INTO (lv_subc, lw_age-sdate, lw_age-stime, lw_age-idate, lw_age-itime)
        WHERE name = source.
      IF sy-subrc <> 0.
        gw_report_status-icon_sap = co_semi_ok.  "Devclass for source could not be determined
        gw_report_status-icon_info = 'Report/include does not exist'.
        lw_status-download_allowed = abap_false.
      ELSE.
        if lv_subc = 'I'.
          additional 'Include'.
        endif.
* The title:
        select single * from TRDIRT into lw_TRDIRT
          where name = source and
                sprsl = sy-langu.
        if sy-subrc <> 0.
          select * from TRDIRT into lw_TRDIRT
            up to 1 rows
            where name = source.
          endselect.
        endif.
        gw_report_status-title_SAP = lw_TRDIRT-text.
* Determine the age of the report
        if lw_age-sdate >= lw_age-idate.
          gw_report_status-date_SAP = lw_age-sdate.
          if lw_age-stime >= lw_age-itime.
            gw_report_status-time_SAP = lw_age-stime.
          else.
            gw_report_status-time_SAP = lw_age-itime.
          endif.
        else.
          gw_report_status-date_SAP = lw_age-idate.
          gw_report_status-time_SAP = lw_age-itime.
        endif.
* Text with the date and time:
        write gw_report_status-date_SAP DD/MM/YYYY to
          gw_report_status-datetime_SAP_text.
        write gw_report_status-time_SAP USING EDIT MASK '__:__' to
          gw_report_status-datetime_SAP_text+11(5).
* Determine SAP status:
        SELECT SINGLE devclass FROM tadir INTO lv_devclass
          WHERE pgmid = 'R3TR' AND
                object = 'PROG' AND
                obj_name = source.
        IF sy-subrc = 0.
          additional lv_devclass.
          IF lv_devclass(1) CO '$YZ'.
            gw_report_status-icon_sap = co_ok.
* The coding could be inactive...
            SELECT SINGLE state FROM progdir INTO lv_state
              WHERE name = source AND state = 'I'.
            IF sy-subrc = 0.
              gw_report_status-icon_sap = co_not_ok.
              lw_status-upload_allowed = abap_false.
            ENDIF.
          ELSE.
            gw_report_status-icon_sap = co_not_ok.
            gw_report_status-icon_info = 'Not a custom object'.
            lw_status-upload_allowed = abap_false.
          ENDIF.
        ELSE.
          gw_report_status-icon_sap = co_semi_ok.  "Devclass for source could not be determined
          gw_report_status-icon_info = 'Report/include does not exist'.
          lw_status-download_allowed = abap_false.
        ENDIF.
      ENDIF.

* Determine Frontend status
***-----------------------------
*** Frontend source
***-----------------------------
      if gv_path <> ''.
        IF  cl_gui_frontend_services=>directory_exist( gv_path ) = abap_true.
          CONCATENATE gv_path '\' source '.abap.txt' INTO lv_filename.
          IF cl_gui_frontend_services=>file_exist( lv_filename ) = abap_true.
            gw_report_status-icon_front = co_ok.
* Determine the age of the source file:
            CONCATENATE source '.abap.txt' INTO lv_filename.
            read table GT_FILE_TABLE into GW_FILE_INFO
              with key FILENAME = lv_filename.
            if sy-subrc = 0.
              gw_report_status-date_front = GW_FILE_INFO-writedate.
              gw_report_status-time_front = GW_FILE_INFO-writetime.
* Text with the date and time:
              write gw_report_status-date_front DD/MM/YYYY to
                gw_report_status-datetime_front_text.
              write gw_report_status-time_front USING EDIT MASK '__:__' to
                gw_report_status-datetime_front_text+11(5).
* Fetch the report title from text.+.txt file
              gw_report_status-title_front = title_extract( source ).
            endif.
          ELSE.
            gw_report_status-icon_front = co_semi_ok.
            gw_report_status-icon_info = 'Report/include does not exist'.
            lw_status-upload_allowed = abap_false.
          ENDIF.
        ELSE.
          gw_report_status-icon_front = co_not_ok.
          gw_report_status-icon_info = 'Directory could not be read'.
          lw_status-download_allowed = abap_false.
          lw_status-upload_allowed = abap_false.
        ENDIF.
      endif.

      IF lw_status-upload_allowed = abap_true AND lw_status-download_allowed = abap_true.
        gw_report_status-icon_overall = co_carte_blanche.
* Perform source comparison
        gw_report_status-icon_compare = coding_compare( source ).
* Which of the sources is the most recent ?
        if gw_report_status-date_SAP > gw_report_status-date_front or
          ( gw_report_status-date_SAP = gw_report_status-date_front and
            gw_report_status-time_SAP > gw_report_status-time_front ).
          gw_report_status-icon_sap = co_ok_latest.
          gw_report_status-title = gw_report_status-title_SAP.
        else.
          gw_report_status-icon_front = co_ok_latest.
          gw_report_status-title = gw_report_status-title_front.
        endif.

      ELSEIF lw_status-upload_allowed = abap_true.
        gw_report_status-title = gw_report_status-title_front.
      ELSEIF lw_status-download_allowed = abap_true.
        gw_report_status-title = gw_report_status-title_SAP.
      ELSE.
        gw_report_status-icon_overall = co_carte_noir.
      ENDIF.
    ENDIF.

  ENDMETHOD.                    "analyze_source

  METHOD compose_dirlisting.
    data: lv_path_string type string,
          lv_count type i.

    lv_path_string = path.
    clear gt_file_table.

    cl_gui_frontend_services=>directory_list_files(
      exporting
        directory = lv_path_string
        files_only = abap_true
      changing
        file_table = gt_file_table
        count = lv_count ).

  ENDMETHOD.

  METHOD coding_download.
    DATA: lt_source TYPE TABLE OF string,
          lt_textpool TYPE TABLE OF textpool,
          lw_textpool TYPE textpool,
          lt_textpool_asc TYPE TABLE OF ty_textpool,
          lw_textpool_asc TYPE ty_textpool,
          lv_filename TYPE string,
          lv_message TYPE string,
          lt_languages TYPE STANDARD TABLE OF sy-langu,
          lv_language TYPE sy-langu,
          lt_transformations type ty_transformations,
          lv_transformation type CXSLTDESC.

    lcl_logging=>set_message( message = 'Download for &' par1 = source ).
    READ REPORT source INTO lt_source.
    IF sy-subrc = 0.
* Create the file
      CONCATENATE gv_path '\' source '.abap.txt' INTO lv_filename.
      lcl_logging=>set_message( lv_filename ).

      CALL FUNCTION 'GUI_DOWNLOAD'
        EXPORTING
          filename = lv_filename
        TABLES
          data_tab = lt_source
        EXCEPTIONS
          OTHERS   = 4.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE 'W' NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ELSE.
      lcl_logging=>set_error( 'Report source could not be read' ).
      exit.
    ENDIF.

    SPLIT co_supported_languages AT ',' INTO TABLE lt_languages.
    LOOP AT lt_languages INTO lv_language.

      READ TEXTPOOL source INTO lt_textpool LANGUAGE lv_language.
      IF sy-subrc = 0.
* Transform the lt_textpool (which holds an integer value) into a full character format:
        CLEAR lt_textpool_asc[].
        LOOP AT lt_textpool INTO lw_textpool.
          MOVE-CORRESPONDING lw_textpool TO lw_textpool_asc.
          APPEND lw_textpool_asc TO lt_textpool_asc.
        ENDLOOP.
        CONCATENATE gv_path '\' source '.text.' lv_language '.txt' INTO lv_filename.
        lcl_logging=>set_message( lv_filename ).
        CALL FUNCTION 'GUI_DOWNLOAD'
          EXPORTING
            filename = lv_filename
          TABLES
            data_tab = lt_textpool_asc
          EXCEPTIONS
            OTHERS   = 4.
        IF sy-subrc <> 0.
          lcl_logging=>set_syst( ).
          MESSAGE ID sy-msgid TYPE 'W' NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
      ENDIF.
    ENDLOOP.

    dynpro_download( source ).

    status_download( source ).

    clear: lt_transformations[].
    source_transformations( exporting source = source changing transformations = lt_transformations ).
    loop at lt_transformations into lv_transformation.
      transformation_download( lv_transformation ).
    endloop.

  ENDMETHOD.                    "coding_download

  METHOD dynpro_download.
    DATA: lt_d020s TYPE STANDARD TABLE OF d020s,
          lw_d020s TYPE d020s,
          lw_d020t TYPE d020t,
          lw_scr_chhead TYPE scr_chhead,
          lt_d021s TYPE STANDARD TABLE OF d021s,
          lt_scr_chfld TYPE STANDARD TABLE OF scr_chfld,
          lw_scr_chfld TYPE scr_chfld,
          lt_file_content TYPE STANDARD TABLE OF scr_chfld,
          lt_flowlogic TYPE dyn_flowlist,
          lv_filename TYPE string,
          lv_prog_len TYPE p.

    DEFINE add_to_file.
      append &1 to lt_file_content.
    END-OF-DEFINITION.

    SELECT * FROM d020s INTO TABLE lt_d020s
      WHERE prog = source AND dnum <> '1000'.

    IF sy-subrc = 0.
* For all screens/Dynpro's (except the 1000)
      LOOP AT lt_d020s INTO lw_d020s.
* Compose filename
        CONCATENATE gv_path '\' source '.dynpro.' lw_d020s-dnum '.txt' INTO lv_filename.
        lcl_logging=>set_message( lv_filename ).
        SELECT * FROM d020t INTO lw_d020t
          UP TO 1 ROWS
          WHERE prog = source AND dynr = lw_d020s-dnum.
        ENDSELECT.

* Compose file content, first gather Dynpro information
        CALL FUNCTION 'RS_IMPORT_DYNPRO'
          EXPORTING
*           DYLANG = ' '
            dyname = lw_d020s-prog
            dynumb = lw_d020s-dnum
          TABLES
            ftab   = lt_d021s
            pltab  = lt_flowlogic
          EXCEPTIONS
            OTHERS = 4.
        IF sy-subrc <> 0.
          lcl_logging=>set_syst( ).
          MESSAGE ID sy-msgid TYPE 'W' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          CONTINUE.
        ENDIF.

        CALL FUNCTION 'RS_SCRP_HEADER_RAW_TO_CHAR'
          EXPORTING
            header_int  = lw_d020s
          IMPORTING
            header_char = lw_scr_chhead.

        CALL FUNCTION 'RS_SCRP_FIELDS_RAW_TO_CHAR'
          TABLES
            fields_int  = lt_d021s
            fields_char = lt_scr_chfld.

* Compose the file:
        CLEAR: lt_file_content[].
        add_to_file:
          lco_stars, lco_comment1, lco_comment2, lco_stars,
          lco_dynpro_text, lw_scr_chhead-prog, lw_scr_chhead-dnum, sy-saprl.

        DESCRIBE FIELD lw_d020s-prog LENGTH lv_prog_len IN CHARACTER MODE.
        CLEAR lw_scr_chfld.
        lw_scr_chfld(16) = lv_prog_len.
        add_to_file: lw_scr_chfld,
          lco_header_text, lw_scr_chhead,
          lco_descript_text, lw_d020t-dtxt,
          lco_fields_text.
        LOOP AT lt_scr_chfld INTO lw_scr_chfld.
          add_to_file lw_scr_chfld.
        ENDLOOP.
        add_to_file: lco_flowlogic_text.
        LOOP AT lt_flowlogic INTO lw_scr_chfld.
          add_to_file lw_scr_chfld.
        ENDLOOP.
        add_to_file lco_params_text.
* Store the file
        CALL FUNCTION 'GUI_DOWNLOAD'
          EXPORTING
            filename              = lv_filename
            write_field_separator = 'X'
            trunc_trailing_blanks = 'X'
*           WRITE_LF              = 'X'
*           CODEPAGE              = ' '
          TABLES
            data_tab              = lt_file_content
          EXCEPTIONS
            OTHERS                = 4.

        IF sy-subrc <> 0.
          lcl_logging=>set_syst( ).
          MESSAGE ID sy-msgid TYPE 'W' NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.                    "dynpro_download

  METHOD status_download.
    DATA: lv_program TYPE trdir-name,
          lw_adm TYPE rsmpe_adm,
          lt_sta TYPE STANDARD TABLE OF rsmpe_stat,
          lt_fun TYPE STANDARD TABLE OF rsmpe_funt,
          lt_men TYPE STANDARD TABLE OF rsmpe_men,
          lt_mtx TYPE STANDARD TABLE OF rsmpe_mnlt,
          lt_act TYPE STANDARD TABLE OF rsmpe_act,
          lt_but TYPE STANDARD TABLE OF rsmpe_but,
          lt_pfk TYPE STANDARD TABLE OF rsmpe_pfk,
          lt_set TYPE STANDARD TABLE OF rsmpe_staf,
          lt_doc TYPE STANDARD TABLE OF rsmpe_atrt,
          lt_tit TYPE STANDARD TABLE OF rsmpe_titt,
          lt_biv TYPE STANDARD TABLE OF rsmpe_buts,
          lt_file_content TYPE STANDARD TABLE OF string,
          lv_filename TYPE string,
          lv_buffer TYPE c LENGTH 500.

    DEFINE absorb.
      loop at lt_&1 into lv_buffer.
        shift lv_buffer right by 3 places.
        lv_buffer(3) = '&1'.
        append lv_buffer to lt_file_content.
      endloop.
    END-OF-DEFINITION.

    lv_program = source.
    CALL FUNCTION 'RS_CUA_INTERNAL_FETCH'
      EXPORTING
        program              = lv_program
        with_second_language = 'X'
        without_texts        = ' '
      IMPORTING
        adm                  = lw_adm
      TABLES
        sta                  = lt_sta
        fun                  = lt_fun
        men                  = lt_men
        mtx                  = lt_mtx
        act                  = lt_act
        but                  = lt_but
        pfk                  = lt_pfk
        set                  = lt_set
        doc                  = lt_doc
        tit                  = lt_tit
        biv                  = lt_biv
      EXCEPTIONS
        OTHERS               = 4.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ELSE.

      CONCATENATE gv_path '\' source '.status.txt' INTO lv_filename.
      lcl_logging=>set_message( lv_filename ).

      CLEAR: lt_file_content[].

      lv_buffer = lw_adm.
      SHIFT lv_buffer RIGHT BY 3 PLACES.
      lv_buffer(3) = 'ADM'.
      APPEND lv_buffer TO lt_file_content.
      absorb: sta, fun, men, mtx, act, but, pfk, set, doc, tit, biv.

      IF NOT lt_file_content[] IS INITIAL.
        CALL FUNCTION 'GUI_DOWNLOAD'
          EXPORTING
            filename              = lv_filename
            trunc_trailing_blanks = 'X'
*           WRITE_LF              = 'X'
*           CODEPAGE              = ' '
          TABLES
            data_tab              = lt_file_content
          EXCEPTIONS
            OTHERS                = 4.
        IF sy-subrc <> 0.
          lcl_logging=>set_syst( ).
          MESSAGE ID sy-msgid TYPE 'W' NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.                    "status_download

  METHOD source_transformations.
* Check whether there are references to transformations in the Abap source
    data: lt_sourcecode type standard table of char255,
          lt_keywords type standard table of char50,
          lt_statements type standard table of SSTMNT,
          lw_statement TYPE SSTMNT,
          lt_tokens type standard table of STOKES,
          lw_token TYPE STOKES,
          lv_transformation_name_next type boolean.

    clear lt_keywords[].
    append 'CALL' to lt_keywords.

    read report source into lt_sourcecode.
    scan abap-source lt_sourcecode
      KEYWORDS FROM lt_keywords
      STATEMENTS INTO lt_statements
      TOKENS INTO lt_tokens.

    loop at LT_STATEMENTS into lw_statement.
      clear: lv_transformation_name_next.
      loop at lt_tokens into lw_token from lw_statement-from to lw_statement-to.
        if lw_token-STR = 'TRANSFORMATION'.
          lv_transformation_name_next = abap_true.
        elseif lv_transformation_name_next = abap_true.
          append lw_token-STR to transformations.
          clear lv_transformation_name_next.
        endif.
      endloop.
    endloop.

  ENDMETHOD.

  METHOD transformation_download.
    data: lt_XSLT_SOURCE type O2PAGELINE_TABLE,
          lw_XSLT_SOURCE type O2PAGELINE,
          lt_XSLT_ATTRIBUTES type standard table of O2XSLTATTR,
          lw_XSLT_ATTRIBUTES type O2XSLTATTR,
          lt_XSLT_TEXTS type standard table of O2XSLTTEXT,
          lw_XSLT_TEXT type O2XSLTTEXT,
          lt_file_content TYPE STANDARD TABLE OF string,
          lv_filename TYPE string.

    CALL FUNCTION 'XSLT_GET_OBJECT'
      EXPORTING
        XSLT_NAME       = transformation
*       STATE           = 'A'
      TABLES
        XSLT_SOURCE     = lt_XSLT_SOURCE
        XSLT_ATTRIBUTES = lt_XSLT_ATTRIBUTES
        XSLT_TEXTS      = lt_XSLT_TEXTS
      EXCEPTIONS
        OTHERS          = 4.

    if sy-subrc = 0.

      CONCATENATE gv_path '\' transformation '.strans.txt' INTO lv_filename.
      lcl_logging=>set_message( lv_filename ).
* We have an existing (simple) transformation
      clear: lt_file_content[].
      append '%_ATTRIBUTES' to lt_file_content.
      read table lt_XSLT_ATTRIBUTES into lw_XSLT_ATTRIBUTES index 1.
      append lw_XSLT_ATTRIBUTES to lt_file_content.

      append '%_TEXTS' to lt_file_content.
      loop at lt_XSLT_TEXTS into lw_XSLT_TEXT.
        append lw_XSLT_TEXT to lt_file_content.
      endloop.

      append '%_SOURCE' to lt_file_content.
      loop at lt_XSLT_SOURCE into lw_XSLT_SOURCE.
        append lw_XSLT_SOURCE to lt_file_content.
      endloop.

      CALL FUNCTION 'GUI_DOWNLOAD'
        EXPORTING
          filename              = lv_filename
          trunc_trailing_blanks = 'X'
        TABLES
          data_tab              = lt_file_content
        EXCEPTIONS
          OTHERS                = 4.
      IF sy-subrc <> 0.
        lcl_logging=>set_syst( ).
        MESSAGE ID sy-msgid TYPE 'W' NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    endif.

  ENDMETHOD.

  METHOD coding_compare.

    data: lt_source_SAP TYPE TABLE OF string,
          lt_source_LOCAL TYPE TABLE OF string,
          lv_filename type string.

    result = '@5F@'.
* Read SAP coding version
    READ REPORT source INTO lt_source_SAP.
    IF sy-subrc <> 0.
      result = 'Compare error'.
      exit.
    ENDIF.

* Read PC version
    CONCATENATE gv_path '\' source '.abap.txt' INTO lv_filename.
    CALL FUNCTION 'GUI_UPLOAD'
      EXPORTING
        filename = lv_filename
      TABLES
        data_tab = lt_source_LOCAL
      EXCEPTIONS
        OTHERS   = 4.
    IF sy-subrc <> 0.
      result = 'Compare error'.
      exit.
    ENDIF.

    if lt_source_SAP[] = lt_source_LOCAL[].
      result = '@20@'.
    else.
      result = '@2B@'.
    endif.
* Determine the youngest source

  ENDMETHOD.

  METHOD dynpro_upload.

* Function module RS_DYNPRO_UPLOAD was the source and inspiration of this logic
    data: lv_filename type string,
          lw_D020T type D020T,
          BEGIN OF lw_dynpro,
            prog type d020s-prog,
            dnum type d020s-dnum,
          END OF lw_dynpro,
          lw_header_scr type scr_chhead,
          lw_header type D020S,
          lt_dynpro_scr type standard table of scr_chfld,
          lw_dynpro_scr type scr_chfld,
          lt_fields_scr type standard table of scr_chfld,
          lw_fields_scr type scr_chfld,
          lt_fields type standard table of D021S,
          lt_flowlogic type standard table of D022S,
          lw_flowlogic type D022S,
          lt_params type standard table of D023S,
          lw_params type D023S,
          lv_prog_len TYPE p,
          lv_prog_len_akt TYPE p,
          lv_processing_status type c length 1,
          lv_description type D020T-DTXT,
          lv_dynpro_rel type c length 4.

    data: lt_bdcdata type standard table of bdcdata,
          lw_bdcdata type bdcdata,
          lt_bdcmsgcoll type standard table of bdcmsgcoll,
          lw_bdcmsgcoll type bdcmsgcoll.

    define source_check.
      READ TABLE lt_dynpro_scr INDEX &1 into lw_dynpro_scr.
      IF lw_dynpro_scr <> &2.
        MESSAGE e250(37) RAISING not_executed.
      ENDIF.
    end-of-definition.
    define bdc_add.
      clear lw_bdcdata.
      lw_bdcdata-dynbegin = &1.
      if &1 = 'X'.
        lw_bdcdata-program = &2.
        lw_bdcdata-dynpro = &3.
      else.
        lw_bdcdata-fnam = &2.
        lw_bdcdata-fval = &3.
      endif.
      append lw_bdcdata to lt_bdcdata.
    end-of-definition.

* Fetch the file content for a dynpro
    clear: lt_dynpro_scr[].
    concatenate gv_path '\' filename into lv_filename.
    lcl_logging=>set_message( lv_filename ).
    CALL FUNCTION 'GUI_UPLOAD'
      EXPORTING
        filename            = lv_filename
        filetype            = 'ASC'
        has_field_separator = 'X'
      TABLES
        data_tab            = lt_dynpro_scr
      EXCEPTIONS
        OTHERS              = 4.
    IF sy-subrc <> 0.
      IF sy-msgty <> space.
        lcl_logging=>set_syst( ).
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_executed.
      ELSE.
        lcl_logging=>set_predefined( 's604(eu)' ).
        MESSAGE s604(eu) RAISING not_executed.
      ENDIF.
    ENDIF.

* Is it really a dynpro file ? A series of tests
    source_check: 1 lco_stars,
                  2 lco_comment1,
                  3 lco_comment2,
                  4 lco_stars,
                  5 lco_dynpro_text.

* Determine dynpro name
    READ TABLE lt_dynpro_scr INDEX 6 into lw_dynpro_scr.
    lw_dynpro-prog = lw_dynpro_scr.
    READ TABLE lt_dynpro_scr INDEX 7 into lw_dynpro_scr.
    lw_dynpro-dnum = lw_dynpro_scr.

* Fill header_scr, lt_fields_scr, lt_dynpro_scr, and dynpro parameters
    clear: lt_fields_scr[], lt_flowlogic[], lt_params[].
    lv_processing_status = ' '.
    LOOP AT lt_dynpro_scr into lw_dynpro_scr.
      CASE lw_dynpro_scr.
        WHEN lco_dynpro_text.
          lv_processing_status = '1'.    " '%_DYNPRO'
        WHEN lco_header_text.
          lv_processing_status = 'H'.    " '%_HEADER'
        WHEN lco_descript_text.
          lv_processing_status = 'D'.    " '%_DESCRIPT'
        WHEN lco_fields_text.
          lv_processing_status = 'F'.    " '%_FIELDS'
        WHEN lco_flowlogic_text.
          lv_processing_status = 'E'.    " '%_FLOWLOGIC'
        WHEN lco_params_text.
          lv_processing_status = 'P'.    " '%_PARAMS'
        WHEN OTHERS.
          CASE lv_processing_status.
            WHEN '1'. "First line of %_DYNPRO info, holds the report name (ignored)
              lv_processing_status = '2'.
            WHEN '2'. "Second line of %_DYNPRO info, holds the dynpro number (ignored)
              lv_processing_status = '3'.
            WHEN '3'. "Third line of %_DYNPRO info, holds the version / release (ignored)
              lv_processing_status = '4'.
            WHEN '4'. "Fourth line of %_DYNPRO info, holds the program length (ignored)
              lv_prog_len = lw_dynpro_scr.
              lv_processing_status = 'H'.
            WHEN 'H'.
              DESCRIBE FIELD lw_d020t-prog LENGTH lv_prog_len_akt IN CHARACTER MODE.
              MOVE lw_dynpro_scr(lv_prog_len) TO lw_header_scr(lv_prog_len_akt).
              MOVE lw_dynpro_scr+lv_prog_len  TO lw_header_scr+lv_prog_len_akt.
              lv_processing_status = ' '.
            WHEN 'D'.
              lv_description = lw_dynpro_scr.
            WHEN 'F'.
              lw_fields_scr = lw_dynpro_scr.
              APPEND lw_fields_scr to lt_fields_scr.
            WHEN 'E'.
              lw_flowlogic = lw_dynpro_scr.
              APPEND lw_flowlogic to lt_flowlogic.
            WHEN 'P'.
              lw_params = lw_dynpro_scr.
              APPEND lw_params to lt_params.
          ENDCASE.
      ENDCASE.
    ENDLOOP.

* Translate header
    CALL FUNCTION 'RS_SCRP_HEADER_CHAR_TO_RAW'
      EXPORTING
        header_char = lw_header_scr
      IMPORTING
        header_int  = lw_header
      EXCEPTIONS
        OTHERS      = 4.
    if sy-subrc <> 0.
      lcl_logging=>set_predefined( 's604(eu)' ).
      MESSAGE s604(eu) raising not_executed.
    endif.

* Translate fieldlist
    CALL FUNCTION 'RS_SCRP_FIELDS_CHAR_TO_RAW'
      TABLES
        fields_char = lt_fields_scr
        fields_int  = lt_fields
      EXCEPTIONS
        OTHERS      = 4.
    if sy-subrc <> 0.
      lcl_logging=>set_predefined( 's604(eu)' ).
      MESSAGE s604(eu) raising not_executed.
    endif.

* Release check
    CALL FUNCTION 'RS_DYNPRO_RELEASE_GET'
      EXPORTING
        dynpro_header  = lw_header
      IMPORTING
        dynpro_release = lv_dynpro_rel.
    if lv_dynpro_rel > '7.00'.
      lcl_logging=>set_predefined( 's604(eu)' ).
      MESSAGE s604(eu) raising not_executed.
    endif.

* Check the dynpro health
    CALL FUNCTION 'RS_SCRP_DYNPRO_CHECK'
      TABLES
        fieldlist            = lt_fields
        flowlogic            = lt_flowlogic
        params               = lt_params
      CHANGING
        header               = lw_header
      EXCEPTIONS
        damaged_but_repaired = 1
        damaged              = 2
        OTHERS               = 3.
    CASE sy-subrc.
      WHEN 2.
        lcl_logging=>set_syst( ).
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                RAISING not_executed.
      WHEN 3.
        lcl_logging=>set_syst( ).
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                RAISING not_executed.
    ENDCASE.

* Create the Dynpro
*-------------------------------------------------------------------------------
    export dynpro lw_header lt_fields lt_flowlogic lt_params ID lw_dynpro.
*-------------------------------------------------------------------------------

* Set the description on the newly created Dynpro, through BDC session
    clear: lt_bdcdata[].
* bdc_add 'X' 'PROGRAM_NAME' 'SCREEN NUMBER'.
* bdc_add ' ' 'FIELDNAME' 'FIELDVALUE'.
    bdc_add: 'X' 'SAPLWBSCREEN' '0010',
             ' ' 'BDC_OKCODE' '=AEND',
             ' ' 'RS37A-DYNPROG' lw_header-PROG,
             ' ' 'FELD-DYNNR' lw_header-DNUM,
             ' ' 'RS37A-FUNHD' 'X',
             'X' 'SAPLWBSCREEN' '2000',
             ' ' 'RS37A-DTXT' lv_description,
             ' ' 'BDC_OKCODE' '=UPD',
             'X' 'SAPLSEWORKINGAREA' '0205',
             ' ' 'BDC_OKCODE' '=WEIT',
             'X' 'SAPLWBSCREEN' '2000',
             ' ' 'BDC_OKCODE' '=WB_BACK',
             'X' 'SAPLWBSCREEN' '0010',
             ' ' 'BDC_OKCODE' '=NEW'.
    call transaction 'SE51' using lt_bdcdata mode 'N' messages into lt_BDCMSGCOLL.

    read table lt_BDCMSGCOLL with key msgtyp = 'E' TRANSPORTING NO FIELDS.
    if sy-subrc = 0.
      lcl_logging=>set_message( 'Dynpro title (trx SE51 call)' ).
      loop at lt_BDCMSGCOLL into lw_BDCMSGCOLL.
        lcl_logging=>set_BDCMSGCOLL( lw_BDCMSGCOLL ).
      endloop.
    endif.

  ENDMETHOD.

  METHOD coding_upload.
    DATA: lv_TRDIR_NAME type TRDIR-NAME,
          lt_source TYPE TABLE OF string,
          lt_textpool TYPE TABLE OF textpool,
          lw_textpool TYPE textpool,
          lt_textpool_asc TYPE TABLE OF ty_textpool,
          lw_textpool_asc TYPE ty_textpool,
          lv_filename TYPE string,
          lv_message TYPE string,
          lt_languages TYPE STANDARD TABLE OF sy-langu,
          lv_language TYPE sy-langu,
          lw_tadir TYPE tadir,
          lt_bdcdata TYPE STANDARD TABLE OF bdcdata,
          lw_bdcdata TYPE bdcdata,
          lt_BDCMSGCOLL type standard table of BDCMSGCOLL,
          lw_BDCMSGCOLL type BDCMSGCOLL,
          lv_filter TYPE string,
          lt_filenames TYPE STANDARD TABLE OF file_info,
          lw_filename TYPE file_info,
          lv_filecount TYPE i,

          lt_transformations type ty_transformations,
          lv_transformation type CXSLTDESC.

* bdc_add 'X' 'PROGRAM_NAME' 'SCREEN NUMBER'.
* bdc_add ' ' 'FIELDNAME' 'FIELDVALUE'.
    DEFINE bdc_add.
      clear lw_bdcdata.
      lw_bdcdata-dynbegin = &1.
      if &1 eq 'X'.
        lw_bdcdata-program = &2.
        lw_bdcdata-dynpro = &3.
      else.
        lw_bdcdata-fnam = &2.
        lw_bdcdata-fval = &3.
      endif.
      append lw_bdcdata to lt_bdcdata.
    END-OF-DEFINITION.

    CONCATENATE source '*' INTO lv_filter.
* First fetch a listing of all available files on the source:
    cl_gui_frontend_services=>directory_list_files(
      EXPORTING directory = gv_path
                filter = lv_filter
                files_only = abap_true
      CHANGING  file_table = lt_filenames
                count = lv_filecount ).

    CLEAR: lt_source[], lt_textpool[].
    lcl_logging=>set_message( message = 'Upload for &' par1 = source ).
* Lock the object (in an SE38 editor ?)
    lv_TRDIR_NAME = source.
    CALL FUNCTION 'ENQUEUE_ESRDIRE'
      EXPORTING
        NAME   = lv_TRDIR_NAME
      EXCEPTIONS
        OTHERS = 4.
    IF SY-SUBRC <> 0.
      lcl_logging=>set_error( message = 'Object locked (&)' par1 = sy-msgv1 ).
      exit.
    ENDIF.

* Read the file
    CONCATENATE gv_path '\' source '.abap.txt' INTO lv_filename.
    lcl_logging=>set_message( lv_filename ).
    CALL FUNCTION 'GUI_UPLOAD'
      EXPORTING
        filename = lv_filename
      TABLES
        data_tab = lt_source
      EXCEPTIONS
        OTHERS   = 4.
    IF sy-subrc <> 0.
      lcl_logging=>set_error( 'File read error').
      lcl_logging=>set_syst( ).
    ELSE.
*-----------------------------------------------------
      INSERT REPORT source FROM lt_source.
*-----------------------------------------------------

      SPLIT co_supported_languages AT ',' INTO TABLE lt_languages.
      LOOP AT lt_languages INTO lv_language.
        CLEAR: lt_textpool_asc[].
        CONCATENATE gv_path '\' source '.text.' lv_language '.txt' INTO lv_filename.
        CALL FUNCTION 'GUI_UPLOAD'
          EXPORTING
            filename        = lv_filename
          TABLES
            data_tab        = lt_textpool_asc
          EXCEPTIONS
            file_open_error = 1
            OTHERS          = 4.
        case sy-subrc.
          when 0.
            lcl_logging=>set_message( lv_filename ).
          when 1.
            CONTINUE.
          when 4.
            lcl_logging=>set_message( lv_filename ).
            lcl_logging=>set_syst( ).
        endcase.
        CLEAR: lt_textpool[].
* Move the file format to the internal format
        LOOP AT lt_textpool_asc INTO lw_textpool_asc.
          MOVE-CORRESPONDING lw_textpool_asc TO lw_textpool.
          APPEND lw_textpool TO lt_textpool.
        ENDLOOP.
        INSERT TEXTPOOL source FROM lt_textpool LANGUAGE lv_language.
      ENDLOOP.

      CALL FUNCTION 'DEQUEUE_ESRDIRE'
        EXPORTING
          NAME = lv_TRDIR_NAME.

* The TADIR entry for this new report may not be availale yet - if it is missing, a
* DBC session form SM31 table TADIR is started, for $TMP or a custom package with
* transport request number.
      SELECT SINGLE * FROM tadir INTO lw_tadir
        WHERE pgmid = 'R3TR' AND object = 'PROG' AND obj_name = source.
      IF sy-subrc <> 0.

        IF gv_package = '$TMP'.
* Compose a new entry on TADIR, through SM31 access:
          CLEAR: lt_bdcdata[], lt_BDCMSGCOLL[].
          bdc_add: 'X' 'SAPMSVMA' '0100',
                   ' ' 'VIEWNAME' 'TADIR',
                   ' ' 'VIMDYNFLDS-LTD_DTA_NO' 'X',
                   ' ' 'BDC_OKCODE' '=UPD',
                   'X' 'RSWBO052' '1000',
                   ' ' 'MAX1000' 'X',
                   ' ' 'BDC_OKCODE' '=FC01',
                   'X' 'SAPLSTR6' '0200',
                   ' ' 'KO007-L_PGMID' 'R3TR',
                   ' ' 'KO007-L_OBJECT' 'PROG',
                   ' ' 'KO007-L_OBJ_NAME' source,
                   ' ' 'BDC_OKCODE' '=CREA',
                   'X' 'SAPLSTRD' '0100',
                   ' ' 'KO007-L_DEVCLASS' '$TMP',
                   ' ' 'BDC_OKCODE' '=TEMP',
                   'X' 'SAPMSSY0' '0120',
                   ' ' 'BDC_OKCODE' '=BAC2',
                   'X' 'RSWBO052' '1000',
                   ' ' 'BDC_OKCODE' '/EE',
                   'X' 'SAPMSVMA' '0100',
                   ' ' 'BDC_OKCODE' '/EBACK'.

          CALL TRANSACTION 'SM31' USING lt_bdcdata MODE 'E' messages into lt_BDCMSGCOLL.

          read table lt_BDCMSGCOLL with key msgtyp = 'E' TRANSPORTING NO FIELDS.
          if sy-subrc = 0.
            lcl_logging=>set_message( 'Catalog for repository objects (TADIR) - $TMP' ).
            loop at lt_BDCMSGCOLL into lw_BDCMSGCOLL.
              lcl_logging=>set_BDCMSGCOLL( lw_BDCMSGCOLL ).
            endloop.
          endif.

        ELSE.

* Compose a new entry on TADIR, through SM31 access:
          CLEAR: lt_bdcdata[], lt_BDCMSGCOLL[].
          bdc_add: 'X' 'SAPMSVMA' '0100',
                   ' ' 'VIEWNAME' 'TADIR',
                   ' ' 'VIMDYNFLDS-LTD_DTA_NO' 'X',
                   ' ' 'BDC_OKCODE' '=UPD',
                   'X' 'RSWBO052' '1000',
                   ' ' 'MAX1000' 'X',
                   ' ' 'BDC_OKCODE' '=FC01',
                   'X' 'SAPLSTR6' '0200',
                   ' ' 'KO007-L_PGMID' 'R3TR',
                   ' ' 'KO007-L_OBJECT' 'PROG',
                   ' ' 'KO007-L_OBJ_NAME' source,
                   ' ' 'BDC_OKCODE' '=CREA',
                   'X' 'SAPLSTRD' '0100',
                   ' ' 'KO007-L_DEVCLASS' gv_package,
                   ' ' 'BDC_OKCODE' '=ADD',
                   'X' 'SAPLSTRD' '0300',
                   ' ' 'KO008-TRKORR' gv_transport,
                   ' ' 'BDC_OKCODE' '=LOCK',
                   'X' 'SAPMSSY0' '0120',
                   ' ' 'BDC_OKCODE' '=BAC2',
                   'X' 'RSWBO052' '1000',
                   ' ' 'BDC_OKCODE' '/EE',
                   'X' 'SAPMSVMA' '0100',
                   ' ' 'BDC_OKCODE' '/EBACK'.

          CALL TRANSACTION 'SM31' USING lt_bdcdata MODE 'E' messages into lt_BDCMSGCOLL.

          read table lt_BDCMSGCOLL with key msgtyp = 'E' TRANSPORTING NO FIELDS.
          if sy-subrc = 0.
            lcl_logging=>set_message( 'Catalog for repository objects (TADIR)' ).
            loop at lt_BDCMSGCOLL into lw_BDCMSGCOLL.
              lcl_logging=>set_BDCMSGCOLL( lw_BDCMSGCOLL ).
            endloop.
          endif.

        ENDIF.

      ENDIF.

*----------------------------------------------------------------------
* Check other components: any menu's to be processed ?  Dynpro's ?
      LOOP AT lt_filenames INTO lw_filename.
        IF lw_filename-filename CS '.status.txt'.
          lv_filename = lw_filename-filename.
          status_upload( source = source filename = lv_filename ).
        ENDIF.

        IF lw_filename-filename CP '*.dynpro.++++.txt'.
          lv_filename = lw_filename-filename.
          dynpro_upload( exporting filename = lv_filename exceptions not_executed = 0 ).
        ENDIF.
      ENDLOOP.
*----------------------------------------------------------------------

* Check the transformations - by extraxting a list of them from the source code that
* was just saved:
      source_transformations( exporting source = source changing transformations = lt_transformations ).
      loop at lt_transformations into lv_transformation.
        transformation_upload( lv_transformation ).
      endloop.

    ENDIF.

  ENDMETHOD.                    "coding_upload

  METHOD status_upload.
    DATA: lv_program TYPE trdir-name,
          lw_adm TYPE rsmpe_adm,
          lt_sta TYPE STANDARD TABLE OF rsmpe_stat,
          lt_fun TYPE STANDARD TABLE OF rsmpe_funt,
          lt_men TYPE STANDARD TABLE OF rsmpe_men,
          lt_mtx TYPE STANDARD TABLE OF rsmpe_mnlt,
          lt_act TYPE STANDARD TABLE OF rsmpe_act,
          lt_but TYPE STANDARD TABLE OF rsmpe_but,
          lt_pfk TYPE STANDARD TABLE OF rsmpe_pfk,
          lt_set TYPE STANDARD TABLE OF rsmpe_staf,
          lt_doc TYPE STANDARD TABLE OF rsmpe_atrt,
          lt_tit TYPE STANDARD TABLE OF rsmpe_titt,
          lt_biv TYPE STANDARD TABLE OF rsmpe_buts,
          lt_file_content TYPE STANDARD TABLE OF string,
          lv_filename TYPE string,
          lv_buffer TYPE c LENGTH 500,
          lv_recordtype TYPE c LENGTH 3,
          lw_trkey TYPE trkey.

    CLEAR: lt_file_content[].
    concatenate gv_path '\' filename into lv_filename.
    lcl_logging=>set_message( lv_filename ).
    CALL FUNCTION 'GUI_UPLOAD'
      EXPORTING
        filename = lv_filename
      TABLES
        data_tab = lt_file_content
      EXCEPTIONS
        OTHERS   = 4.
    if sy-subrc = 4.
      lcl_logging=>set_syst( ).
    endif.
    CHECK sy-subrc = 0.

    CLEAR: lt_sta[], lt_fun[], lt_men[], lt_mtx[], lt_act[], lt_but[], lt_pfk[], lt_set[], lt_doc[], lt_tit[].
    LOOP AT lt_file_content INTO lv_buffer.
      lv_recordtype = lv_buffer(3).
      SHIFT lv_buffer LEFT BY 3 PLACES.
      CASE lv_recordtype.
        WHEN 'ADM'. lw_adm = lv_buffer.
        WHEN 'STA'. APPEND lv_buffer TO lt_sta.
        WHEN 'FUN'. APPEND lv_buffer TO lt_fun.
        WHEN 'MEN'. APPEND lv_buffer TO lt_men.
        WHEN 'MTX'. APPEND lv_buffer TO lt_mtx.
        WHEN 'ACT'. APPEND lv_buffer TO lt_act.
        WHEN 'BUT'. APPEND lv_buffer TO lt_but.
        WHEN 'PFK'. APPEND lv_buffer TO lt_pfk.
        WHEN 'SET'. APPEND lv_buffer TO lt_set.
        WHEN 'DOC'. APPEND lv_buffer TO lt_doc.
        WHEN 'TIT'. APPEND lv_buffer TO lt_tit.
        WHEN 'BIV'. APPEND lv_buffer TO lt_biv.
      ENDCASE.
    ENDLOOP.
    CHECK sy-subrc = 0.

    lv_program = source.
    lw_trkey-devclass = gv_package.
    lw_trkey-obj_type = 'PROG'.
    lw_trkey-obj_name = source.
    lw_trkey-sub_type	= 'CUAD'.
    lw_trkey-sub_name = source.

    CALL FUNCTION 'RS_CUA_INTERNAL_WRITE'
      EXPORTING
        program  = lv_program
        language = sy-langu
        tr_key   = lw_trkey
        adm      = lw_adm
*       STATE    = 'A'
      TABLES
        sta      = lt_sta
        fun      = lt_fun
        men      = lt_men
        mtx      = lt_mtx
        act      = lt_act
        but      = lt_but
        pfk      = lt_pfk
        set      = lt_set
        doc      = lt_doc
        tit      = lt_tit
        biv      = lt_biv
      EXCEPTIONS
        OTHERS   = 4.
    IF sy-subrc = 4.
      lcl_logging=>set_syst( ).
    ENDIF.

  ENDMETHOD.                    "status_upload

  METHOD transformation_upload.
* Transformations are only uploaded if they don't already exist. So if you want to
* renew your transformation, first delete it from the system.
    data: lt_XSLT_SOURCE type O2PAGELINE_TABLE,
          lw_XSLT_SOURCE type O2PAGELINE,
          lt_XSLT_ATTRIBUTES type standard table of O2XSLTATTR,
          lw_XSLT_ATTRIBUTES type O2XSLTATTR,
          lt_XSLT_TEXTS type standard table of O2XSLTTEXT,
          lw_XSLT_TEXT type O2XSLTTEXT,
          lt_file_content type STANDARD TABLE OF string,
          lv_content_line type string,
          lv_focus type c length 20,
          lv_filename type string,
          lv_TRKORR type TRKORR.

    CALL FUNCTION 'XSLT_GET_OBJECT'
      EXPORTING
        XSLT_NAME       = transformation
*       STATE           = 'A'
      TABLES
        XSLT_SOURCE     = lt_XSLT_SOURCE
        XSLT_ATTRIBUTES = lt_XSLT_ATTRIBUTES
        XSLT_TEXTS      = lt_XSLT_TEXTS
      EXCEPTIONS
        OTHERS          = 4.
    if sy-subrc = 0.
      lcl_logging=>set_message( message = 'Transformation & is already on the system' par1 = transformation ).
      exit.
    endif.

    clear: lt_XSLT_SOURCE[], lt_XSLT_ATTRIBUTES[], lt_XSLT_TEXTS[].

    CONCATENATE gv_path '\' transformation '.strans.txt' INTO lv_filename.
    lcl_logging=>set_message( lv_filename ).
    CALL FUNCTION 'GUI_UPLOAD'
      EXPORTING
        filename = lv_filename
      TABLES
        data_tab = lt_file_content
      EXCEPTIONS
        OTHERS   = 4.
    if sy-subrc = 4.
      lcl_logging=>set_syst( ).
    endif.
    CHECK sy-subrc = 0.

    loop at lt_file_content into lv_content_line.
      if lv_content_line = '%_ATTRIBUTES' or lv_content_line = '%_TEXTS' or lv_content_line = '%_SOURCE'.
        lv_focus = lv_content_line.
        continue.
      endif.

      case lv_focus.
        when '%_ATTRIBUTES'.
          lw_XSLT_ATTRIBUTES = lv_content_line.
        when '%_TEXTS'.
          lw_XSLT_TEXT = lv_content_line.
          append lw_XSLT_TEXT to lt_XSLT_TEXTS.
        when '%_SOURCE'.
          lw_XSLT_SOURCE = lv_content_line.
          append lw_XSLT_SOURCE to lt_XSLT_SOURCE.
      endcase.
    endloop.

    lv_TRKORR = gv_transport.
* Now save the transformation
    CALL FUNCTION 'XSLT_MAINTENANCE'
      EXPORTING
        I_OPERATION         = 'CREA_ACT' "create and activate
        I_XSLT_ATTRIBUTES   = lw_XSLT_ATTRIBUTES
        I_XSLT_SOURCE       = lt_XSLT_SOURCE
        I_TRANSPORT_REQUEST = lv_TRKORR
      EXCEPTIONS
        others              = 4.
    if sy-subrc <> 0.
      lcl_logging=>set_syst( ).
    endif.

  ENDMETHOD.

  METHOD title_extract.
    data: lv_filename type string,
          lt_textpool type standard table of ty_textpool,
          lw_textpool type ty_textpool.

    title = 'No title'.
* The title of the report
    CONCATENATE source '.text.' sy-langu '.txt' INTO lv_filename.
    read table GT_FILE_TABLE into GW_FILE_INFO with key FILENAME = lv_filename.
    if sy-subrc <> 0.
* Fetch first available text
      CONCATENATE source '.text.+.txt' INTO lv_filename.
      loop at GT_FILE_TABLE into GW_FILE_INFO
        where filename cp lv_filename.
* First result will do
      endloop.
    endif.
    if sy-subrc = 0.
* Read PC version
      CONCATENATE gv_path '\' lv_filename INTO lv_filename.
      CALL FUNCTION 'GUI_UPLOAD'
        EXPORTING
          filename = lv_filename
        TABLES
          data_tab = lt_textpool
        EXCEPTIONS
          OTHERS   = 4.
      IF sy-subrc = 0.
        read table lt_textpool into lw_textpool with key id = 'R'.
        if sy-subrc = 0.
          title = lw_textpool-entry.
        endif.
      ENDIF.
    endif.

  ENDMETHOD.

  METHOD project_file.
    DATA: lv_filename TYPE string.

    CASE action.
      WHEN 'SAVE'.
* Create the file
        CONCATENATE gv_path '\' gv_project '.project.txt' INTO lv_filename.
        CALL FUNCTION 'GUI_DOWNLOAD'
          EXPORTING
            filename = lv_filename
          TABLES
            data_tab = gt_project_file
          EXCEPTIONS
            OTHERS   = 4.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE 'W' NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ELSE.
          MESSAGE 'Project file saved' TYPE 'S'.
        ENDIF.
      WHEN 'READ'.
* Read the file
        CLEAR: gt_project_file[].
        CONCATENATE gv_path '\' gv_project '.project.txt' INTO lv_filename.
        CALL FUNCTION 'GUI_UPLOAD'
          EXPORTING
            filename = lv_filename
          TABLES
            data_tab = gt_project_file
          EXCEPTIONS
            OTHERS   = 4.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE 'W' NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ELSE.
          MESSAGE 'Project file read' TYPE 'S'.
        ENDIF.
    ENDCASE.

  ENDMETHOD.                    "project_file

  METHOD delete_tmp_object.
    data:
      lv_devclass type tadir-devclass,
      lt_bdcdata type standard table of bdcdata,
      lw_bdcdata type bdcdata.
*      lt_bdcmsgcoll type standard table of bdcmsgcoll,
*      lw_bdcmsgcoll type bdcmsgcoll.

    define source_check.
      READ TABLE lt_dynpro_scr INDEX &1 into lw_dynpro_scr.
      IF lw_dynpro_scr <> &2.
        MESSAGE e250(37) RAISING not_executed.
      ENDIF.
    end-of-definition.
    define bdc_add.
      clear lw_bdcdata.
      lw_bdcdata-dynbegin = &1.
      if &1 = 'X'.
        lw_bdcdata-program = &2.
        lw_bdcdata-dynpro = &3.
      else.
        lw_bdcdata-fnam = &2.
        lw_bdcdata-fval = &3.
      endif.
      append lw_bdcdata to lt_bdcdata.
    end-of-definition.

    SELECT SINGLE devclass FROM tadir INTO lv_devclass
      WHERE pgmid = 'R3TR' AND
            object = 'PROG' AND
            obj_name = source.
    IF sy-subrc = 0 and lv_devclass = '$TMP'.
* Delete the object, through SE38 recording.
      clear: lt_bdcdata[].
      bdc_add: 'X' 'SAPLWBABAP' '0100',
               ' ' 'RS38M-PROGRAMM' source,
               ' ' 'BDC_OKCODE' '=DELP',
               'X' 'SAPLSEU2' '0201',
               ' ' 'BDC_OKCODE' '=BACK',
               'X' 'SAPLWBABAP' '0100',
               ' ' 'BDC_OKCODE' '=BACK'.
      call transaction 'SE38' using lt_bdcdata mode 'E'.
    endif.

  ENDMETHOD.

  METHOD is_production_system.
    DATA: lv_cccategory TYPE t000-cccategory.
* Get system category
    SELECT SINGLE cccategory FROM t000
      INTO lv_cccategory
      WHERE mandt = sy-mandt.
    IF sy-subrc = 0 AND lv_cccategory = 'P'.
      is_production = abap_true.
    ELSE.
      CLEAR is_production.
    ENDIF.
  ENDMETHOD.                    "is_production_system

ENDCLASS.                    "lcl_codemover IMPLEMENTATION

SELECTION-SCREEN: BEGIN OF LINE,
  COMMENT 1(16) lbl_l02 FOR FIELD pa_path,
  POSITION 20.
PARAMETERS: pa_path TYPE fileextern OBLIGATORY LOWER CASE.
SELECTION-SCREEN: END OF LINE.
SELECTION-SCREEN SKIP.
SELECTION-SCREEN: BEGIN OF LINE,
  COMMENT 1(15) lbl_l01 FOR FIELD pa_proj, POSITION 20.
PARAMETERS: pa_proj TYPE char50 VISIBLE LENGTH 19 LOWER CASE.
SELECTION-SCREEN:
  PUSHBUTTON 40(30) but_prea USER-COMMAND button_project_read VISIBLE LENGTH 6,
  PUSHBUTTON 47(30) but_psav USER-COMMAND button_project_save VISIBLE LENGTH 6,
END OF LINE.

SELECTION-SCREEN: BEGIN OF LINE,
  COMMENT 1(16) lbl_l03 FOR FIELD pa_packa,
  POSITION 20.
PARAMETERS: pa_packa TYPE tadir-devclass DEFAULT '$TMP' VISIBLE LENGTH 12,
            pa_korrn TYPE tadir-korrnum.
SELECTION-SCREEN: END OF LINE,
  BEGIN OF LINE,
  PUSHBUTTON 1(30) but_mark USER-COMMAND button_mark_all VISIBLE LENGTH 4,
  PUSHBUTTON 6(30) but_umrk USER-COMMAND button_unmark_all VISIBLE LENGTH 4,
  PUSHBUTTON 20(40) but_up USER-COMMAND button_upload VISIBLE LENGTH 14,
  PUSHBUTTON 35(40) but_down USER-COMMAND button_download VISIBLE LENGTH 14,
  END OF LINE,
  SKIP.
* Column headers for the main table:
SELECTION-SCREEN:
  BEGIN OF LINE,
  COMMENT 3(30) lbl_lh1,  "Abap source
  COMMENT 35(3) lbl_lh2,  "SAP
  COMMENT 42(15) lbl_lh3. "Additional

DEFINE parameter_line.
  selection-screen: end of line, begin of line.

  PARAMETERS:
    pa_sel&1 as checkbox DEFAULT abap_true,   "Selection of the line (for upload/downloads)
    pa_src&1 type sy-repid visible length 30. "Source code
  SELECTION-SCREEN:
    PUSHBUTTON 36(40) pa_sta&1 USER-COMMAND button_&1 VISIBLE LENGTH 2,
    POSITION 40.
  PARAMETERS:
    pa_cmp&1 type icon_d visible length 2 modif id ico. "Comparison status
  SELECTION-SCREEN:
    PUSHBUTTON 44(40) pa_lcl&1 USER-COMMAND button_&1x VISIBLE LENGTH 2,
    POSITION 47.
  parameters:
    pa_ttl&1 type sy-title modif id txt, "Report/include description
    pa_add&1 type string LOWER CASE VISIBLE LENGTH 15 modif id reo. "Additional info
END-OF-DEFINITION.

parameter_line:
  01, 02, 03, 04, 05, 06, 07, 08, 09, 10,
  11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
  21, 22, 23, 24, 25, 26, 27, 28, 29, 30.

SELECTION-SCREEN: END OF LINE.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_proj.
  DATA: lv_complete_filename TYPE string,
        lt_dynpvaluetab TYPE STANDARD TABLE OF dynpread,
        lw_dynpread TYPE dynpread,
        lv_path TYPE string.

  lv_path = pa_path.
  if lv_complete_filename is initial.
    lv_complete_filename = '*.project.txt'.
  endif.
  cl_rsan_ut_files=>f4(
    EXPORTING i_applserv = space
              i_gui_extension = ''
              i_gui_ext_filter = '.txt'
              i_gui_initial_directory = lv_path
              i_title = 'Choose project file'
    CHANGING  c_file_name = lv_complete_filename ).

  if not lv_complete_filename is initial.
    CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
      EXPORTING
        full_name     = lv_complete_filename
      IMPORTING
        stripped_name = pa_proj
        file_path     = lv_complete_filename
      EXCEPTIONS
        OTHERS        = 0.
    REPLACE '.project.txt' IN pa_proj WITH ''.

    CLEAR: lt_dynpvaluetab[], lw_dynpread.
    lw_dynpread-fieldname = 'PA_PATH'.
    lw_dynpread-fieldvalue = lv_complete_filename.
    APPEND lw_dynpread TO lt_dynpvaluetab.
    CALL FUNCTION 'DYNP_VALUES_UPDATE'
      EXPORTING
        dyname     = sy-repid
        dynumb     = sy-dynnr
      TABLES
        dynpfields = lt_dynpvaluetab
      EXCEPTIONS
        OTHERS     = 0.
  endif.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_path.
  CALL FUNCTION 'TMP_GUI_BROWSE_FOR_FOLDER'
    EXPORTING
      window_title    = 'Choose the path to UPLOAD from or DOWNLOAD to'
    IMPORTING
      selected_folder = pa_path.

  DEFINE f4_line.

at selection-screen on value-request for pa_src&1.
  data: lw_info_object type euobj-id.
  lw_info_object = 'PROG'.
  call function 'REPOSITORY_INFO_SYSTEM_F4'
    exporting
      object_type          = lw_info_object
      object_name          = pa_src&1
      suppress_selection   = 'X'
    importing
      object_name_selected = pa_src&1
    exceptions
      cancel               = 0.
END-OF-DEFINITION.

f4_line:
  01, 02, 03, 04, 05, 06, 07, 08, 09, 10,
  11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
  21, 22, 23, 24, 25, 26, 27, 28, 29, 30.

AT SELECTION-SCREEN OUTPUT.

  LOOP AT SCREEN.
    IF screen-group1 = 'ICO'.
      screen-input = '0'.
      MODIFY SCREEN.
    ENDIF.
    IF screen-group1 = 'REO'.
      screen-input = '0'.
      screen-DISPLAY_3D = '0'.
      screen-INTENSIFIED = '1'.
      MODIFY SCREEN.
    ENDIF.
    IF screen-group1 = 'TXT'.
      screen-input = '0'.
      screen-DISPLAY_3D = '0'.
      MODIFY SCREEN.
    ENDIF.
    IF screen-group1 = 'XXX'.
      screen-input = '0'.
      screen-active = '0'.
      MODIFY SCREEN.
    ENDIF.
    IF screen-group1 = 'INF'.
      screen-input = '0'.
      screen-output = '1'.
      screen-display_3d = '0'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name   = icon_read_file
      text   = ''
      info   = 'Read project file'
    IMPORTING
      RESULT = but_prea
    EXCEPTIONS
      OTHERS = 0.

  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name   = icon_write_file
      text   = ''
      info   = 'Save project file'
    IMPORTING
      RESULT = but_psav
    EXCEPTIONS
      OTHERS = 0.

  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name   = icon_select_all
      text   = ''
      info   = 'Set all marks'
    IMPORTING
      RESULT = but_mark
    EXCEPTIONS
      OTHERS = 0.

  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name   = icon_deselect_all
      text   = ''
      info   = 'Clear all marks'
    IMPORTING
      RESULT = but_umrk
    EXCEPTIONS
      OTHERS = 0.

  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name   = ICON_WD_INBOUND_PLUG
      text   = 'Upload'
      info   = 'Import local files into SAP'
    IMPORTING
      RESULT = but_up
    EXCEPTIONS
      OTHERS = 0.

  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name   = ICON_WD_OUTBOUND_PLUG
      text   = 'Downld'
      info   = 'Move objects to local files'
    IMPORTING
      RESULT = but_down
    EXCEPTIONS
      OTHERS = 0.

  if not pa_path is initial.
* Get a directory listing for the front-end files, to be able to
* determine the last changed date/time:
    lcl_codemover=>compose_dirlisting( pa_path ).
  endif.

  DEFINE set_controls.

    lcl_codemover=>analyze_source( pa_src&1 ). "Fill in gw_report_status

    if lcl_codemover=>gw_report_status-icon_sap = lcl_codemover=>co_ok or
      lcl_codemover=>gw_report_status-icon_sap = lcl_codemover=>co_ok_latest.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name   = lcl_codemover=>gw_report_status-icon_sap
          info   = lcl_codemover=>gw_report_status-datetime_SAP_text
        IMPORTING
          RESULT = pa_sta&1
        EXCEPTIONS
          OTHERS = 0.
    else.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name   = lcl_codemover=>gw_report_status-icon_sap
          info   = lcl_codemover=>gw_report_status-icon_info
        IMPORTING
          RESULT = pa_sta&1
        EXCEPTIONS
          OTHERS = 0.
    endif.

    pa_cmp&1 = lcl_codemover=>gw_report_status-icon_compare.
    if pa_cmp&1 is initial.
      pa_cmp&1 = '@5F@'.
    endif.

    if lcl_codemover=>gw_report_status-icon_front = lcl_codemover=>co_ok or
      lcl_codemover=>gw_report_status-icon_front = lcl_codemover=>co_ok_latest.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name   = lcl_codemover=>gw_report_status-icon_front
          info   = lcl_codemover=>gw_report_status-datetime_front_text
        IMPORTING
          RESULT = pa_lcl&1
        EXCEPTIONS
          OTHERS = 0.
    else.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name   = lcl_codemover=>gw_report_status-icon_front
          info   = lcl_codemover=>gw_report_status-icon_info
        IMPORTING
          RESULT = pa_lcl&1
        EXCEPTIONS
          OTHERS = 0.
    endif.

    pa_ttl&1 = lcl_codemover=>gw_report_status-title.
    pa_add&1 = lcl_codemover=>gw_report_status-additional.
  END-OF-DEFINITION.

* Check all field-sets
  lcl_codemover=>gv_path = pa_path.
  lcl_codemover=>gv_package = pa_packa.
  lcl_codemover=>gv_transport = pa_korrn.

  if lcl_codemover=>gv_skip_controls = abap_true.
    lcl_codemover=>gv_skip_controls = abap_false.
  else.
    set_controls:
      01, 02, 03, 04, 05, 06, 07, 08, 09, 10,
      11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
      21, 22, 23, 24, 25, 26, 27, 28, 29, 30.
  endif.

  IF lcl_codemover=>is_production_system( ) = abap_true.
    LOOP AT SCREEN.
      screen-input = 0.
      MODIFY SCREEN.
    ENDLOOP.
    MESSAGE 'Code mover is NOT for production systems' TYPE 'S'.
  ENDIF.

AT SELECTION-SCREEN.

  DEFINE get_project_line.
    if not pa_src&1 is initial.
      append pa_src&1 to lcl_codemover=>gt_project_file.
    endif.
  END-OF-DEFINITION.
  DEFINE set_project_line.
    read table lcl_codemover=>gt_project_file into lcl_codemover=>gv_string index &1.
    if sy-subrc = 0.
      pa_src&1 = lcl_codemover=>gv_string.
    else.
      clear pa_src&1.
    endif.
  END-OF-DEFINITION.
  DEFINE button_mark_all.
    pa_sel&1 = abap_true.
  END-OF-DEFINITION.
  DEFINE button_unmark_all.
    pa_sel&1 = abap_false.
  END-OF-DEFINITION.
  DEFINE button_upload.
    if not pa_sel&1 is initial and not pa_src&1 is initial.
      lcl_codemover=>coding_upload( pa_src&1 ).
    endif.
  END-OF-DEFINITION.
  DEFINE button_download.
    if not pa_sel&1 is initial and not pa_src&1 is initial.
      lcl_codemover=>coding_download( pa_src&1 ).
    endif.
  END-OF-DEFINITION.
  DEFINE delete_tmp_object.
    if not pa_sel&1 is initial and not pa_src&1 is initial.
      lcl_codemover=>delete_tmp_object( pa_src&1 ).
    endif.
  END-OF-DEFINITION.

  lcl_codemover=>gv_project = pa_proj.
  lcl_codemover=>gv_path = pa_path.
  CASE sy-ucomm.
    WHEN 'BUTTON_PROJECT_SAVE'.
      IF pa_proj IS INITIAL.
        MESSAGE 'Please specify a project name' TYPE 'S'.
      ELSE.
        CLEAR lcl_codemover=>gt_project_file[].
        get_project_line: 01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30.
        lcl_codemover=>project_file( 'SAVE' ).
      ENDIF.
    WHEN 'BUTTON_PROJECT_READ'.
      IF pa_proj IS INITIAL.
        MESSAGE 'Please specify a project name' TYPE 'S'.
      ELSE.
        lcl_codemover=>project_file( 'READ' ).
        IF NOT lcl_codemover=>gt_project_file[] IS INITIAL.
          set_project_line: 01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30.
        ENDIF.
      ENDIF.
    WHEN 'BUTTON_MARK_ALL'.
      button_mark_all:
        01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30.
      message 'All marked' type 'S'.
      lcl_codemover=>gv_skip_controls = abap_true.
    WHEN 'BUTTON_UNMARK_ALL'.
      button_unmark_all:
        01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30.
      message 'All cleared' type 'S'.
      lcl_codemover=>gv_skip_controls = abap_true.
    WHEN 'BUTTON_UPLOAD'.
      lcl_logging=>initialize( ).
      lcl_logging=>set_message( 'Upload selected sources' ).
      button_upload:
        01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30.
      lcl_logging=>set_message( 'End of upload' ).
      lcl_logging=>go_log->display( ).
    WHEN 'BUTTON_DOWNLOAD'.
      lcl_logging=>initialize( ).
      lcl_logging=>set_message( 'Download selected sources' ).
      button_download:
        01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30.
      lcl_logging=>set_message( 'End of download' ).
      lcl_logging=>go_log->display( ).
    WHEN 'DELETE'.
      delete_tmp_object:
        01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30.
  ENDCASE.

INITIALIZATION.
  lbl_l01 = 'Project'.
  lbl_l02 = 'Frontend path'.
  lbl_l03 = 'Package/request'.
  lbl_lh1 = 'Abap source (report/include)'.
  lbl_lh2 = 'SAP'.
  lbl_lh3 = 'Frontend'.

START-OF-SELECTION.

* Actions are performed from the selection screen - no factual START-OF-SELECTION is relevant
  MESSAGE 'This application only responds to the buttons on the selection screen' TYPE 'S'.
