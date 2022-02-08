data tm1 type timestampl.
get time stamp field tm1.

data tm2 type timestampl.
get time stamp field tm2.

try .
  " get runtime of smth
  data(seconds) = cl_abap_tstmp=>subtract(
    exporting
      tstmp1 = tm1
      tstmp2 = tm2 ).
catch cx_parameter_invalid_range into data(e).
endtry.
