* Events in the object oriented ALV based on class CL_GUI_ALV_GRID
* There are a lot of events fired in the object oriented ALV based on class CL_GUI_ALV_GRID. You can receive them and use for your actions. It's sometimes difficult to realize, which action fires which events and what their order is.

* This template program can be helpful to follow the calls of events. It registers handler for all of them. It also activates some extra events for edit mode. The handler calls methods and stops in debugger, when the event is received. You've also a possibility to have a look on the passed parameters.
* This program also registers handlers for protected, inherited events of class CL_GUI_ALV_GRID_BASE. Registration is a bit tricky. To do this, the class of event receiver have to be child of the class CL_GUI_ALV_GRID_BASE. Some of this events seems to be very promising, for example TOOLBAR_BUTTON_CLICK, but unfortunately in my tests they were never raised. According to where-used-list they are only fired from CL_GUI_ALV_GRID_BASE->DISPATCH and this method is redefined in CL_GUI_ALV_GRID and in such case not used. Let me know if you find out how to bring ALV to fire this events.
* If you want to start the program in your system, besides copying the source code, you have to create screen, GUI status, etc. See the comment at the beginning of the program for the detailed instruction.

PROGRAM zkmalvev.

* 1. SE38: create executable program (type 1), use PROGRAM
*    instead of REPORT because it will have screen and modules
*
* 2. SE80: create screen 0100
*
* 3. Screen Painter: on the screen 0100 create 'Custom control'
*    CONT1_0100
*
* 4. SE80: for screen 0100 set the variable OK_CODE for the element OK
*
* 5. SE80: create calls to PBO and PAI in the flow logic of screen 0100:
*
*    PROCESS BEFORE OUTPUT.
*      MODULE pbo_0100.
*    PROCESS AFTER INPUT.
*      MODULE pai_0100.
*
* 6. SE80: create GUI Status STAT_0100, assign functions EXIT and SAVE
*    to standard icons, eventually create your own toolbar button

TYPE-POOLS:
  slis.

CLASS cl_event_receiver       DEFINITION DEFERRED.
CLASS cl_base_event_receiver  DEFINITION DEFERRED.

DATA:
  gt_usr                 TYPE TABLE OF usr02,
  gs_usr                 TYPE usr02.

DATA:
  go_grid                TYPE REF TO cl_gui_alv_grid,
  go_custom_container    TYPE REF TO cl_gui_custom_container,
  go_event_receiver      TYPE REF TO cl_event_receiver,
  go_base_event_receiver TYPE REF TO cl_base_event_receiver,
  ok_code                TYPE sy-ucomm,
  gt_fcat                TYPE lvc_t_fcat.

