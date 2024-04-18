
class dummy definition.
  public section.
    constants file_name_c type string value 'some_file_name'.
    " Returns the file name
    methods get_fname
      returning
        value(r) type string.
endclass. " dummy

class dummy implementation.
method get_fname.

r = |{ file_name_c }_{ sy-datum date = raw }_{ sy-uzeit time = raw }|.

endmethod. " get_fname
endclass. " dummy
