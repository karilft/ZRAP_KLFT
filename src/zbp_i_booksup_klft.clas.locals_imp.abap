CLASS lhc_Supplement DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calculateTotalSuppltPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Supplement~calculateTotalSuppltPrice.

ENDCLASS.

CLASS lhc_Supplement IMPLEMENTATION.

  METHOD calculateTotalSuppltPrice.

    IF NOT keys IS INITIAL.
      zcl_aux_travel_klft=>calculate_price( it_travel_id = VALUE #( FOR GROUPS <booking_supp> OF booking_key IN keys
                                            GROUP BY booking_key-TravelID
                                            WITHOUT MEMBERS ( <booking_supp> ) ) ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_supp DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PUBLIC SECTION.
    CONSTANTS: lc_create TYPE zde_op_type VALUE 'C',
               lc_update TYPE zde_op_type VALUE 'U',
               lc_delete TYPE zde_op_type VALUE 'D'.

  PROTECTED SECTION.
    METHODS save_modified REDEFINITION.
ENDCLASS.

CLASS lsc_supp IMPLEMENTATION.
  METHOD save_modified.
    DATA: lt_supp    TYPE STANDARD TABLE OF ztb_booksuppl_kl,
          lv_op_type TYPE zde_op_type,
          lv_updated TYPE abap_bool.

    IF NOT create-supplement IS INITIAL.
      lt_supp = CORRESPONDING #( create-supplement ).
      lv_op_type = lc_create.
    ENDIF.
    IF NOT update-supplement IS INITIAL.
*      lt_supp = CORRESPONDING #( update-supplement ).
      APPEND INITIAL LINE TO lt_supp ASSIGNING FIELD-SYMBOL(<lfs_supp>).
      <lfs_supp>-booking_id = update-supplement[ 1 ]-BookingID.
      <lfs_supp>-booking_supplement_id = update-supplement[ 1 ]-BookingSupplementID.
      <lfs_supp>-currency_code = update-supplement[ 1 ]-CurrencyCode.
      <lfs_supp>-last_changed_at = update-supplement[ 1 ]-LastChangedAt.
      <lfs_supp>-price = update-supplement[ 1 ]-Price.
      <lfs_supp>-travel_id = update-supplement[ 1 ]-TravelID.
      lv_op_type = lc_update.
    ENDIF.
    IF NOT delete-supplement IS INITIAL.
      lt_supp = CORRESPONDING #( delete-supplement ).
      lv_op_type = lc_delete.
    ENDIF.

    IF NOT lt_supp IS INITIAL.

      CALL FUNCTION 'Z_SUPPL_KLFT'
        EXPORTING
          it_suppl   = lt_supp
          iv_op_type = lv_op_type
        IMPORTING
          ev_updated = lv_updated.

      IF lv_updated EQ abap_true.
*        reported-supplement[ 1 ]-...
      ENDIF.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