*----------------------------------------------------------------------*
*       CLASS cl_event_receiver DEFINITION
*----------------------------------------------------------------------*
CLASS cl_event_receiver DEFINITION.

  PUBLIC SECTION.

    METHODS handle_right_click                  " RIGHT_CLICK
      FOR EVENT right_click OF cl_gui_alv_grid.

    METHODS handle_left_click_design            " LEFT_CLICK_DESIGN
      FOR EVENT left_click_design OF cl_gui_alv_grid.

    METHODS handle_move_control                 " MOVE_CONTROL
      FOR EVENT move_control OF cl_gui_alv_grid.

    METHODS handle_size_control                 " SIZE_CONTROL
      FOR EVENT size_control OF cl_gui_alv_grid.

    METHODS handle_left_click_run               " LEFT_CLICK_RUN
      FOR EVENT left_click_run OF cl_gui_alv_grid.

    METHODS handle_onf1                                     " ONF1
      FOR EVENT onf1 OF cl_gui_alv_grid
        IMPORTING
          e_fieldname
          es_row_no
          er_event_data.

    METHODS handle_onf4                                     " ONF4
      FOR EVENT onf4 OF cl_gui_alv_grid
        IMPORTING
          e_fieldname
          e_fieldvalue
          es_row_no
          er_event_data
          et_bad_cells
          e_display.

    METHODS handle_data_changed                 " DATA_CHANGED
      FOR EVENT data_changed OF cl_gui_alv_grid
        IMPORTING
          er_data_changed
          e_onf4
          e_onf4_before
          e_onf4_after
          e_ucomm.

    METHODS handle_ondropgetflavor              " ONDROPGETFLAVOR
      FOR EVENT ondropgetflavor OF cl_gui_alv_grid
        IMPORTING
          e_row
          e_column
          es_row_no
          e_dragdropobj
          e_flavors.

    METHODS handle_ondrag                       " ONDRAG
      FOR EVENT ondrag OF cl_gui_alv_grid
        IMPORTING
          e_row
          e_column
          es_row_no
          e_dragdropobj.

    METHODS handle_ondrop                       " ONDROP
      FOR EVENT ondrop OF cl_gui_alv_grid
        IMPORTING
          e_row
          e_column
          es_row_no
          e_dragdropobj.

    METHODS handle_ondropcomplete               " ONDROPCOMPLETE
      FOR EVENT ondropcomplete OF cl_gui_alv_grid
        IMPORTING
          e_row
          e_column
          es_row_no
          e_dragdropobj.

    METHODS handle_subtotal_text                " SUBTOTAL_TEXT
      FOR EVENT subtotal_text OF cl_gui_alv_grid
        IMPORTING
          es_subtottxt_info
          ep_subtot_line
          e_event_data.

    METHODS handle_before_user_command          " BEFORE_USER_COMMAND
      FOR EVENT before_user_command OF cl_gui_alv_grid
        IMPORTING
          e_ucomm.

    METHODS handle_user_command                 " USER_COMMAND
      FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING
          e_ucomm.

    METHODS handle_after_user_command           " AFTER_USER_COMMAND
      FOR EVENT after_user_command OF cl_gui_alv_grid
        IMPORTING
          e_ucomm
          e_not_processed.

    METHODS handle_double_click                 " DOUBLE_CLICK
      FOR EVENT double_click OF cl_gui_alv_grid
        IMPORTING
          e_row
          e_column
          es_row_no.

    METHODS handle_delayed_callback             " DELAYED_CALLBACK
      FOR EVENT delayed_callback OF cl_gui_alv_grid.

    METHODS handle_delayed_changed_sel_cal " DELAYED_CHANGED_SEL_CALLBACK
      FOR EVENT delayed_changed_sel_callback OF cl_gui_alv_grid.

    METHODS handle_print_top_of_page            " PRINT_TOP_OF_PAGE
      FOR EVENT print_top_of_page OF cl_gui_alv_grid
        IMPORTING
          table_index.

    METHODS handle_print_top_of_list            " PRINT_TOP_OF_LIST
      FOR EVENT print_top_of_list OF cl_gui_alv_grid.

    METHODS handle_print_end_of_page            " PRINT_END_OF_PAGE
      FOR EVENT print_end_of_page OF cl_gui_alv_grid.

    METHODS handle_print_end_of_list            " PRINT_END_OF_LIST
      FOR EVENT print_end_of_list OF cl_gui_alv_grid.

    METHODS handle_top_of_page                  " TOP_OF_PAGE
      FOR EVENT top_of_page OF cl_gui_alv_grid
        IMPORTING
          e_dyndoc_id
          table_index.

    METHODS handle_context_menu_request         " CONTEXT_MENU_REQUEST
      FOR EVENT context_menu_request OF cl_gui_alv_grid
        IMPORTING
          e_object.

    METHODS handle_menu_button                  " MENU_BUTTON
      FOR EVENT menu_button OF cl_gui_alv_grid
        IMPORTING
          e_object
          e_ucomm.

    METHODS handle_toolbar                      " TOOLBAR
      FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING
          e_object
          e_interactive.

    METHODS handle_hotspot_click                " HOTSPOT_CLICK
      FOR EVENT hotspot_click OF cl_gui_alv_grid
        IMPORTING
          e_row_id
          e_column_id.

    METHODS handle_end_of_list                  " END_OF_LIST
      FOR EVENT end_of_list OF cl_gui_alv_grid
        IMPORTING
          e_dyndoc_id.

    METHODS handle_after_refresh                " AFTER_REFRESH
      FOR EVENT after_refresh OF cl_gui_alv_grid.

    METHODS handle_button_click                 " BUTTON_CLICK
      FOR EVENT button_click OF cl_gui_alv_grid
        IMPORTING
          es_col_id
          es_row_no.

    METHODS handle_data_changed_finished        " DATA_CHANGED_FINISHED
      FOR EVENT data_changed_finished OF cl_gui_alv_grid
        IMPORTING
          e_modified
          et_good_cells.

ENDCLASS.                    "cl_event_receiver DEFINITION

