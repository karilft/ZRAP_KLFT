CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS acceptTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~acceptTravel RESULT result.

    METHODS createTravelByTemplate FOR MODIFY
      IMPORTING keys FOR ACTION Travel~createTravelByTemplate RESULT result.

    METHODS rejectTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~rejectTravel RESULT result.

    METHODS status FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~status.

    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateCustomer.

    METHODS validateDates FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDates.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_features.

    READ ENTITIES OF z_i_travel_klft
    ENTITY Travel
    FIELDS ( TravelID OverallStatus )
    WITH VALUE #( FOR key_row IN keys ( %key = key_row-%key ) )
    RESULT DATA(lt_travel_result).

    result = VALUE #( FOR ls_travel IN lt_travel_result (
                     %key = ls_travel-%key
                     %field-TravelID = if_abap_behv=>fc-f-read_only
                     %field-OverallStatus = if_abap_behv=>fc-f-read_only
                     %assoc-_Booking = if_abap_behv=>fc-o-enabled
                     %action-acceptTravel = COND #( WHEN ls_travel-OverallStatus EQ 'A'
                                                    THEN if_abap_behv=>fc-o-disabled
                                                    ELSE if_abap_behv=>fc-o-enabled )
                     %action-rejectTravel = COND #( WHEN ls_travel-OverallStatus EQ 'X'
                                                    THEN if_abap_behv=>fc-o-disabled
                                                    ELSE if_abap_behv=>fc-o-enabled )
                                                        )
                      ).

  ENDMETHOD.

  METHOD get_instance_authorizations.

*       CB9980010653
    DATA(lv_auth) = COND #( WHEN cl_abap_context_info=>get_user_technical_name( ) EQ 'CB9980010653'
                             THEN if_abap_behv=>auth-allowed
                             ELSE if_abap_behv=>auth-unauthorized ) .

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<lfs_key>).
      APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<lfs_result>).
      <lfs_result> = VALUE  #( %key = <lfs_key>-%key
                               %op-%update = lv_auth
                               %op-%delete = lv_auth
                               %action-acceptTravel = lv_auth
                               %action-createTravelByTemplate = lv_auth
                               %action-rejectTravel = lv_auth
                               %assoc-_Booking = lv_auth ).
    ENDLOOP.

  ENDMETHOD.

  METHOD acceptTravel.

    MODIFY ENTITIES OF z_i_travel_klft
    IN LOCAL MODE
    ENTITY Travel
    UPDATE FIELDS ( OverallStatus )
    WITH VALUE #( FOR key_row IN keys ( TravelID = key_row-TravelID
                                        OverallStatus = 'A' ) )
    FAILED failed
    REPORTED reported.

    READ ENTITIES OF z_i_travel_klft IN LOCAL MODE
    ENTITY Travel
    FIELDS ( TravelID
                    AgencyID
                    CustomerID
                    BeginDate
                    EndDate
                    BookingFee
                    TotalPrice
                    CurrencyCode
                    Description
                    OverallStatus
                    CreatedAt
                    CreatedBy
                    LastChangedAt
                    LastChangedBy )
     WITH VALUE #(  FOR key_row_aux IN keys ( TravelID = key_row_aux-TravelID ) )
     RESULT DATA(lt_travel).

