CLASS zcl_ext_update_entity_klft DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_ext_update_entity_klft IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    MODIFY ENTITIES OF z_i_travel_klft
    ENTITY Travel
    UPDATE FIELDS ( AgencyID Description )
    WITH VALUE #( ( TravelID = '00000015'
                    AgencyID = '070048'
                    Description = 'Test external' ) )
     FAILED DATA(failed)
     REPORTED DATA(reported).

    READ ENTITIES OF z_i_travel_klft
         ENTITY Travel
         FIELDS ( AgencyID Description )
   WITH VALUE #( ( TravelID = '00000015'  ) )
   RESULT DATA(lt_travel_data)
    FAILED failed
    REPORTED reported.

    COMMIT ENTITIES.

  ENDMETHOD.
ENDCLASS.
