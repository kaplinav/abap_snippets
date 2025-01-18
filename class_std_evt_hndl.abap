
CLASS zcl_report_events DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    " Class introduction
    " This class provides static methods for handling standard events 
    " in an ABAP report. Each method represents a standard event and can 
    " be used to implement logic associated with these events. The events 
    " include INITIALIZATION, START-OF-SELECTION, END-OF-SELECTION, and more.

    " Static method for INITIALIZATION event
    CLASS-METHODS handle_initialization
      " Detailed comments:
      " This method corresponds to the INITIALIZATION event in an ABAP report.
      " It is called before the selection screen is displayed for the first time.
      IMPORTING iv_message TYPE string OPTIONAL.

    " Static method for AT SELECTION-SCREEN event
    CLASS-METHODS handle_at_selection_screen
      " Detailed comments:
      " This method corresponds to the AT SELECTION-SCREEN event in an ABAP report.
      " It is triggered after user input is validated on the selection screen.
      IMPORTING iv_message TYPE string OPTIONAL.

    " Static method for START-OF-SELECTION event
    CLASS-METHODS handle_start_of_selection
      " Detailed comments:
      " This method corresponds to the START-OF-SELECTION event in an ABAP report.
      " It is the main processing block and is triggered after the selection screen is processed.
      IMPORTING iv_message TYPE string OPTIONAL.

    " Static method for END-OF-SELECTION event
    CLASS-METHODS handle_end_of_selection
      " Detailed comments:
      " This method corresponds to the END-OF-SELECTION event in an ABAP report.
      " It is called after the main logic in START-OF-SELECTION is completed.
      IMPORTING iv_message TYPE string OPTIONAL.

    " Static method for TOP-OF-PAGE event
    CLASS-METHODS handle_top_of_page
      " Detailed comments:
      " This method corresponds to the TOP-OF-PAGE event in an ABAP report.
      " It is triggered when a new page starts in a report's output.
      IMPORTING iv_message TYPE string OPTIONAL.

ENDCLASS.

CLASS zcl_report_events IMPLEMENTATION.

  METHOD handle_initialization.
    " Log the INITIALIZATION event and any message passed
    WRITE: / 'INITIALIZATION Event Triggered'.
    IF iv_message IS NOT INITIAL.
      WRITE: / 'Message:', iv_message.
    ENDIF.
  ENDMETHOD.

  METHOD handle_at_selection_screen.
    " Log the AT SELECTION-SCREEN event and any message passed
    WRITE: / 'AT SELECTION-SCREEN Event Triggered'.
    IF iv_message IS NOT INITIAL.
      WRITE: / 'Message:', iv_message.
    ENDIF.
  ENDMETHOD.

  METHOD handle_start_of_selection.
    " Log the START-OF-SELECTION event and any message passed
    WRITE: / 'START-OF-SELECTION Event Triggered'.
    IF iv_message IS NOT INITIAL.
      WRITE: / 'Message:', iv_message.
    ENDIF.
  ENDMETHOD.

  METHOD handle_end_of_selection.
    " Log the END-OF-SELECTION event and any message passed
    WRITE: / 'END-OF-SELECTION Event Triggered'.
    IF iv_message IS NOT INITIAL.
      WRITE: / 'Message:', iv_message.
    ENDIF.
  ENDMETHOD.

  METHOD handle_top_of_page.
    " Log the TOP-OF-PAGE event and any message passed
    WRITE: / 'TOP-OF-PAGE Event Triggered'.
    IF iv_message IS NOT INITIAL.
      WRITE: / 'Message:', iv_message.
    ENDIF.
  ENDMETHOD.

ENDCLASS.


REPORT zexample_report.

START-OF-SELECTION.
  zcl_report_events=>handle_start_of_selection( iv_message = 'Processing data...' ).

END-OF-SELECTION.
  zcl_report_events=>handle_end_of_selection( iv_message = 'Processing completed.' ).
