
class-methods GET_ACT_WERKS
    importing
      !PERNR type PERSNO
    returning
      value(R) type PERSA .

method GET_ACT_WERKS.

if pernr is initial.
  return.
endif.

select single werks
from pa0001
into r
where pernr = pernr
and endda >= sy-datum
and begda <= sy-datum .

endmethod.