*    Devolver los datos en el result
    result = VALUE #( FOR ls_travel IN lt_travel ( TravelID = ls_travel-TravelID
                                                   %param = ls_travel ) ).

    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<lfs_travel>).

      APPEND VALUE #( TravelId = <lfs_travel>-TravelID
                  %msg = new_message( id = 'Z_MC_TRAVEL'
                                   number = '006'
                                       v1 = <lfs_travel>-TravelID
                                 severity = if_abap_behv_message=>severity-success )
                  %element-customerId = if_abap_behv=>mk-on ) TO reported-travel.

    ENDLOOP.

  ENDMETHOD.

  METHOD createTravelByTemplate.

    READ ENTITIES OF z_i_travel_klft
    ENTITY Travel FIELDS ( TravelID AgencyID CustomerID BookingFee TotalPrice CurrencyCode )
    WITH VALUE #( FOR row_key IN keys ( %key = row_key-%key ) )
    RESULT DATA(lt_entity_travel)
    REPORTED reported.

    DATA lt_create_travel TYPE TABLE FOR CREATE z_i_travel_klft\\Travel.

    SELECT MAX( travel_id )
    FROM ztb_travel_klft
    INTO @DATA(lv_max_id).

    lt_create_travel = VALUE #( FOR result_row IN lt_entity_travel INDEX INTO idx
                              ( TravelID = lv_max_id + idx
                                AgencyID = result_row-AgencyID
                                CustomerID = result_row-CustomerID
                                BeginDate = cl_abap_context_info=>get_system_date( )
                                EndDate = cl_abap_context_info=>get_system_date( ) + 30
                                BookingFee = result_row-BookingFee
                                TotalPrice = result_row-TotalPrice
                                CurrencyCode = result_row-CurrencyCode
                                Description = 'Agregar comentarios'
                                OverallStatus = '0' ) ).

    MODIFY ENTITIES OF z_i_travel_klft
    IN LOCAL MODE ENTITY Travel
    CREATE FIELDS ( TravelID
                    AgencyID
                    CustomerID
                    BeginDate
                    EndDate
                    BookingFee
                    TotalPrice
                    CurrencyCode
                    Description
                    OverallStatus )
             WITH lt_create_travel
             MAPPED mapped
             FAILED failed
             REPORTED reported.

*    Devolver los datos en el result
    result = VALUE #( FOR resu_row IN lt_create_travel INDEX INTO idx
                      ( %cid_ref = keys[ idx ]-%cid_ref
                        %key = keys[ idx ]-%key
                        %param = CORRESPONDING #( resu_row ) ) ).

  ENDMETHOD.

  METHOD rejectTravel.

    MODIFY ENTITIES OF z_i_travel_klft
    IN LOCAL MODE
    ENTITY Travel
    UPDATE FIELDS ( OverallStatus )
    WITH VALUE #( FOR key_row IN keys ( TravelID = key_row-TravelID
                                        OverallStatus = 'X' ) )
    FAILED failed
    REPORTED reported.

    READ ENTITIES OF z_i_travel_klft IN LOCAL MODE
    ENTITY Travel
    FIELDS ( TravelID
                    AgencyID
                    CustomerID
                    BeginDate
                    EndDate
                    BookingFee
                    TotalPrice
                    CurrencyCode
                    Description
                    OverallStatus
                    CreatedAt
                    CreatedBy
                    LastChangedAt
                    LastChangedBy )
     WITH VALUE #(  FOR key_row_aux IN keys ( TravelID = key_row_aux-TravelID ) )
     RESULT DATA(lt_travel).

