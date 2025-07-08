CLASS ycl_yhttpsrv_188 DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.

    METHODS: get_bank_details RETURNING VALUE(r_json) TYPE string.

ENDCLASS.



CLASS ycl_yhttpsrv_188 IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.

    DATA(lt_params) = request->get_form_fields( ).

    READ TABLE lt_params REFERENCE INTO DATA(lr_param) WITH KEY name = 'cmd'.

    IF sy-subrc <> 0.
      response->set_status( i_code = 400
                            i_reason = 'Bad Request'
                            ). " Bad Request
      RETURN.

    ENDIF.

    CASE lr_param->value.
      WHEN 'timestamp'.
        response->set_text( |'text/plain; charset=utf-8' {

                                cl_abap_context_info=>get_user_technical_name( ) } | &&

                                | on  { cl_abap_context_info=>get_system_date( ) DATE = ENVIRONMENT } | &&
                                | at { cl_abap_context_info=>get_system_time( ) TIME = ENVIRONMENT } | ).


      WHEN 'getbankdetails'.

      response->set_content_type( content_type = 'application/json' ).
      response->set_text( get_bank_details( ) ).

      WHEN 'getbankdetailsxml'.
        response->set_content_type( content_type = 'application/xml' ).
        response->set_text( get_bank_details( ) ).

      WHEN 'getbankdetailshtml'.
        response->set_content_type( content_type = 'text/html' ).
        response->set_text( get_bank_details( ) ).

      WHEN 'getbankdetailscsv'.
        response->set_content_type( content_type = 'text/csv' ).
        response->set_text( get_bank_details( ) ).

      WHEN 'getbankdetailspdf'.
        response->set_content_type( content_type = 'application/pdf' ).
        response->set_text( get_bank_details( ) ).


      WHEN OTHERS.
        response->set_status( i_code = 404
                              i_reason = 'Bad Request'
                              ). " Not Found

    ENDCASE.

  ENDMETHOD.
  METHOD get_bank_details.

    DATA: lv_url         TYPE string VALUE 'https://sandbox.api.sap.com/s4hanacloud/sap/opu/odata/sap/',
          lo_http_client TYPE REF TO if_web_http_client.

    lo_http_client = cl_web_http_client_manager=>create_by_http_destination(

    i_destination = cl_http_destination_provider=>create_by_url( lv_url ) ).

    DATA(lo_request) = lo_http_client->get_http_request( ).

    lo_request->set_header_fields( VALUE #( ( name = 'Content-Type' value = 'application/json' )
                                            ( name = 'Accept' value = 'application/json' )
                                            ( name = 'APIKey' value = 'iNS6UF51lXGOl3PLOBTq4s5Xi52wF83t' ) ) ).
    lo_request->set_uri_path(
      EXPORTING
        i_uri_path = lv_url && 'API_BANKDETAIL_SRV/A_BankDetail?$top=50' && '&$format=json'
*       multivalue = 0
*     RECEIVING
*       r_value    =
    ).

    TRY.
        DATA(lv_response) = lo_http_client->execute( i_method = if_web_http_client=>get )->get_text( ).
      CATCH cx_web_http_client_error INTO DATA(cx).
    ENDTRY.

    r_json = lv_response.

  ENDMETHOD.

ENDCLASS.
