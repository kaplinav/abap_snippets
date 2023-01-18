data(min) = 12345678.
data(max) = 99999999.

data(random_int) = cl_abap_random_int=>create(
  seed = conv i( sy-uzeit )
  min = min
  max = max ).
