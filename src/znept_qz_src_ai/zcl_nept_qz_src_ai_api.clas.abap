CLASS zcl_nept_qz_src_ai_api DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CONSTANTS:
      gv_max_quiz_tokens_limit TYPE int2 VALUE 25000.

    TYPES:
      ty_api_prompt    TYPE string,
      ty_api_key       TYPE string,
      ty_api_max_token TYPE i,
      ty_api_model     TYPE string,

* result quiz JSON mapping

      BEGIN OF ty_api_variants_s,
        variant TYPE string,
        correct TYPE string,
      END OF ty_api_variants_s,
      ty_api_variants_t TYPE STANDARD TABLE OF ty_api_variants_s WITH NON-UNIQUE DEFAULT KEY,
      BEGIN OF ty_api_questions_s,
        question    TYPE string,
        explanation TYPE string,
        variants    TYPE ty_api_variants_t,
      END OF ty_api_questions_s,
      BEGIN OF ty_api_quiz_s,
        questions TYPE STANDARD TABLE OF ty_api_questions_s WITH NON-UNIQUE DEFAULT KEY,
      END OF ty_api_quiz_s,

* result usage

      BEGIN OF ty_api_usage_s,
        prompt_tokens     TYPE i,
        completion_tokens TYPE i,
        total_tokens      TYPE i,
      END OF ty_api_usage_s,

* result models

      BEGIN OF ty_api_model_item_s,
        model       TYPE string,
        description TYPE string,
      END OF ty_api_model_item_s,
      ty_api_model_item_t TYPE TABLE OF ty_api_model_item_s WITH NON-UNIQUE DEFAULT KEY,
      BEGIN OF ty_api_model_s,
        models TYPE ty_api_model_item_t,
      END OF ty_api_model_s.

    CLASS-METHODS get_quiz
      IMPORTING
        iv_prompt    TYPE ty_api_prompt
        iv_api_key   TYPE ty_api_key
        iv_max_token TYPE ty_api_max_token
        iv_model     TYPE ty_api_model
      EXPORTING
        es_results   TYPE ty_api_quiz_s
        es_usage     TYPE ty_api_usage_s
      RAISING
        zcx_nept_qz_src_ai_api.

    CLASS-METHODS get_models
      IMPORTING
        iv_api_key TYPE ty_api_key
      EXPORTING
        es_model   TYPE ty_api_model_s
      RAISING
        zcx_nept_qz_src_ai_api.

    CLASS-METHODS check_availability
      RAISING
        zcx_nept_qz_src_ai_api.

  PROTECTED SECTION.
  PRIVATE SECTION.

* response

    TYPES: BEGIN OF ty_response_s,
             status_code TYPE i,
             reason      TYPE string,
             body        TYPE string,
             error_text  TYPE string,
           END OF ty_response_s.

* request completion

    TYPES: BEGIN OF ty_messages_s,
             role    TYPE string,
             content TYPE string,
           END OF ty_messages_s,
           ty_messages_t TYPE STANDARD TABLE OF ty_messages_s WITH EMPTY KEY.
    TYPES: BEGIN OF ty_completionrequest_s,
             messages              TYPE ty_messages_t,
             model                 TYPE string,
             max_completion_tokens TYPE i,
           END OF ty_completionrequest_s.

    CLASS-METHODS process_request
      IMPORTING
        iv_api_key  TYPE string
        iv_method   TYPE string
        iv_path     TYPE string
        iv_json     TYPE string OPTIONAL
      EXPORTING
        es_response TYPE ty_response_s
      RAISING
        zcx_nept_qz_src_ai_api.

ENDCLASS.


CLASS zcl_nept_qz_src_ai_api IMPLEMENTATION.

  METHOD get_models.

