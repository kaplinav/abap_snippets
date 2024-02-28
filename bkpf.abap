
types:
    begin of bkpf_key_t,
      bukrs type bukrs,
      belnr type belnr_d,
      gjahr type gjahr,
    end of bkpf_key_t.

    types bkpf_key_tab_t type standard table of bkpf_key_t with empty key.
