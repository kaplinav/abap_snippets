selection-screen begin of block b01 with frame.
  parameters mon_year type spmon default sy-datum(6) obligatory .
selection-screen end of block b01.

at selection-screen on value-request for mon_year.
sel_screen=>on_mon_year_f4( ).

method on_mon_year_f4.

data returncode type syst_subrc.

call function 'POPUP_TO_SELECT_MONTH'
  exporting
    actual_month = sy-datum(6)
  importing
    selected_month = mon_year
    return_code = returncode
  exceptions
    factory_calendar_not_found = 01
    holiday_calendar_not_found = 02
    month_not_found            = 03.

endmethod. " on_mon_year_f4.
