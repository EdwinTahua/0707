CLASS ycl_scm_188 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES tt_ya_bankdetails TYPE STANDARD TABLE OF yscm_bank_details_188=>tys_a_bank_detail_type WITH EMPTY KEY.
    METHODS get_bank_details_scm RETURNING VALUE(rt_table) TYPE tt_ya_bankdetails.


ENDCLASS.



CLASS ycl_scm_188 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    out->write( get_bank_details_scm( ) ).

  ENDMETHOD.
  METHOD get_bank_details_scm.


    DATA:
      lt_business_data TYPE TABLE OF yscm_bank_details_188=>tys_a_bank_detail_type,
      lo_http_client   TYPE REF TO if_web_http_client,
      lo_client_proxy  TYPE REF TO /iwbep/if_cp_client_proxy,
      lo_request       TYPE REF TO /iwbep/if_cp_request_read_list,
      lo_response      TYPE REF TO /iwbep/if_cp_response_read_lst.

    DATA:
      lo_filter_factory     TYPE REF TO /iwbep/if_cp_filter_factory,
      lo_filter_node_1      TYPE REF TO /iwbep/if_cp_filter_node,
*     lo_filter_node_2    TYPE REF TO /iwbep/if_cp_filter_node,
      lo_filter_node_root   TYPE REF TO /iwbep/if_cp_filter_node,
      lt_range_BANK_COUNTRY TYPE RANGE OF yscm_bank_details_188=>tys_a_bank_detail_type-bank_country.
*     lt_range_BANK_INTERNAL_ID TYPE RANGE OF <element_name>.

    DATA: lv_url TYPE string VALUE 'https://sandbox.api.sap.com/'.
    lo_http_client = cl_web_http_client_manager=>create_by_http_destination(
                    i_destination = cl_http_destination_provider=>create_by_url( lv_url ) ).

    lo_http_client->get_http_request( )->set_header_fields( VALUE #(
         (  name = 'APIKey' value = 'iNS6UF51lXGOl3PLOBTq4s5Xi52wF83t') ) ).



    TRY.
        " Create http client
*    DATA(lo_destination) = cl_http_destination_provider=>create_by_comm_arrangement(
*                                                 comm_scenario  = '<Comm Scenario>'
*                                                 comm_system_id = '<Comm System Id>'
*                                                 service_id     = '<Service Id>' ).
*    lo_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_destination ).
        lo_client_proxy = /iwbep/cl_cp_factory_remote=>create_v2_remote_proxy(
          EXPORTING
             is_proxy_model_key       = VALUE #( repository_id       = 'DEFAULT'
                                                 proxy_model_id      = 'YSCM_BANK_DETAILS_188'
                                                 proxy_model_version = '0001' )
            io_http_client             = lo_http_client
            iv_relative_service_root   = '/s4hanacloud/sap/opu/odata/sap/API_BANKDETAIL_SRV' ).

        ASSERT lo_http_client IS BOUND.


        " Navigate to the resource and create a request for the read operation
        lo_request = lo_client_proxy->create_resource_for_entity_set( 'A_BANK_DETAIL' )->create_request_for_read( ).

        " Create the filter tree

        lt_range_BANK_COUNTRY = VALUE #( ( sign = 'I' option = 'EQ' low = 'AU' high = ' ' ) ).

        lo_filter_factory = lo_request->create_filter_factory( ).
*
        lo_filter_node_1  = lo_filter_factory->create_by_range( iv_property_path     = 'BANK_COUNTRY'
                                                                it_range             = lt_range_BANK_COUNTRY ).
*    lo_filter_node_2  = lo_filter_factory->create_by_range( iv_property_path     = 'BANK_INTERNAL_ID'
*                                                            it_range             = lt_range_BANK_INTERNAL_ID ).

        lo_filter_node_root = lo_filter_node_1->and( lo_filter_node_1 ).
        lo_request->set_filter( lo_filter_node_root ).

        lo_request->set_top( 500 )->set_skip( 0 ).

        " Execute the request and retrieve the business data
        lo_response = lo_request->execute( ).
        lo_response->get_business_data( IMPORTING et_business_data = rt_table ).

      CATCH /iwbep/cx_cp_remote INTO DATA(lx_remote).
        " Handle remote Exception
        " It contains details about the problems of your http(s) connection

      CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
        " Handle Exception

      CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
        " Handle Exception
        RAISE SHORTDUMP lx_web_http_client_error.


    ENDTRY.

  ENDMETHOD.

ENDCLASS.