*    Devolver los datos en el result
    result = VALUE #( FOR ls_travel IN lt_travel ( TravelID = ls_travel-TravelID
                                                   %param = ls_travel ) ).

    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<lfs_travel>).

      APPEND VALUE #( TravelId = <lfs_travel>-TravelID
                  %msg = new_message( id = 'Z_MC_TRAVEL'
                                   number = '007'
                                       v1 = <lfs_travel>-TravelID
                                 severity = if_abap_behv_message=>severity-success )
                  %element-customerId = if_abap_behv=>mk-on ) TO reported-travel.

    ENDLOOP.

  ENDMETHOD.

  METHOD status.

    READ ENTITY z_i_travel_klft\\Travel FIELDS ( OverallStatus )
    WITH VALUE #( FOR <root_key> IN keys ( %key = <root_key> ) )
   RESULT DATA(lt_travel_result).

    LOOP AT lt_travel_result INTO DATA(ls_travel_result).
      CASE ls_travel_result-OverallStatus.
        WHEN 'O'. " Open
        WHEN 'A'. " Cancelled
        WHEN 'X'. " Blooked
        WHEN OTHERS.
          APPEND VALUE #( %key = ls_travel_result-%key ) TO failed-travel.
          APPEND VALUE #( %key = ls_travel_result-%key
                           %msg = new_message( id = /dmo/cx_flight_legacy=>status_is_not_valid-msgid
                         number = /dmo/cx_flight_legacy=>status_is_not_valid-msgno
                             v1 = ls_travel_result-OverallStatus
                       severity = if_abap_behv_message=>severity-error )

             %element-OverallStatus = if_abap_behv=>mk-on ) TO reported-travel.
      ENDCASE.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateCustomer.

    READ ENTITIES OF z_i_travel_klft IN LOCAL MODE
    ENTITY Travel
    FIELDS (  CustomerID )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel).

    DATA lt_customer TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.

    lt_customer = CORRESPONDING #( lt_travel DISCARDING DUPLICATES
                        MAPPING customer_id = CustomerID EXCEPT * ).
    "eliminamos los posibles campos en blanco.
    DELETE lt_customer WHERE customer_id IS INITIAL.

    SELECT FROM /dmo/customer FIELDS customer_id
    FOR ALL ENTRIES IN @lt_customer
    WHERE customer_id = @lt_customer-customer_id
    INTO TABLE @DATA(lt_customer_validos).

    "Comprobar contra los clientes que existen contra bd.
    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<lfs_travel>).
      IF <lfs_travel>-CustomerID IS INITIAL
      OR NOT line_exists( lt_customer_validos[ customer_id = <lfs_travel>-CustomerID ] ).
        "Error
        APPEND VALUE #( TravelId = <lfs_travel>-TravelID ) TO failed-travel.

        "Notificar mensaje de error
        APPEND VALUE #( TravelId = <lfs_travel>-TravelID
                        %msg = new_message( id = 'Z_MC_TRAVEL'
                                         number = '001'
                                             v1 = <lfs_travel>-TravelID
                                       severity = if_abap_behv_message=>severity-error )
*    Le indicamos el elemento que da error MK (mark)
                        %element-CustomerId = if_abap_behv=>mk-on ) TO reported-travel.

      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateDates.
    READ ENTITY z_i_travel_klft\\Travel
     FIELDS ( BeginDate EndDate )
     WITH VALUE #( FOR <root_key> IN keys ( %key = <root_key> ) )
     RESULT DATA(lt_travel_result).

    LOOP AT lt_travel_result INTO DATA(ls_travel_result).
      IF ls_travel_result-EndDate < ls_travel_result-BeginDate.

        APPEND VALUE #( %key = ls_travel_result-%key
                    TravelID = ls_travel_result-TravelID ) TO failed-travel.
        APPEND VALUE #( %key = ls_travel_result-%key
        %msg = new_message( id = /dmo/cx_flight_legacy=>end_date_before_begin_date-msgid
        number = /dmo/cx_flight_legacy=>end_date_before_begin_date-msgno
        v1 =  ls_travel_result-BeginDate
        v2 =  ls_travel_result-EndDate
        v3 =  ls_travel_result-TravelID
        severity = if_abap_behv_message=>severity-error )
        %element-BeginDate = if_abap_behv=>mk-on
        %element-EndDate = if_abap_behv=>mk-on )
        TO reported-travel.

      ELSEIF ls_travel_result-BeginDate < cl_abap_context_info=>get_system_date( ).

        APPEND VALUE #( %key = ls_travel_result-%key
        TravelId = ls_travel_result-TravelId ) TO failed-travel.
        APPEND VALUE #( %key = ls_travel_result-%key
        %msg = new_message( id = /dmo/cx_flight_legacy=>begin_date_before_system_date-msgid
                        number = /dmo/cx_flight_legacy=>begin_date_before_system_date-msgno
                      severity = if_abap_behv_message=>severity-error )
        %element-BeginDate = if_abap_behv=>mk-on
        %element-EndDate = if_abap_behv=>mk-on ) TO reported-travel.

      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_Z_I_TRAVEL_KLFT DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_Z_I_TRAVEL_KLFT IMPLEMENTATION.

  METHOD save_modified.

    DATA: lt_travel_log   TYPE STANDARD TABLE OF ztb_log_klft,
          lt_travel_log_u TYPE STANDARD TABLE OF ztb_log_klft.

    DATA(lv_flag) = cl_abap_behv=>flag_changed.
    DATA(lv_mk_on) = if_abap_behv=>mk-on.
    DATA(lv_user_mod) = cl_abap_context_info=>get_user_technical_name( ).

