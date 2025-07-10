CLASS ycl_scm_188 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .

    INTERFACES if_rap_query_provider.

  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES: tt_ya_bankdetails TYPE STANDARD TABLE OF yscm_bank_details_188=>tys_a_bank_detail_type
           WITH EMPTY KEY.

    TYPES: t_business_data          TYPE yscm_bank_details_188=>tyt_a_bank_detail_type,

           t_banks_range            TYPE RANGE OF yscm_bank_details_188=>tyt_a_bank_detail_type,

           t_business_data_external TYPE TABLE OF yce_grp_188.


    METHODS: get_bank_details_scm RETURNING VALUE(rt_table) TYPE tt_ya_bankdetails,

      get_banks IMPORTING it_filter_cond   TYPE if_rap_query_filter=>tt_name_range_pairs OPTIONAL
                          top              TYPE i OPTIONAL
                          skip             TYPE i OPTIONAL
                EXPORTING
                          et_business_data TYPE t_business_data
*                          rt_table         TYPE tt_ya_bankdetails

                RAISING
                          /iwbep/cx_cp_remote
                          /iwbep/cx_gateway
                          cx_web_http_client_error
                          cx_http_dest_provider_error.



ENDCLASS.



CLASS ycl_scm_188 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA: lt_business_data TYPE t_business_data,
          filter_condition TYPE if_rap_query_filter=>tt_name_range_pairs,
          range_table      TYPE if_rap_query_filter=>tt_range_option.

*    out->write( get_bank_details_scm( ) ).

    range_table = VALUE #( ( sign = 'I' option = 'EQ' low = 'AU' ) ).

    filter_condition = VALUE #( ( name = 'BANK_COUNTRY' range = range_table ) ).

    TRY.

        me->get_banks(
          EXPORTING
            it_filter_cond   = filter_condition
            top              = 50
            skip             = 1
          IMPORTING
            et_business_data = lt_business_data
        ).

        out->write( lt_business_data ).

        out->write( 'lin11111').

*        CATCH /iwbep/cx_cp_remote.
*        CATCH /iwbep/cx_gateway.
*        CATCH cx_web_http_client_error.
*        CATCH cx_http_dest_provider_error.

      CATCH cx_root INTO DATA(lx_exception).

        out->write( 'line3333').

        out->write( cl_message_helper=>get_latest_t100_exception( exception = lx_exception )->if_message~get_longtext( ) ).

    ENDTRY.

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

  METHOD get_banks.


    DATA:
      "lt_business_data TYPE TABLE OF yscm_bank_details_188=>tys_a_bank_detail_type,
      lo_http_client  TYPE REF TO if_web_http_client,
      lo_client_proxy TYPE REF TO /iwbep/if_cp_client_proxy,
      lo_request      TYPE REF TO /iwbep/if_cp_request_read_list,
      lo_response     TYPE REF TO /iwbep/if_cp_response_read_lst.

    DATA:
      lo_filter_factory   TYPE REF TO /iwbep/if_cp_filter_factory,
      lo_filter_node      TYPE REF TO /iwbep/if_cp_filter_node,
* lo_filter_node_2    TYPE REF TO /iwbep/if_cp_filter_node,
      lo_root_filter_node TYPE REF TO /iwbep/if_cp_filter_node
* lt_range_BANK_COUNTRY TYPE RANGE OF <element_name>,
* lt_range_BANK_INTERNAL_ID TYPE RANGE OF <element_name>
      .
    DATA: lv_url TYPE string VALUE 'https://sandbox.api.sap.com/'.


    TRY.
        " Create http client
        DATA(lo_destination) = cl_http_destination_provider=>create_by_url( i_url = lv_url ).

        lo_http_client = cl_web_http_client_manager=>create_by_http_destination(
                        i_destination = lo_destination ).

        lo_http_client->get_http_request( )->set_header_fields( VALUE #(
             (  name = 'APIKey' value = 'iNS6UF51lXGOl3PLOBTq4s5Xi52wF83t') ) ).


