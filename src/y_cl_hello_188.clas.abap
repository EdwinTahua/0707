CLASS y_cl_hello_188 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS y_cl_hello_188 IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA: lv_message TYPE string.

    " Set the message to be displayed
    lv_message = 'Hello, ADT World!'.

    DATA(lv_text) = |{ text-001 } { text-002 }|.

    " Output the message to the console
    out->write( lv_text ).

    " Optionally, you can also use a breakpoint here for debugging
*    BREAK-POINT.
  ENDMETHOD.

ENDCLASS.