*    IF create-travel IS NOT INITIAL.
*      lt_travel_log = CORRESPONDING #( create-travel ).
*      LOOP AT lt_travel_log ASSIGNING FIELD-SYMBOL(<fs_travel_log_c>).
*        GET TIME STAMP FIELD <fs_travel_log_c>-created_at.
*        <fs_travel_log_c>-changing_operation = 'CREATE'.
*        READ TABLE create-travel WITH TABLE KEY entity
*                                 COMPONENTS TravelID = <fs_travel_log_c>-travel_id
*                                 INTO DATA(ls_travel).
*        IF sy-subrc = 0.
*          IF ls_travel-%control-BookingFee = lv_flag.
*            <fs_travel_log_c>-changed_field_name = 'booking_fee'.
*            <fs_travel_log_c>-changed_value = ls_travel-BookingFee.
*            <fs_travel_log_c>-user_mod = lv_user_mod.
*            TRY.
*                <fs_travel_log_c>-change_id =
*               cl_system_uuid=>create_uuid_x16_static( ) .
*              CATCH cx_uuid_error.
*
*            ENDTRY.
*            APPEND <fs_travel_log_c> TO lt_travel_log_u.
*          ENDIF.
*        ENDIF.
*      ENDLOOP.
*    ENDIF.
*
*    IF update-travel IS NOT INITIAL.
*      lt_travel_log = CORRESPONDING #( update-travel ).
*
*      LOOP AT update-travel ASSIGNING FIELD-SYMBOL(<fs_travel_log_u>).
*        ASSIGN lt_travel_log[ travel_id = <fs_travel_log_u>-TravelID ] TO
*        FIELD-SYMBOL(<fs_travel_db>).
*        GET TIME STAMP FIELD <fs_travel_db>-created_at.
*        <fs_travel_db>-changing_operation = 'UPDATE'.
*        IF <fs_travel_log_u>-%control-CustomerID = lv_mk_on.
*          <fs_travel_db>-changed_value = <fs_travel_log_u>-CustomerID.
*          <fs_travel_db>-changed_field_name = 'customer_id'.
*          <fs_travel_db>-user_mod = lv_user_mod.
*          TRY.
*              <fs_travel_db>-change_id =
*             cl_system_uuid=>create_uuid_x16_static( ).
*            CATCH cx_uuid_error.
*          ENDTRY.
*          APPEND <fs_travel_db> TO lt_travel_log_u.
*        ENDIF.
*      ENDLOOP.
*    ENDIF.
*
*    IF delete-travel IS NOT INITIAL.
*      lt_travel_log = CORRESPONDING #( delete-travel ).
*      LOOP AT lt_travel_log ASSIGNING FIELD-SYMBOL(<fs_travel_log_d>).
*        GET TIME STAMP FIELD <fs_travel_log_d>-created_at.
*        <fs_travel_log_d>-changing_operation = 'DELETE'.
*        <fs_travel_log_d>-user_mod = lv_user_mod.
*        TRY.
*            <fs_travel_log_d>-change_id =
*           cl_system_uuid=>create_uuid_x16_static( ) .
*          CATCH cx_uuid_error.
*        ENDTRY.
*        APPEND <fs_travel_log_d> TO lt_travel_log_u.
*      ENDLOOP.
*    ENDIF.
*
*    INSERT ztb_log_klft FROM TABLE @lt_travel_log_u.

  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