*----------------------------------------------------------------------*
*       CLASS cl_event_receiver IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS cl_event_receiver IMPLEMENTATION.

  METHOD handle_right_click.
    BREAK-POINT.
  ENDMETHOD.                    "handle_right_click

  METHOD handle_left_click_design.
    BREAK-POINT.
  ENDMETHOD.                    "handle_left_click_design

  METHOD handle_move_control.
    BREAK-POINT.
  ENDMETHOD.                    "handle_move_control

  METHOD handle_size_control.
    BREAK-POINT.
  ENDMETHOD.                    "handle_size_control

  METHOD handle_left_click_run.
    BREAK-POINT.
  ENDMETHOD.                    "handle_left_click_run

  METHOD handle_onf1.
    BREAK-POINT.
  ENDMETHOD.                    "handle_onf1

  METHOD handle_onf4.
    BREAK-POINT.
  ENDMETHOD.                    "handle_onf4

  METHOD handle_data_changed.
    BREAK-POINT.
  ENDMETHOD.                    "handle_data_changed

  METHOD handle_ondropgetflavor.
    BREAK-POINT.
  ENDMETHOD.                    "handle_ondropgetflavor

  METHOD handle_ondrag.
    BREAK-POINT.
  ENDMETHOD.                    "handle_ondrag

  METHOD handle_ondrop.
    BREAK-POINT.
  ENDMETHOD.                    "handle_ondrop

  METHOD handle_ondropcomplete.
    BREAK-POINT.
  ENDMETHOD.                    "handle_ondropcomplete

  METHOD handle_subtotal_text.
    BREAK-POINT.
  ENDMETHOD.                    "handle_subtotal_text

  METHOD handle_before_user_command.
    BREAK-POINT.
  ENDMETHOD.                    "handle_before_user_command

  METHOD handle_user_command.
    BREAK-POINT.
  ENDMETHOD.                    "handle_user_command

  METHOD handle_after_user_command.
    BREAK-POINT.
  ENDMETHOD.                    "handle_after_user_command

  METHOD handle_double_click.
    BREAK-POINT.
  ENDMETHOD.                    "handle_double_click

  METHOD handle_delayed_callback.
    BREAK-POINT.
  ENDMETHOD.                    "handle_delayed_callback

  METHOD handle_delayed_changed_sel_cal.
    BREAK-POINT.
  ENDMETHOD.                    "handle_delayed_changed_sel_cal

  METHOD handle_print_top_of_page.
    BREAK-POINT.
  ENDMETHOD.                    "handle_print_top_of_page

  METHOD handle_print_top_of_list.
    BREAK-POINT.
  ENDMETHOD.                    "handle_print_top_of_list

  METHOD handle_print_end_of_page.
    BREAK-POINT.
  ENDMETHOD.                    "handle_print_end_of_page

  METHOD handle_print_end_of_list.
    BREAK-POINT.
  ENDMETHOD.                    "handle_print_end_of_list

  METHOD handle_top_of_page.
    BREAK-POINT.
  ENDMETHOD.                    "handle_top_of_page

  METHOD handle_context_menu_request.
    BREAK-POINT.
  ENDMETHOD.                    "handle_context_menu_request

  METHOD handle_menu_button.
    BREAK-POINT.
  ENDMETHOD.                    "handle_menu_button

  METHOD handle_toolbar.
    BREAK-POINT.
  ENDMETHOD.                    "handle_toolbar

  METHOD handle_hotspot_click.
    BREAK-POINT.
  ENDMETHOD.                    "handle_hotspot_click

  METHOD handle_end_of_list.
    BREAK-POINT.
  ENDMETHOD.                    "handle_end_of_list

  METHOD handle_after_refresh.
    BREAK-POINT.
  ENDMETHOD.                    "handle_after_refresh

  METHOD handle_button_click.
    BREAK-POINT.
  ENDMETHOD.                    "handle_button_click

  METHOD handle_data_changed_finished.
    BREAK-POINT.
  ENDMETHOD.                    "handle_data_changed_finished

ENDCLASS.                    "cl_event_receiver IMPLEMENTATION

