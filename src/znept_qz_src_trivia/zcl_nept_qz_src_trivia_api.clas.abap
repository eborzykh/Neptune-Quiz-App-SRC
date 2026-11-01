"! <p class="shorttext synchronized" lang="en">Neptune Quiz App (SRC): Trivia API call</p>
"! Get more information on: <br>
"! https://opentdb.com/api_config.php
CLASS zcl_nept_qz_src_trivia_api DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    CONSTANTS:
      "! Code 0: Success Returned results successfully.
      gc_rc_0_success         TYPE i VALUE 0,
      "! Code 1: No Results Could not return results. The API doesn't have enough questions for your query. (Ex. Asking for 50 Questions in a Category that only has 20.)
      gc_rc_1_not_enough      TYPE i VALUE 1,
      "! Code 2: Invalid Parameter Contains an invalid parameter. Arguements passed in aren't valid. (Ex. Amount = Five)
      gc_rc_2_invalid_param   TYPE i VALUE 2,
      "! Code 3: Token Not Found Session Token does not exist.
      gc_rc_3_token_not_found TYPE i VALUE 3,
      "! Code 4: Token Empty Session Token has returned all possible questions for the specified query. Resetting the Token is necessary.
      gc_rc_4_token_ret_empty TYPE i VALUE 4,
      "! Code 5: Rate Limit Too many requests have occurred. Each IP can only access the API once every 5 seconds.
      gc_rc_5_limit_requests  TYPE i VALUE 5.

    TYPES:
      BEGIN OF ty_count_questions_s,
        total_num_of_questions         TYPE i,
        total_num_of_pending_questions TYPE i,
        total_num_of_verified_question TYPE i,
        total_num_of_rejected_question TYPE i,
      END OF ty_count_questions_s,
      BEGIN OF ty_count_by_category_s,
        category       TYPE string,
        cout_questions TYPE ty_count_questions_s,
      END OF ty_count_by_category_s,
      BEGIN OF ty_api_count_s,
        overall    TYPE ty_count_questions_s,
        categories TYPE ty_count_by_category_s,
      END OF ty_api_count_s,

      BEGIN OF ty_api_category_item_s,
        id   TYPE i,
        name TYPE string,
      END OF ty_api_category_item_s,
      ty_api_category_item_t TYPE TABLE OF ty_api_category_item_s WITH NON-UNIQUE DEFAULT KEY,
      BEGIN OF ty_api_category_s,
        trivia_categories TYPE ty_api_category_item_t,
      END OF ty_api_category_s,

      BEGIN OF ty_api_token_get_s,
        response_code    TYPE i,
        response_message TYPE string,
        token            TYPE string,
      END OF ty_api_token_get_s,

      BEGIN OF ty_api_token_reset_s,
        response_code TYPE int2,
        token         TYPE string,
      END OF ty_api_token_reset_s,

      BEGIN OF ty_api_results_s,
        category          TYPE string,
        correct_answer    TYPE string,
        difficulty        TYPE string,
        incorrect_answers TYPE STANDARD TABLE OF string WITH NON-UNIQUE DEFAULT KEY,
        question          TYPE string,
        type              TYPE string,
      END OF ty_api_results_s,
      BEGIN OF ty_api_quiz_s,
        response_code TYPE i,
        results       TYPE STANDARD TABLE OF ty_api_results_s WITH NON-UNIQUE DEFAULT KEY,
      END OF ty_api_quiz_s,

      ty_api_count      TYPE i,
      ty_api_category   TYPE i,
      ty_api_difficulty TYPE string,
      ty_api_token      TYPE c LENGTH 64.

    CLASS-METHODS get_count
      EXPORTING
        es_count TYPE ty_api_count_s
      RAISING
        zcx_nept_qz_src_trivia_api.

    CLASS-METHODS get_token
      EXPORTING
        ev_token TYPE ty_api_token
      RAISING
        zcx_nept_qz_src_trivia_api.

    CLASS-METHODS reset_token
      IMPORTING
        iv_token    TYPE ty_api_token
      EXPORTING
        es_response TYPE ty_api_token_reset_s
      RAISING
        zcx_nept_qz_src_trivia_api.

    CLASS-METHODS get_quiz
      IMPORTING
        iv_count      TYPE ty_api_count
        iv_difficulty TYPE ty_api_difficulty OPTIONAL
        iv_category   TYPE ty_api_category OPTIONAL
        iv_token      TYPE ty_api_token OPTIONAL
      EXPORTING
        es_results    TYPE ty_api_quiz_s
      RAISING
        zcx_nept_qz_src_trivia_api.

    CLASS-METHODS get_categories
      EXPORTING
        et_category TYPE ty_api_category_s
      RAISING
        zcx_nept_qz_src_trivia_api.

    CLASS-METHODS check_availability
      RAISING
        zcx_nept_qz_src_trivia_api.

  PROTECTED SECTION.
  PRIVATE SECTION.

    CONSTANTS: lc_s_api_token        TYPE string VALUE 'api_token.php',
               lc_s_api_category     TYPE string VALUE 'api_category.php',
               lc_s_api_count_global TYPE string VALUE 'api_count_global.php',
               lc_s_api              TYPE string VALUE 'api.php'.

    CLASS-METHODS process_request
      IMPORTING
        iv_url_script    TYPE string
        iv_url_param     TYPE string OPTIONAL
        it_name_mappings TYPE /ui2/cl_json=>name_mappings OPTIONAL
      EXPORTING
        es_response      TYPE data
      RAISING
        zcx_nept_qz_src_trivia_api.

