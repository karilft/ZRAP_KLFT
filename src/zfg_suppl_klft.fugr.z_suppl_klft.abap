FUNCTION z_suppl_klft.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_SUPPL) TYPE  ZTY_SUPPL_KLFT
*"     REFERENCE(IV_OP_TYPE) TYPE  ZDE_OP_TYPE
*"  EXPORTING
*"     REFERENCE(EV_UPDATED) TYPE  ABAP_BOOL
*"----------------------------------------------------------------------
  CASE iv_op_type.

    WHEN 'C'. "Created
      INSERT ztb_booksuppl_kl FROM TABLE @it_suppl.
    WHEN 'U'. "Update
      UPDATE ztb_booksuppl_kl FROM TABLE @it_suppl.
    WHEN 'D'. "Detele
      DELETE ztb_booksuppl_kl FROM TABLE @it_suppl.
  ENDCASE.

  IF sy-subrc EQ 0.
    ev_updated = abap_true.
  ENDIF.

ENDFUNCTION.