*----------------------------------------------------------------------*
*       CLASS cl_base_event_receiver DEFINITION
*----------------------------------------------------------------------*
CLASS cl_base_event_receiver DEFINITION INHERITING FROM cl_gui_alv_grid_base.

  PUBLIC SECTION.

    METHODS set_protected_handlers.

  PROTECTED SECTION.

    METHODS handle_toolbar_menubutton_clk     " TOOLBAR_MENUBUTTON_CLICK
      FOR EVENT toolbar_menubutton_click OF cl_gui_alv_grid_base.

    METHODS handle_click_col_header             " CLICK_COL_HEADER
      FOR EVENT click_col_header OF cl_gui_alv_grid_base
        IMPORTING
          col_id.

    METHODS handle_delayed_move_curr_cell    " DELAYED_MOVE_CURRENT_CELL
      FOR EVENT delayed_move_current_cell OF cl_gui_alv_grid_base.

    METHODS handle_f1                           " F1
      FOR EVENT f1 OF cl_gui_alv_grid_base.

    METHODS handle_dblclick_row_col             " DBLCLICK_ROW_COL
      FOR EVENT dblclick_row_col OF cl_gui_alv_grid_base
        IMPORTING
          row_id
          col_id.

    METHODS handle_click_row_col                " CLICK_ROW_COL
      FOR EVENT click_row_col OF cl_gui_alv_grid_base
        IMPORTING
          row_id
          col_id.

    METHODS handle_toolbar_button_click         " TOOLBAR_BUTTON_CLICK
      FOR EVENT toolbar_button_click OF cl_gui_alv_grid_base.

    METHODS handle_double_click_col_sep   " DOUBLE_CLICK_COL_SEPARATOR
      FOR EVENT double_click_col_separator OF cl_gui_alv_grid_base
        IMPORTING
          col_id.

    METHODS handle_delayed_change_select     " DELAYED_CHANGE_SELECTION
      FOR EVENT delayed_change_selection OF cl_gui_alv_grid_base.

    METHODS handle_context_menu                 " CONTEXT_MENU
      FOR EVENT context_menu OF cl_gui_alv_grid_base.

    METHODS handle_total_click_row_col          " TOTAL_CLICK_ROW_COL
      FOR EVENT total_click_row_col OF cl_gui_alv_grid_base
        IMPORTING
          row_id
          col_id.

    METHODS handle_context_menu_selected        " CONTEXT_MENU_SELECTED
      FOR EVENT context_menu_selected  OF cl_gui_alv_grid_base
        IMPORTING
          fcode.

    METHODS handle_toolbar_menu_selected        " TOOLBAR_MENU_SELECTED
      FOR EVENT toolbar_menu_selected OF cl_gui_alv_grid_base
        IMPORTING
          fcode.

ENDCLASS.                    "cl_base_event_receiver DEFINITION

*----------------------------------------------------------------------*
*       CLASS cl_base_event_receiver IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS cl_base_event_receiver IMPLEMENTATION.

  METHOD set_protected_handlers.
    SET HANDLER me->handle_toolbar_menubutton_clk     FOR go_grid.
    SET HANDLER me->handle_click_col_header           FOR go_grid.
    SET HANDLER me->handle_delayed_move_curr_cell     FOR go_grid.
    SET HANDLER me->handle_f1                         FOR go_grid.
    SET HANDLER me->handle_dblclick_row_col           FOR go_grid.
    SET HANDLER me->handle_click_row_col              FOR go_grid.
    SET HANDLER me->handle_toolbar_button_click       FOR go_grid.
    SET HANDLER me->handle_double_click_col_sep       FOR go_grid.
    SET HANDLER me->handle_delayed_change_select      FOR go_grid.
    SET HANDLER me->handle_context_menu               FOR go_grid.
    SET HANDLER me->handle_total_click_row_col        FOR go_grid.
    SET HANDLER me->handle_context_menu_selected      FOR go_grid.
    SET HANDLER me->handle_toolbar_menu_selected      FOR go_grid.
  ENDMETHOD.                    "set_protected_handlers

  METHOD handle_toolbar_menubutton_clk.
    BREAK-POINT.
  ENDMETHOD.                    "handle_toolbar_menubutton_clk

  METHOD handle_click_col_header.
    BREAK-POINT.
  ENDMETHOD.                    "handle_click_col_header

  METHOD handle_delayed_move_curr_cell.
    BREAK-POINT.
  ENDMETHOD.                    "handle_delayed_move_curr_cell

  METHOD handle_f1.
    BREAK-POINT.
  ENDMETHOD.                                                "handle_f1

  METHOD handle_dblclick_row_col.
    BREAK-POINT.
  ENDMETHOD.                    "handle_dblclick_row_col

  METHOD handle_click_row_col.
    BREAK-POINT.
  ENDMETHOD.                    "handle_click_row_col

  METHOD handle_toolbar_button_click.
    BREAK-POINT.
  ENDMETHOD.                    "handle_toolbar_button_click

  METHOD handle_double_click_col_sep.
    BREAK-POINT.
  ENDMETHOD.                    "handle_double_click_col_sep

  METHOD handle_delayed_change_select.
    BREAK-POINT.
  ENDMETHOD.                    "handle_delayed_change_select

  METHOD handle_context_menu.
    BREAK-POINT.
  ENDMETHOD.                    "handle_context_menu

  METHOD handle_total_click_row_col.
    BREAK-POINT.
  ENDMETHOD.                    "handle_total_click_row_col

  METHOD handle_context_menu_selected.
    BREAK-POINT.
  ENDMETHOD.                    "handle_context_menu_selected

  METHOD handle_toolbar_menu_selected.
    BREAK-POINT.
  ENDMETHOD.                    "handle_toolbar_menu_selected