* models list response

    TYPES: BEGIN OF ty_modeldata_s,
             id       TYPE i,
             object   TYPE string,
             created  TYPE i, " Unix timestamp in seconds
             owned_by TYPE string,
           END OF ty_modeldata_s,
           ty_modeldata_t TYPE STANDARD TABLE OF ty_modeldata_s WITH EMPTY KEY,
           BEGIN OF ty_modelslistresponse_s,
             data   TYPE ty_modeldata_t,
             object TYPE string,
           END OF ty_modelslistresponse_s.

    DATA: ls_response TYPE ty_response_s,
          ls_result   TYPE ty_modelslistresponse_s.

    CLEAR es_model.

    CALL METHOD process_request
      EXPORTING
        iv_api_key  = iv_api_key
        iv_path     = '/models'
        iv_method   = if_http_request=>co_request_method_get
      IMPORTING
        es_response = ls_response.

    IF ls_response-status_code = 200.

      /ui2/cl_json=>deserialize(
        EXPORTING json        = ls_response-body
                  pretty_name = /ui2/cl_json=>pretty_mode-low_case
        CHANGING  data        = ls_result ).

      LOOP AT ls_result-data INTO DATA(ls_data).
        APPEND INITIAL LINE TO es_model-models ASSIGNING FIELD-SYMBOL(<fs_model>).
        <fs_model>-model = ls_data-id.
        <fs_model>-description = ls_data-id.
      ENDLOOP.

    ENDIF.

  ENDMETHOD.

  METHOD get_quiz.

    TYPES:
      BEGIN OF ty_choice_s,
        BEGIN OF message,
          role    TYPE string,
          content TYPE string,
        END OF message,
      END OF ty_choice_s,
      ty_choices_t TYPE STANDARD TABLE OF ty_choice_s WITH EMPTY KEY,
      BEGIN OF ty_completionresponse_s,
        choices TYPE ty_choices_t,
        BEGIN OF usage,
		  prompt_tokens     TYPE i,
		  completion_tokens TYPE i,
		  total_tokens      TYPE i,
		END OF usage,
      END OF ty_completionresponse_s.

    DATA: ls_response           TYPE ty_response_s,
          ls_completionresponse TYPE ty_completionresponse_s,
          lv_max_token          TYPE int2,
          lv_model              TYPE string,
          lv_json_response      TYPE string.

    CLEAR: es_results, es_usage.

    lv_max_token = iv_max_token.
    IF lv_max_token > gv_max_quiz_tokens_limit.
      RAISE EXCEPTION TYPE zcx_nept_qz_src_ai_api EXPORTING textid = zcx_nept_qz_src_ai_api=>quiz_tokens_limit tokens_spend = lv_max_token.
    ENDIF.

    lv_model = iv_model.
    IF lv_model IS INITIAL.
*      lv_model = default.
    ENDIF.

    DATA(ls_request) = VALUE ty_completionrequest_s(
      model                 = lv_model
      messages              = VALUE #( ( role = 'user' content = iv_prompt ) )
      max_completion_tokens = lv_max_token ).

    DATA(lv_json) = /ui2/cl_json=>serialize(
      data        = ls_request
      pretty_name = /ui2/cl_json=>pretty_mode-low_case ).

    CALL METHOD process_request
      EXPORTING
        iv_api_key  = iv_api_key
        iv_path     = '/chat/completions'
        iv_json     = lv_json
        iv_method   = if_http_request=>co_request_method_post
      IMPORTING
        es_response = ls_response.


    IF ls_response-status_code = 200.

      /ui2/cl_json=>deserialize( EXPORTING json        = ls_response-body
                                           pretty_name = /ui2/cl_json=>pretty_mode-low_case
                                 CHANGING  data        = ls_completionresponse ).

      IF ls_completionresponse-choices IS NOT INITIAL.
        TRY.
            lv_json_response = ls_completionresponse-choices[ 1 ]-message-content.
            MOVE-CORRESPONDING ls_completionresponse-usage TO es_usage.
          CATCH cx_sy_itab_line_not_found.
            RAISE EXCEPTION TYPE zcx_nept_qz_src_ai_api EXPORTING textid = zcx_nept_qz_src_ai_api=>no_response.
        ENDTRY.

        IF lv_json_response IS INITIAL.
          RAISE EXCEPTION TYPE zcx_nept_qz_src_ai_api EXPORTING textid = zcx_nept_qz_src_ai_api=>blank_response.
        ENDIF.

