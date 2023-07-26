
" MAKT-MAKTX
" Returns Material Material description (MAKTX) by given Material Number (MATNR) from MAKT
form get_material_description 
using 
    p_matnr type matnr
changing 
    ch_maktx type maktx.

if p_matnr = space .
    return.
endif.   

select single maktx 
from makt
into ch_maktx 
where spras = 'R' 
and matnr = p_matnr.
      
endform. " get_Material_description .
