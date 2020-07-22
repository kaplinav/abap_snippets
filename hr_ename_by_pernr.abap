method ename_by_pernr.

if im_pernr is initial.
  return.
endif.

data date type datum.
date = im_date.

if date is initial.
  date = sy-datum.
endif.

select single ename
from pa0001
into r_ename
where pernr eq im_pernr
and endda ge date
and begda le date.

endmethod.
