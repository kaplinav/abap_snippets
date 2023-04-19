""" Reading the BDC Message Result
" https://belajarabap.wordpress.com/2011/09/13/reading-the-bdc-message-result/

" Usually after running BDC in the program, a message will appear on the results of the transaction execution. 
" The data thrown in the message table is just an ID, TYPE, NUMBER, etc. which is difficult to understand. 
" This is different from BAPI Return which has sent its message in full which can be understood by the user.

" To read the contents of the message throw from the BDC, you can actually use TCODE SE91, 
" which is a transaction to read messages by inputting the message ID and NUMBER. but this is very, very inefficient. 
" so it would be nice if you do some coding to read the message from the BDC throw in the program.

" There are several ways to make the message that appears easily understood by the user, 
" namely by using the FORMAT_MESSAGE function, or by selecting data to table T10o.

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