ENDCLASS.                    "cl_base_event_receiver IMPLEMENTATION

*&---------------------------------------------------------------------*
*&      START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.

* read sample data to internal table
  SELECT * FROM usr02 UP TO 30 ROWS
    APPENDING CORRESPONDING FIELDS OF TABLE gt_usr
    ORDER BY bname.

* create field catalog
  PERFORM create_fieldcat.

* display screen
  CALL SCREEN 0100.

*&---------------------------------------------------------------------*
*&      Form  create_fieldcat
*&---------------------------------------------------------------------*
FORM create_fieldcat.

  DATA:
    ls_fcat TYPE lvc_s_fcat.

* create field catalog
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'USR02'
    CHANGING
      ct_fieldcat      = gt_fcat.

* hotspot fields
  ls_fcat-hotspot = 'X'.
  MODIFY gt_fcat FROM ls_fcat
    TRANSPORTING hotspot
    WHERE fieldname = 'BNAME'.

* editable column
  ls_fcat-edit = 'X'.
  MODIFY gt_fcat FROM ls_fcat
    TRANSPORTING edit
    WHERE
         fieldname = 'GLTGV'.

* F4 list
  ls_fcat-f4availabl = 'X'.
  MODIFY gt_fcat FROM ls_fcat
    TRANSPORTING f4availabl
    WHERE
         fieldname = 'UFLAG'
      OR fieldname = 'ANAME'.

* dropdown list
  ls_fcat-drdn_hndl = '1'.
  MODIFY gt_fcat FROM ls_fcat
    TRANSPORTING drdn_hndl
    WHERE
         fieldname = 'CLASS'
      OR fieldname = 'LOCNT'.
ENDFORM.                    "create_fieldcat

*&---------------------------------------------------------------------*
*&      Form  field_f4_register
*&---------------------------------------------------------------------*
FORM field_f4_register.

  DATA:
    lt_f4 TYPE lvc_t_f4,
    ls_f4 TYPE lvc_s_f4.

  ls_f4-fieldname  = 'UFLAG'.
  ls_f4-register   = 'X'.
* ls_f4-getbefore  = 'X'.
* ls_f4-chngeafter = 'X'.
  INSERT ls_f4 INTO TABLE lt_f4.

  ls_f4-fieldname  = 'ANAME'.
  ls_f4-register   = 'X'.
* ls_f4-getbefore  = 'X'.
* ls_f4-chngeafter = 'X'.
  INSERT ls_f4 INTO TABLE lt_f4.

  CALL METHOD go_grid->register_f4_for_fields
    EXPORTING
      it_f4 = lt_f4.
ENDFORM.                    "field_f4_register

*----------------------------------------------------------------------*
*  MODULE pbo_0100 OUTPUT
*----------------------------------------------------------------------*
MODULE pbo_0100 OUTPUT.

* set GUI status
  SET PF-STATUS 'STAT_0100'.

  IF go_custom_container IS INITIAL.

    CREATE OBJECT go_custom_container
      EXPORTING
        container_name = 'CONT1_0100'.

    CREATE OBJECT go_grid
      EXPORTING
        i_appl_events = 'X'
        i_parent      = go_custom_container.

