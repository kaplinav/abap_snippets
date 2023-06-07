" Dialog box for the display and request of values, without check
call function 'POPUP_GET_VALUES'

" Dialog Box to Display a Message
call function 'POPUP_TO_INFORM'
  exporting
    titel = 'Message'
    txt1 = 'Text of'
    txt2 = 'message' .

call function 'POPUP_TO_CONFIRM' "Standard Dialog Popup
  EXPORTING
*  TITLEBAR = ' ' "Title of dialog box
*  USERDEFINED_F1_HELP = ' ' "User-Defined F1 Help
*  START_COLUMN = 25 "Column in which the POPUP begins
*  START_ROW = 6 "Line in which the POPUP begins
*  POPUP_TYPE =  "Icon type
*  IV_QUICKINFO_BUTTON_1 = ' ' "Quick Info on First Pushbutton
*  IV_QUICKINFO_BUTTON_2 = ' ' "Quick Info on Second Pushbutton
*  DIAGNOSE_OBJECT = ' ' "Diagnosis text (maintain via SE61)
   TEXT_QUESTION =  "Question text in dialog box
*  TEXT_BUTTON_1 = 'Ja'(001) "Text on the first pushbutton
*  ICON_BUTTON_1 = ' ' "Icon on first pushbutton
*  TEXT_BUTTON_2 = 'Nein'(002) "Text on the second pushbutton
*  ICON_BUTTON_2 = ' ' "Icon on second pushbutton
*  DEFAULT_BUTTON = '1' "Cursor position
*  DISPLAY_CANCEL_BUTTON = 'X' "Button for displaying cancel pushbutton
  IMPORTING
    ANSWER =  "Return values: '1', '2', 'A'
  TABLES
*  PARAMETER =  "Text transfer table for parameter in text
  EXCEPTIONS
    TEXT_NOT_FOUND = 1 . 
