CLASS zcl_nept_qz_src_trivia_api DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

* ----------------------------------------------------------------
* https://opentdb.com/api_config.php
* ----------------------------------------------------------------
* Code 0: Success Returned results successfully.
* Code 1: No Results Could not return results. The API doesn't have enough questions for your query. (Ex. Asking for 50 Questions in a Category that only has 20.)
* Code 2: Invalid Parameter Contains an invalid parameter. Arguements passed in aren't valid. (Ex. Amount = Five)
* Code 3: Token Not Found Session Token does not exist.
* Code 4: Token Empty Session Token has returned all possible questions for the specified query. Resetting the Token is necessary.
* Code 5: Rate Limit Too many requests have occurred. Each IP can only access the API once every 5 seconds.

    CONSTANTS:
      gc_rc_0_success         TYPE i VALUE 0,
      gc_rc_1_not_enough      TYPE i VALUE 1,
      gc_rc_2_invalid_param   TYPE i VALUE 2,
      gc_rc_3_token_not_found TYPE i VALUE 3,
      gc_rc_4_token_ret_empty TYPE i VALUE 4,
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
        es_count TYPE ty_api_count_s.

    CLASS-METHODS get_token
      EXPORTING
        ev_token TYPE ty_api_token.

    CLASS-METHODS reset_token
      IMPORTING
        iv_token TYPE ty_api_token.

    CLASS-METHODS get_quiz
      IMPORTING
        iv_count      TYPE ty_api_count
        iv_difficulty TYPE ty_api_difficulty OPTIONAL
        iv_category   TYPE ty_api_category OPTIONAL
        iv_token      TYPE ty_api_token OPTIONAL
      EXPORTING
        es_results    TYPE ty_api_quiz_s.

    CLASS-METHODS get_categories
      EXPORTING
        et_category TYPE ty_api_category_s.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_nept_qz_src_trivia_api IMPLEMENTATION.

  METHOD get_categories.
* ----------------------------------------------------------------

    DATA: lv_url          TYPE string,
          lv_response     TYPE string,
          lr_json_data    TYPE REF TO data,
          ls_api_category TYPE ty_api_category_s.

    CLEAR et_category.

    lv_url = |https://opentdb.com/api_category.php|.

    cl_http_client=>create_by_url( EXPORTING url = lv_url
                                   IMPORTING client = DATA(http_client)
                                   EXCEPTIONS argument_not_found = 1
                                              plugin_not_active  = 2
                                              internal_error     = 3
                                              OTHERS             = 4 ).
    IF sy-subrc = 0.
      http_client->send( ).
      http_client->receive( ).
      lv_response = http_client->response->get_cdata( ).
    ENDIF.

    IF NOT lv_response IS INITIAL.
      CALL METHOD /ui2/cl_json=>deserialize
        EXPORTING
          json         = lv_response
          pretty_name  = /ui2/cl_json=>pretty_mode-user
          assoc_arrays = abap_true
        CHANGING
          data         = ls_api_category.
    ENDIF.

    et_category = ls_api_category.

  ENDMETHOD.

  METHOD get_quiz.
* ----------------------------------------------------------------

    DATA: lv_url         TYPE string,
          lv_response    TYPE string,
          ls_api_results TYPE ty_api_quiz_s,
          lr_json_data   TYPE REF TO data.

    CLEAR es_results.

    lv_url = |https://opentdb.com/api.php?amount={ iv_count }|.

    IF NOT iv_category IS INITIAL.
      lv_url = |{ lv_url }&category={ iv_category }|.
    ENDIF.

    IF NOT iv_difficulty IS INITIAL.
      lv_url = |{ lv_url }&difficulty={ iv_difficulty }|.
    ENDIF.

    IF NOT iv_token IS INITIAL.
      lv_url = |{ lv_url }&token={ iv_token }|.
    ENDIF.

    cl_http_client=>create_by_url( EXPORTING url = lv_url
                                   IMPORTING client = DATA(http_client)
                                   EXCEPTIONS argument_not_found = 1
                                              plugin_not_active  = 2
                                              internal_error     = 3
                                              OTHERS             = 4 ).
    IF sy-subrc = 0.
      http_client->send( ).
      http_client->receive( ).
      lv_response = http_client->response->get_cdata( ).
    ENDIF.

    IF NOT lv_response IS INITIAL.
      CALL METHOD /ui2/cl_json=>deserialize
        EXPORTING
          json         = lv_response
          pretty_name  = /ui2/cl_json=>pretty_mode-user
          assoc_arrays = abap_true
        CHANGING
          data         = ls_api_results.
    ENDIF.

    es_results = ls_api_results.

  ENDMETHOD.

  METHOD get_token.