* something cannot be achieved in the prompt

        REPLACE ALL OCCURRENCES OF '```json' IN lv_json_response WITH ''.
        REPLACE ALL OCCURRENCES OF '```' IN lv_json_response WITH ''.

        /ui2/cl_json=>deserialize( EXPORTING json = lv_json_response
                                   CHANGING  data = es_results ).
        		
        IF es_results IS INITIAL.        		
          RAISE EXCEPTION TYPE zcx_nept_qz_src_ai_api EXPORTING textid = zcx_nept_qz_src_ai_api=>format_error.
        ENDIF.
      ENDIF.

    ELSE.
      RAISE EXCEPTION TYPE zcx_nept_qz_src_ai_api
        EXPORTING
          textid        = zcx_nept_qz_src_ai_api=>bad_response
          response_code = ls_response-status_code
          reason        = ls_response-reason.
    ENDIF.

  ENDMETHOD.

  METHOD check_availability.

    CONSTANTS: lc_dummy_key TYPE ty_api_key VALUE 'blank'.

    DATA ls_response TYPE ty_response_s.

    CALL METHOD process_request
      EXPORTING
        iv_api_key  = lc_dummy_key
        iv_path     = '/models'
        iv_method   = if_http_request=>co_request_method_get
      IMPORTING
        es_response = ls_response.

    IF ls_response-status_code <> 403.
      RAISE EXCEPTION TYPE zcx_nept_qz_src_ai_api EXPORTING textid = zcx_nept_qz_src_ai_api=>not_available.
    ENDIF.

  ENDMETHOD.

  METHOD process_request.

    CONSTANTS: lc_rfc_destination TYPE rfcdest VALUE 'ZNEPT_QZ_SCR_AI'.

    CONSTANTS: lc_timeout TYPE i VALUE 180.

    DATA: lr_client TYPE REF TO if_http_client,
          lv_code   TYPE i,
          lv_reason TYPE string.

    CLEAR es_response.

    IF iv_api_key IS INITIAL.
      RAISE EXCEPTION TYPE zcx_nept_qz_src_ai_api EXPORTING textid = zcx_nept_qz_src_ai_api=>missing_api_key.
    ENDIF.

    IF iv_path IS INITIAL.
      RAISE EXCEPTION TYPE zcx_nept_qz_src_ai_api EXPORTING textid = zcx_nept_qz_src_ai_api=>missing_path.
    ENDIF.

    cl_http_client=>create_by_destination( EXPORTING destination = lc_rfc_destination
                                   IMPORTING client = lr_client
                                   EXCEPTIONS argument_not_found = 1
                                              destination_not_found = 2
                                              destination_no_authority = 3
                                              plugin_not_active = 4
                                              internal_error = 5
                                              OTHERS = 6 ).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_nept_qz_src_ai_api
        EXPORTING
          textid = VALUE scx_t100key( msgid = sy-msgid
                                      msgno = sy-msgno
                                      attr1 = sy-msgv1
                                      attr2 = sy-msgv2
                                      attr3 = sy-msgv3
                                      attr4 = sy-msgv4 ).
    ENDIF.

    cl_http_utility=>set_request_uri( request = lr_client->request uri = iv_path ).

    lr_client->propertytype_logon_popup = if_http_client=>co_disabled.
    lr_client->request->set_method( iv_method ).

    lr_client->request->set_header_field( name = 'Authorization' value = |Bearer { iv_api_key }| ).
    lr_client->request->set_header_field( name = 'Accept' value = 'application/json' ).

    IF iv_method = if_http_request=>co_request_method_post.
      lr_client->request->set_header_field( name = 'Content-Type' value = 'application/json' ).
      lr_client->request->set_cdata( iv_json ).
    ENDIF.

    lr_client->send(
        EXPORTING timeout = lc_timeout
        EXCEPTIONS
          http_communication_failure = 1
          http_invalid_state         = 2
          http_processing_failed     = 3
          http_invalid_timeout       = 4
          OTHERS                     = 5 ).
    IF sy-subrc <> 0.
      lr_client->close(  ).
      RAISE EXCEPTION TYPE zcx_nept_qz_src_ai_api
        EXPORTING
          textid = VALUE scx_t100key( msgid = sy-msgid
                                      msgno = sy-msgno
                                      attr1 = sy-msgv1
                                      attr2 = sy-msgv2
                                      attr3 = sy-msgv3
                                      attr4 = sy-msgv4 ).
    ENDIF.

    lr_client->receive(
        EXCEPTIONS
          http_communication_failure = 1
          http_invalid_state         = 2
          http_processing_failed     = 3
          OTHERS                     = 4 ).
    IF sy-subrc <> 0.
      lr_client->close(  ).
      RAISE EXCEPTION TYPE zcx_nept_qz_src_ai_api
        EXPORTING
          textid = VALUE scx_t100key( msgid = sy-msgid
                                      msgno = sy-msgno
                                      attr1 = sy-msgv1
                                      attr2 = sy-msgv2
                                      attr3 = sy-msgv3
                                      attr4 = sy-msgv4 ).
    ENDIF.

    lr_client->response->get_status( IMPORTING code = lv_code reason = lv_reason ).
    es_response-status_code = lv_code.
    es_response-reason = lv_reason.
    es_response-body = lr_client->response->get_cdata(  ).

    lr_client->close(  ).

  ENDMETHOD.

ENDCLASS.
