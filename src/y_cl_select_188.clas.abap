CLASS y_cl_select_188 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  inTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
  TYPES tt_carries TYPE STANDARD TABLE OF /dmo/carrier WITH empty KEY.
  METHODS get_carries
    RETURNING VALUE(rt_carries) TYPE tt_carries.
ENDCLASS.



CLASS y_cl_select_188 IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    out->write( get_carries( ) ).
  ENDMETHOD.

  METHOD get_carries.
    SELECT * FROM /dmo/carrier
      INTO TABLE @rt_carries.
  ENDMETHOD.

ENDCLASS.
