CLASS zcl_aux_travel_klft DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES: tt_travel_reported  TYPE TABLE FOR REPORTED z_i_travel_klft,
           tt_booking_reported TYPE TABLE FOR REPORTED z_i_booking_klft,
           tt_supp_reported    TYPE TABLE FOR REPORTED z_i_booksup_klft.

    TYPES: tt_travel_id TYPE TABLE OF /dmo/travel_id.

    CLASS-METHODS calculate_price IMPORTING it_travel_id TYPE tt_travel_id.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_aux_travel_klft IMPLEMENTATION.

  METHOD calculate_price.

    DATA: lv_total_booking_price TYPE /dmo/total_price,
          lv_total_suppl_price   TYPE /dmo/total_price.

    IF it_travel_id IS INITIAL.
      RETURN.
    ENDIF.

    READ ENTITIES OF z_i_travel_klft
    ENTITY Travel
    FIELDS ( TravelID CurrencyCode )
    WITH VALUE #( FOR lv_travel_id IN it_travel_id ( TravelID = lv_travel_id ) )
    RESULT DATA(lt_read_travel).

    READ ENTITIES OF z_i_travel_klft
    ENTITY Travel BY \_Booking
    FROM VALUE #( FOR lv_travel_id IN it_travel_id ( TravelID = lv_travel_id
                                                     %control-FlightPrice = if_abap_behv=>mk-on
                                                     %control-CurrencyCode = if_abap_behv=>mk-on ) )
    RESULT DATA(lt_read_booking).

    LOOP AT lt_read_booking INTO DATA(ls_booking)
       GROUP BY ls_booking-TravelID INTO DATA(lv_travel_key).

      ASSIGN lt_read_travel[ KEY entity COMPONENTS TravelID = lv_travel_key ]
      TO FIELD-SYMBOL(<lfs_travel>).
      IF sy-subrc EQ 0.

        LOOP AT GROUP lv_travel_key INTO DATA(ls_booking_result)
        GROUP BY ls_booking_result-CurrencyCode INTO DATA(lv_curr).

          lv_total_booking_price = 0.

          LOOP AT GROUP lv_curr INTO DATA(ls_booking_line).
            lv_total_booking_price += ls_booking_line-FlightPrice.
          ENDLOOP.

          IF lv_curr EQ <lfs_travel>-CurrencyCode.
            <lfs_travel>-TotalPrice += lv_total_booking_price.
          ELSE.

            /dmo/cl_flight_amdp=>convert_currency(
            EXPORTING
            iv_amount = lv_total_booking_price
            iv_currency_code_source = lv_curr
            iv_currency_code_target = <lfs_travel>-CurrencyCode
            iv_exchange_rate_date = cl_abap_context_info=>get_system_date(  )
            IMPORTING
            ev_amount = DATA(lv_amount_converted) ).

            <lfs_travel>-TotalPrice += lv_amount_converted.

          ENDIF.
        ENDLOOP.

      ENDIF.
    ENDLOOP.

    READ ENTITIES OF z_i_travel_klft
    ENTITY Booking BY \_Booksup
    FROM VALUE #( FOR ls_travel IN lt_read_booking ( TravelID = ls_travel-TravelID
                                                     BookingID = ls_travel-BookingID
                                                     %control-Price = if_abap_behv=>mk-on
                                                     %control-CurrencyCode = if_abap_behv=>mk-on ) )
    RESULT DATA(lt_read_supp).

    LOOP AT lt_read_supp INTO DATA(ls_booking_supp)
    GROUP BY ls_booking_supp-TravelID INTO lv_travel_key.

      ASSIGN lt_read_travel[ KEY entity COMPONENTS TravelID = lv_travel_key ]
      TO <lfs_travel>.
      IF sy-subrc EQ 0.

        LOOP AT GROUP lv_travel_key INTO DATA(ls_supplements_result)
        GROUP BY ls_supplements_result-CurrencyCode INTO lv_curr.

          lv_total_suppl_price = 0.

          LOOP AT GROUP lv_curr INTO DATA(ls_supp_line).
            lv_total_suppl_price += ls_supp_line-price.
          ENDLOOP.

          IF lv_curr EQ <lfs_travel>-CurrencyCode.
            <lfs_travel>-TotalPrice += lv_total_suppl_price.
          ELSE.

            /dmo/cl_flight_amdp=>convert_currency(
            EXPORTING
            iv_amount = lv_total_suppl_price
            iv_currency_code_source = lv_curr
            iv_currency_code_target = <lfs_travel>-CurrencyCode
            iv_exchange_rate_date = cl_abap_context_info=>get_system_date(  )
            IMPORTING
            ev_amount = lv_amount_converted ).

            <lfs_travel>-TotalPrice += lv_amount_converted.

          ENDIF.
        ENDLOOP.

      ENDIF.
    ENDLOOP.


    MODIFY ENTITIES OF z_i_travel_klft
    ENTITY Travel
    UPDATE FROM VALUE #( for ls_travel_bo IN lt_read_travel (
                         TravelID = ls_travel_bo-TravelID
                         TotalPrice = ls_travel_bo-TotalPrice
                         %control-TotalPrice = if_abap_behv=>mk-on ) ).
  ENDMETHOD.

ENDCLASS.