ENDCLASS.



CLASS zcl_nept_qz_src_trivia_api IMPLEMENTATION.


  METHOD get_categories.

    CLEAR et_category.

    CALL METHOD process_request
      EXPORTING
        iv_url_script = lc_s_api_category
      IMPORTING
        es_response   = et_category.

  ENDMETHOD.


  METHOD get_count.

    DATA: lt_name_mappings TYPE /ui2/cl_json=>name_mappings.

    CLEAR es_count.

* long names in JSON structure issue
    lt_name_mappings = VALUE #( ( abap = 'total_num_of_verified_question'
                                  json = 'total_num_of_verified_questions' )
                                ( abap = 'total_num_of_rejected_question'
                                  json = 'total_num_of_rejected_questions' ) ).

    CALL METHOD process_request
      EXPORTING
        iv_url_script    = lc_s_api_count_global
        it_name_mappings = lt_name_mappings
      IMPORTING
        es_response      = es_count.

  ENDMETHOD.


  METHOD get_quiz.

    DATA: lv_url         TYPE string.

    CLEAR es_results.

    lv_url = |amount={ iv_count }|.

    IF NOT iv_category IS INITIAL.
      lv_url = |{ lv_url }&category={ iv_category }|.
    ENDIF.

    IF NOT iv_difficulty IS INITIAL.
      lv_url = |{ lv_url }&difficulty={ iv_difficulty }|.
    ENDIF.

    IF NOT iv_token IS INITIAL.
      lv_url = |{ lv_url }&token={ iv_token }|.
    ENDIF.

    CALL METHOD process_request
      EXPORTING
        iv_url_param  = lv_url
        iv_url_script = lc_s_api
      IMPORTING
        es_response   = es_results.

  ENDMETHOD.


  METHOD get_token.

    DATA: lv_url           TYPE string.

    CLEAR ev_token.

    lv_url = |command=request|.

    CALL METHOD process_request
      EXPORTING
        iv_url_param  = lv_url
        iv_url_script = lc_s_api_token
      IMPORTING
        es_response   = ev_token.

  ENDMETHOD.


  METHOD process_request.

    CONSTANTS: lc_s_protocol TYPE string VALUE 'https' ##NO_TEXT,
               lc_s_url      TYPE string VALUE 'opentdb.com' ##NO_TEXT.

    DATA: lv_url           TYPE string,
          lv_response      TYPE string,
          lv_response_code TYPE i.

    CLEAR es_response.

    lv_url = |{ lc_s_protocol }://{ lc_s_url }/{ iv_url_script }|.

    IF NOT iv_url_param IS INITIAL.
      lv_url = |{ lv_url }?{ iv_url_param }|.
    ENDIF.

    cl_http_client=>create_by_url( EXPORTING url = lv_url
                                   IMPORTING client = DATA(http_client)
                                   EXCEPTIONS argument_not_found = 1
                                              plugin_not_active  = 2
                                              internal_error     = 3
                                              OTHERS             = 4 ).
    IF sy-subrc = 0.
      http_client->send(
        EXCEPTIONS
          http_communication_failure = 1 " Communication Error
          http_invalid_state         = 2 " Invalid state
          http_processing_failed     = 3 " Error when processing method
          http_invalid_timeout       = 4 " Invalid Time Entry
          OTHERS                     = 5 ).
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_nept_qz_src_trivia_api
          EXPORTING
            textid = VALUE scx_t100key( msgid = sy-msgid
                                        msgno = sy-msgno
                                        attr1 = sy-msgv1
                                        attr2 = sy-msgv2
                                        attr3 = sy-msgv3
                                        attr4 = sy-msgv4 ).
      ENDIF.

      http_client->receive(
        EXCEPTIONS
          http_communication_failure = 1 " Communication Error
          http_invalid_state         = 2 " Invalid state
          http_processing_failed     = 3 " Error when processing method
          OTHERS                     = 4 ).
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_nept_qz_src_trivia_api
          EXPORTING
            textid = VALUE scx_t100key( msgid = sy-msgid
                                        msgno = sy-msgno
                                        attr1 = sy-msgv1
                                        attr2 = sy-msgv2
                                        attr3 = sy-msgv3
                                        attr4 = sy-msgv4 ).
      ENDIF.

      lv_response = http_client->response->get_cdata( ).
    ENDIF.

    IF NOT lv_response IS INITIAL.

      CALL METHOD /ui2/cl_json=>deserialize
        EXPORTING
          json          = lv_response
          pretty_name   = /ui2/cl_json=>pretty_mode-user
          assoc_arrays  = abap_true
          name_mappings = it_name_mappings
        CHANGING
          data          = es_response.

      IF es_response IS INITIAL.
        RAISE EXCEPTION TYPE zcx_nept_qz_src_trivia_api EXPORTING textid = zcx_nept_qz_src_trivia_api=>no_response.
      ENDIF.

