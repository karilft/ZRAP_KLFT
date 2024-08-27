CLASS zcl_virtual_element_klft DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_virtual_element_klft IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA lt_original_data TYPE STANDARD TABLE OF z_c_travel_klft WITH DEFAULT KEY.
    lt_original_data = CORRESPONDING #( it_original_data ).

    LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<lfs_data>).
      <lfs_data>-DiscountPrice = <lfs_data>-TotalPrice - ( <lfs_data>-TotalPrice * ( 1 / 10 ) ).
    ENDLOOP.
    ct_calculated_data = CORRESPONDING #( lt_original_data ).
  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
    IF iv_entity = 'Z_C_TRAVEL_KLFT'.
      LOOP AT it_requested_calc_elements INTO DATA(ls_calc_elements).
        IF ls_calc_elements = 'DiscountPrice'.
          APPEND 'TotalPrice' TO et_requested_orig_elements.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