*lo_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_destination ).

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
        lo_filter_factory = lo_request->create_filter_factory( ).

        LOOP AT it_filter_cond INTO DATA(ls_filter_cond).


          lo_filter_node  = lo_filter_factory->create_by_range( iv_property_path     = ls_filter_cond-name
                                                                  it_range             = ls_filter_cond-range ).

          IF lo_root_filter_node IS INITIAL.
            lo_root_filter_node = lo_filter_node.

          ELSE.
            lo_root_filter_node = lo_root_filter_node->and( io_filter_node = lo_filter_node ).
          ENDIF.

        ENDLOOP.


*lo_filter_node_2  = lo_filter_factory->create_by_range( iv_property_path     = 'BANK_INTERNAL_ID'
*                                                        it_range             = lt_range_BANK_INTERNAL_ID ).

*lo_filter_node_root = lo_filter_node_1->and( lo_filter_node_2 ).

        IF lo_root_filter_node IS NOT INITIAL.
          lo_request->set_filter( lo_root_filter_node ).
        ENDIF.

        IF top GT 0.
          lo_request->set_top( top ).
        ENDIF.

        lo_request->set_skip( skip ).

        " Execute the request and retrieve the business data
        lo_response = lo_request->execute( ).
        lo_response->get_business_data( IMPORTING et_business_data = et_business_data ).

      CATCH /iwbep/cx_cp_remote INTO DATA(lx_remote).
        " Handle remote Exception
        " It contains details about the problems of your http(s) connection

      CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
        " Handle Exception

      CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
        " Handle Exception
        RAISE SHORTDUMP lx_web_http_client_error.

      CATCH cx_http_dest_provider_error INTO DATA(lx_http_dest_provider_error).
        " Handle Exception
        RAISE SHORTDUMP lx_web_http_client_error.

    ENDTRY.

  ENDMETHOD.

  METHOD if_rap_query_provider~select.

    DATA: lt_business_data          TYPE t_business_data,
          lt_business_data_external TYPE t_business_data_external.

    DATA(top) = io_request->get_paging( )->get_page_size( ).
    DATA(ski) = io_request->get_paging( )->get_offset( ).

    DATA(requested_files) = io_request->get_requested_elements( ).
    DATA(sort_order) = io_request->get_sort_elements( ).

    TRY.

        DATA(filter_condition) = io_request->get_filter( )->get_as_ranges( ).

        me->get_banks(
          EXPORTING
            it_filter_cond   = filter_condition
            top              = CONV i( top )
            skip             = CONV i( ski )
          IMPORTING
            et_business_data = lt_business_data
        ).



      CATCH cx_root INTO DATA(lx_exception).

        DATA(exception_message) = cl_message_helper=>get_latest_t100_exception( exception = lx_exception )->if_message~get_longtext( ).

    ENDTRY.

    " Convert the business data to external format

    lt_business_data_external = CORRESPONDING #( lt_business_data

                                                MAPPING bank_internal_id = bank_internal_id
                                                        bank_country = bank_country
                                                        bank_name = bank_name
                                                        swiftcode = swiftcode
                                                        bank_group = bank_group
                                                        bank_number = bank_number
                                                        region = region
                                                        street_name = street_name
                                                        city_name = city_name
                                                        branch = branch


                                                 ).

    IO_response->set_total_number_of_records( lines( lt_business_data_external ) ).

    io_response->set_data( lt_business_data_external ).

*    LOOP AT lt_business_data INTO DATA(ls_business_data).
*      APPEND VALUE #( bank_country = ls_business_data-bank_country
*                      bank_internal_id = ls_business_data-bank_internal_id
*                      bank_name = ls_business_data-bank_name
*                      bank_account = ls_business_data-bank_account
*
*                       ) TO lt_business_data_external.
*    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
