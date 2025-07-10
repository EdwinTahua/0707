CLASS y_cl_select_188 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  inTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
  TYPES: tt_carries TYPE STANDARD TABLE OF /dmo/carrier WITH empty KEY,
         tt_travel TYPE STANDARD TABLE OF ytb_grp_188 WITH empty KEY.

  METHODS: get_carries
    RETURNING VALUE(rt_carries) TYPE tt_carries,

    get_travel RETURNING VALUE(rt_travel) TYPE tt_travel.

ENDCLASS.



CLASS y_cl_select_188 IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
*    out->write( get_carries( ) ).

    DATA(rt_travel) = get_travel( ).

    out->write( get_travel( ) ).

    out->write( |Travel data: { lines( rt_travel ) }| ).

  ENDMETHOD.

  METHOD get_carries.
    SELECT * FROM /dmo/carrier
      INTO TABLE @rt_carries.
  ENDMETHOD.

  METHOD get_travel.

    DATA: lt_travel TYPE standard TABLE OF ytb_grp_188.

      SELECT * FROM /dmo/a_travel_d
        INTO CORRESPONDING FIELDS OF TABLE @lt_travel
        .

      IF sy-subrc IS INITIAL.

        DELETE FROM ytb_grp_188.
        COMMIT WORK AND WAIT.

        INSERT ytb_grp_188 FROM TABLE @lt_travel.
        COMMIT WORK AND WAIT.

        rt_travel = lt_travel.

      endIF.

  ENDMETHOD.

ENDCLASS.
