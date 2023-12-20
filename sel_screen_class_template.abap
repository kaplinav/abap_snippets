class sel_screen definition.
  public section.
    " interfaces
    " interfaces isel_screen.
    " aliases
    " types
    types:
    begin of user_input_t,
      ... type ...,
    end of user_input_t.
    " constants
    " data definition
    data ... type ... .
    " methods
    class-methods class_constructor.

    class-methods get_user_input
      returning
        value(r) type user_input_t.

    class-methods pai.
    class-methods pbo.

  private section.
    " interfaces
    " types
    " constants
    " data definition
    " methods
    class-methods process_screen.

endclass. " sel_screen

*--------------------------------------------------------------------*
selection-screen begin of block b01 with frame.
  parameters p_... type ... .
selection-screen end of block b01.
*--------------------------------------------------------------------*


class sel_screen implementation.
method class_constructor.
endmethod. " class_constructor.

method get_user_input.

r-... = ....

endmethod. " get_user_input

method pai.
endmethod. " pai.

method pbo.
endmethod. " pbo.

" loop at screen
method process_screen.
endmethod. " process_screen
endclass. " sel_screen
