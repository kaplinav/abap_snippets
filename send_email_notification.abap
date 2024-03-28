 METHOD send_approver_notification.
    DATA: lo_bcs       TYPE REF TO cl_bcs,
          lo_sender    TYPE REF TO cl_cam_address_bcs,
          lo_recepient TYPE REF TO cl_cam_address_bcs,
          lv_subject   TYPE so_obj_des,
          lo_document  TYPE REF TO cl_document_bcs,
          lv_cfcno     LIKE cfcno,
          lv_level     TYPE string,
          lit_text     TYPE bcsy_text.

    lv_cfcno = get_cfc_display( ).
    lv_level = im_approver-aprv_level.

    "Remove Leading 0
    SHIFT lv_level LEFT DELETING LEADING '0'.

    "Build Subject
    CONCATENATE TEXT-001 lv_cfcno TEXT-002 lv_level
      INTO lv_subject SEPARATED BY space.

    "Build Email Body
    APPEND '<h2>Test Email Notification</h2> <br> <br>' TO lit_text.
    APPEND '<p>Use this <a href="www.google.com">link</a> </p>' TO lit_text.

    "Try Send Email
    TRY.
        "BCS Object
        lo_bcs = cl_bcs=>create_persistent( ).

        "Get Sender's Name and Email
        DATA(ls_sender_details) = get_user_details( im_sender ).

        lo_sender = cl_cam_address_bcs=>create_internet_address(
          EXPORTING
            i_address_name =   CONV adr6-smtp_addr( ls_sender_details-full_name )
            i_address_string = CONV adr6-smtp_addr( ls_sender_details-email )
        ).

        "Pass Sender
        lo_bcs->set_sender( lo_sender ).

        DATA(ls_approver_details) = get_user_details( im_approver-approver ).

        "Check First if Email is Internal Only in DEV
        IF sy-sysid EQ 'DS4'.
          "Check Email
          IF NOT ls_approver_details-email CS '@accenture.com'.
            RETURN.
          ENDIF.
        ENDIF.

        lo_recepient = cl_cam_address_bcs=>create_internet_address(
          EXPORTING
            i_address_name = CONV adr6-smtp_addr( ls_approver_details-full_name )
            i_address_string = CONV adr6-smtp_addr( ls_approver_details-email )
        ).


        "Pass Recepient
        lo_bcs->add_recipient( lo_recepient ).

        "Create Document
        lo_document = cl_document_bcs=>create_document(
          EXPORTING
            i_subject = lv_subject
            i_type    = 'HTM'
            i_text    = lit_text
        ).

        lo_bcs->set_document( lo_document ).

        "Set Send Immediately
*        lo_bcs->set_send_immediately( abap_true ).

        "Send Email
        lo_bcs->send( ).

        COMMIT WORK.
      CATCH cx_bcs.
        "Error Sending

    ENDTRY.

  ENDMETHOD.
