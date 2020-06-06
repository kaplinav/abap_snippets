methods get_class_name
  importing
    im_object type ref to object
  returning value(r_name) type abap_classname .


" returns the class name for an object
method get_class_name .

constants prefix type char6 value `\CLASS=` .
constants regex type string value `(CLASS=).+`.

r_name = substring(
  val = match( val = cl_abap_classdescr=>get_class_name( im_object )
               regex = regex occ = 1 )
  off = strlen( prefix )
  ).

endmethod. " get_class_name .
