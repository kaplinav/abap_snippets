" Reading the BDC Message Result

"" Function FORMAT_MESSAGE.

data: wa_messtab like bdcmsgcoll.
data: d_msg(255).

call function 'FORMAT_MESSAGE'
  exporting
    id        = wa_bdcmsg-msgid
    lang      = 'EN'
    no        = wa_bdcmsg-msgnr
    v1        = wa_bdcmsg-msgv1
    v2        = wa_bdcmsg-msgv2
    v3        = wa_bdcmsg-msgv3
    v4        = wa_bdcmsg-msgv4
  importing
    msg       = d_msg
        
        
"" Select data from table T100.

data: d_msg type natxt.
data: wa_messtab like bdcmsgcoll.

select single text 
from t100
into d_msg
where sprsl = wa_messtab-MSGSPRA
and arbgb = wa_messtab-MSGID
and msgnr = wa_messtab-MSGNR.

replace '&1' in d_msg with wa_messtab-msgv1.
replace '&2' in d_msg with wa_messtab-msgv2.
replace '&3' in d_msg with wa_messtab-msgv3.
replace '&4' in d_msg with wa_messtab-msgv4.