*   create handler
    CREATE OBJECT go_event_receiver.

*   register handler for events
    SET HANDLER go_event_receiver->handle_right_click                FOR go_grid.
    SET HANDLER go_event_receiver->handle_left_click_design          FOR go_grid.
    SET HANDLER go_event_receiver->handle_move_control               FOR go_grid.
    SET HANDLER go_event_receiver->handle_size_control               FOR go_grid.
    SET HANDLER go_event_receiver->handle_left_click_run             FOR go_grid.
    SET HANDLER go_event_receiver->handle_onf1                       FOR go_grid.
    SET HANDLER go_event_receiver->handle_onf4                       FOR go_grid.
    SET HANDLER go_event_receiver->handle_data_changed               FOR go_grid.
    SET HANDLER go_event_receiver->handle_ondropgetflavor            FOR go_grid.
    SET HANDLER go_event_receiver->handle_ondrag                     FOR go_grid.
    SET HANDLER go_event_receiver->handle_ondrop                     FOR go_grid.
    SET HANDLER go_event_receiver->handle_ondropcomplete             FOR go_grid.
    SET HANDLER go_event_receiver->handle_subtotal_text              FOR go_grid.
    SET HANDLER go_event_receiver->handle_before_user_command        FOR go_grid.
    SET HANDLER go_event_receiver->handle_user_command               FOR go_grid.
    SET HANDLER go_event_receiver->handle_after_user_command         FOR go_grid.
    SET HANDLER go_event_receiver->handle_double_click               FOR go_grid.
    SET HANDLER go_event_receiver->handle_delayed_callback           FOR go_grid.
    SET HANDLER go_event_receiver->handle_delayed_changed_sel_cal    FOR go_grid.
    SET HANDLER go_event_receiver->handle_print_top_of_page          FOR go_grid.
    SET HANDLER go_event_receiver->handle_print_top_of_list          FOR go_grid.
    SET HANDLER go_event_receiver->handle_print_end_of_page          FOR go_grid.
    SET HANDLER go_event_receiver->handle_print_end_of_list          FOR go_grid.
    SET HANDLER go_event_receiver->handle_top_of_page                FOR go_grid.
    SET HANDLER go_event_receiver->handle_context_menu_request       FOR go_grid.
    SET HANDLER go_event_receiver->handle_menu_button                FOR go_grid.
    SET HANDLER go_event_receiver->handle_toolbar                    FOR go_grid.
    SET HANDLER go_event_receiver->handle_hotspot_click              FOR go_grid.
    SET HANDLER go_event_receiver->handle_end_of_list                FOR go_grid.
    SET HANDLER go_event_receiver->handle_after_refresh              FOR go_grid.
    SET HANDLER go_event_receiver->handle_button_click               FOR go_grid.
    SET HANDLER go_event_receiver->handle_data_changed_finished      FOR go_grid.

*   create handler for protected events
    CREATE OBJECT go_base_event_receiver.

*   register handler for protected events
    CALL METHOD go_base_event_receiver->set_protected_handlers.

*   register F4 fields
    PERFORM field_f4_register.

*   register extra events for edit mode
*   - events DATA_CHANGED and DATA_CHANGED_FINISHED are called, when:

*   ENTER key is pressed or
    CALL METHOD go_grid->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_enter.

*   data is changed and cursor is moved from the cell
    CALL METHOD go_grid->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified.

*   display table
    CALL METHOD go_grid->set_table_for_first_display
      CHANGING
        it_fieldcatalog = gt_fcat
        it_outtab       = gt_usr.
  ENDIF.
ENDMODULE.                    "pbo_0100 OUTPUT

*----------------------------------------------------------------------*
*  MODULE pai_0100 INPUT
*----------------------------------------------------------------------*
MODULE pai_0100 INPUT.

  BREAK-POINT.

* to react on custom events:
  CALL METHOD cl_gui_cfw=>dispatch.

  BREAK-POINT.

  CASE ok_code.

    WHEN 'EXIT'.
      LEAVE PROGRAM.

    WHEN 'SAVE'.
*     force ALV to copy the data from grid to the internal table
*     (events DATA_CHANGED and DATA_CHANGED_FINISHED will be fired)
      CALL METHOD go_grid->check_changed_data.
  ENDCASE.

  CLEAR ok_code.
ENDMODULE.                    "pai_0100 INPUT