* ----------------------------------------------------------------

    DATA: lv_url           TYPE string,
          lv_response      TYPE string,
          lr_json_data     TYPE REF TO data,
          ls_api_token_get TYPE ty_api_token_get_s.

    CLEAR ev_token.

    lv_url = |https://opentdb.com/api_token.php?command=request|.

    cl_http_client=>create_by_url( EXPORTING url = lv_url
                                   IMPORTING client = DATA(http_client)
                                   EXCEPTIONS argument_not_found = 1
                                              plugin_not_active  = 2
                                              internal_error     = 3
                                              OTHERS             = 4 ).
    IF sy-subrc = 0.
      http_client->send( ).
      http_client->receive( ).
      lv_response = http_client->response->get_cdata( ).
    ENDIF.

    IF NOT lv_response IS INITIAL.
      CALL METHOD /ui2/cl_json=>deserialize
        EXPORTING
          json         = lv_response
          pretty_name  = /ui2/cl_json=>pretty_mode-user
          assoc_arrays = abap_true
        CHANGING
          data         = ls_api_token_get.
    ENDIF.

  ENDMETHOD.

  METHOD reset_token.
* ----------------------------------------------------------------

    DATA: lv_url             TYPE string,
          lv_response        TYPE string,
          ls_api_token_reset TYPE ty_api_token_reset_s,
          lr_json_data       TYPE REF TO data.

    lv_url = |https://opentdb.com/api.php?command=reset&token={ iv_token }|.

    cl_http_client=>create_by_url( EXPORTING url = lv_url
                                   IMPORTING client = DATA(http_client)
                                   EXCEPTIONS argument_not_found = 1
                                              plugin_not_active  = 2
                                              internal_error     = 3
                                              OTHERS             = 4 ).
    IF sy-subrc = 0.
      http_client->send( ).
      http_client->receive( ).
      lv_response = http_client->response->get_cdata( ).
    ENDIF.

    IF NOT lv_response IS INITIAL.
      CALL METHOD /ui2/cl_json=>deserialize
        EXPORTING
          json         = lv_response
          pretty_name  = /ui2/cl_json=>pretty_mode-user
          assoc_arrays = abap_true
        CHANGING
          data         = ls_api_token_reset.
    ENDIF.

  ENDMETHOD.

  METHOD get_count.
* ----------------------------------------------------------------

    DATA: lv_url           TYPE string,
          lv_response      TYPE string,
          lt_name_mappings TYPE /ui2/cl_json=>name_mappings,
          ls_name_mapping  TYPE /ui2/cl_json=>name_mapping,
          lr_json_data     TYPE REF TO data,
          ls_api_count     TYPE ty_api_count_s.

    CLEAR es_count.

    lv_url = |https://opentdb.com/api_count_global.php|.

    cl_http_client=>create_by_url( EXPORTING url = lv_url
                                   IMPORTING client = DATA(http_client)
                                   EXCEPTIONS argument_not_found = 1
                                              plugin_not_active  = 2
                                              internal_error     = 3
                                              OTHERS             = 4 ).
    IF sy-subrc = 0.
      http_client->send( ).
      http_client->receive( ).
      lv_response = http_client->response->get_cdata( ).
    ENDIF.

    IF NOT lv_response IS INITIAL.

* long names in JSON structure issue
      ls_name_mapping-abap = 'total_num_of_verified_question'.
      ls_name_mapping-json = 'total_num_of_verified_questions'.
      INSERT ls_name_mapping INTO TABLE lt_name_mappings.

      ls_name_mapping-abap = 'total_num_of_rejected_question'.
      ls_name_mapping-json = 'total_num_of_rejected_questions'.
      INSERT ls_name_mapping INTO TABLE lt_name_mappings.

      CALL METHOD /ui2/cl_json=>deserialize
        EXPORTING
          json          = lv_response
          pretty_name   = /ui2/cl_json=>pretty_mode-user
          assoc_arrays  = abap_true
          name_mappings = lt_name_mappings
        CHANGING
          data          = ls_api_count.

      es_count = ls_api_count.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
