CLASS lhc_Booking DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calculateTotalFlightPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Booking~calculateTotalFlightPrice.

    METHODS validateStatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR Booking~validateStatus.

ENDCLASS.

CLASS lhc_Booking IMPLEMENTATION.

  METHOD calculateTotalFlightPrice.

    IF NOT keys IS INITIAL.
      zcl_aux_travel_klft=>calculate_price( it_travel_id = VALUE #( FOR GROUPS <booking> OF booking_key IN keys
                                            GROUP BY booking_key-TravelID
                                            WITHOUT MEMBERS ( <booking> ) ) ).
    ENDIF.

  ENDMETHOD.

  METHOD validateStatus.

    READ ENTITY z_i_travel_klft\\Booking FIELDS ( BookingStatus )
     WITH VALUE #( FOR <root_key> IN keys ( %key = <root_key> ) )
    RESULT DATA(lt_travel_result).

    LOOP AT lt_travel_result INTO DATA(ls_travel_result).
      CASE ls_travel_result-BookingStatus.
        WHEN 'N'. " Open
        WHEN 'C'. " Cancelled
        WHEN 'B'. " Blooked
        WHEN OTHERS.
          APPEND VALUE #( %key = ls_travel_result-%key ) TO failed-booking.
          APPEND VALUE #( %key = ls_travel_result-%key
                          %msg = new_message( id = 'Z_MC_TRAVEL'
                                          number = '008'
                                              v1 = ls_travel_result-BookingStatus
                                        severity = if_abap_behv_message=>severity-error )

             %element-BookingStatus = if_abap_behv=>mk-on ) TO reported-booking.
      ENDCASE.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