* check response code
      ASSIGN COMPONENT 'response_code' OF STRUCTURE es_response TO FIELD-SYMBOL(<fs_response_code>) ##NO_TEXT.
      IF sy-subrc = 0 AND <fs_response_code> IS ASSIGNED.
        lv_response_code = <fs_response_code>.
        CASE lv_response_code.
          WHEN gc_rc_0_success.
* take no action
          WHEN gc_rc_1_not_enough.
            RAISE EXCEPTION TYPE zcx_nept_qz_src_trivia_api EXPORTING textid = zcx_nept_qz_src_trivia_api=>questions_limit.
          WHEN gc_rc_2_invalid_param.
            RAISE EXCEPTION TYPE zcx_nept_qz_src_trivia_api EXPORTING textid = zcx_nept_qz_src_trivia_api=>invalid_param.
          WHEN gc_rc_3_token_not_found.
            RAISE EXCEPTION TYPE zcx_nept_qz_src_trivia_api EXPORTING textid = zcx_nept_qz_src_trivia_api=>token_not_found.
          WHEN gc_rc_4_token_ret_empty.
            RAISE EXCEPTION TYPE zcx_nept_qz_src_trivia_api EXPORTING textid = zcx_nept_qz_src_trivia_api=>token_ret_empty.
          WHEN gc_rc_5_limit_requests.
            RAISE EXCEPTION TYPE zcx_nept_qz_src_trivia_api EXPORTING textid = zcx_nept_qz_src_trivia_api=>limit_requests.
          WHEN OTHERS.
            RAISE EXCEPTION TYPE zcx_nept_qz_src_trivia_api EXPORTING textid = zcx_nept_qz_src_trivia_api=>response_unknown response_code = lv_response_code.
        ENDCASE.
      ELSE.
* not all requests have response code
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD reset_token.

    DATA: lv_url             TYPE string.

    CLEAR es_response.

    lv_url = |command=reset&token={ iv_token }|.

    CALL METHOD process_request
      EXPORTING
        iv_url_param  = lv_url
        iv_url_script = lc_s_api
      IMPORTING
        es_response   = es_response.

  ENDMETHOD.

  METHOD check_availability.

* RAISE EXCEPTION TYPE zcx_nept_qz_src_trivia_api EXPORTING textid = zcx_nept_qz_src_trivia_api=>not_available.

  ENDMETHOD.

ENDCLASS.
