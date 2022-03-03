data duration_1 type fahztd .
data duration_2 type fahztd .
data duration_sum type fahztd .

call function 'SD_ADD_DURATION'
  exporting
    i_dur1   = duration_1
    i_dur2   = duration_2
  importing
    e_dur    = duration_sum
  exceptions
    overflow = 1
    others   = 2 .
