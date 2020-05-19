class myclass definition.
public section.
class-methods build
  changing
    ch_source type data
  returning value(r_fcat) type lvc_t_fcat.

endclass. " myclass

class myclass implementation.
method build.

field-symbols <tab> type standard table.
get reference of ch_source into data(ref_tab).
assign ref_tab->* to <tab>.

data o_salv_table type ref to cl_salv_table.
try .

cl_salv_table=>factory(
  importing
    r_salv_table = o_salv_table
  changing
    t_table = <tab> ) .

catch cx_dynamic_check into data(e).
  "TO DO
  return.
endtry.

data o_columns_table type ref to cl_salv_columns_table.
o_columns_table = o_salv_table->get_columns( ) .
data o_aggregations type ref to cl_salv_aggregations.
r_fcat = cl_salv_controller_metadata=>get_lvc_fieldcatalog(
  r_columns = o_columns_table
  r_aggregations = o_aggregations ) .

endmethod. " build
endclass. " myclass
