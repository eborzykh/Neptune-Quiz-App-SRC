*"* use this source file for your ABAP unit test classes

CLASS ltcl_trivia_api DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS:
      api_available FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_trivia_api IMPLEMENTATION.

  METHOD api_available.

    DATA: ls_api_count TYPE zcl_nept_qz_src_trivia_api=>ty_api_count_s.

    TRY.
        zcl_nept_qz_src_trivia_api=>get_count( IMPORTING es_count = ls_api_count ).
      CATCH zcx_nept_qz_src_trivia_api INTO DATA(lr_trivia_api).
        DATA(lv_message) = lr_trivia_api->get_longtext(  ).
    ENDTRY.

    IF ls_api_count-overall-total_num_of_questions = 0.
      IF lv_message IS INITIAL.
        lv_message = 'Trivia API returns no data or call failed'.
      ENDIF.
      cl_abap_unit_assert=>fail( lv_message ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.

**********************************************************************

*"! Test if categories can be retrieved successfully
*    get_categories_success FOR TESTING RAISING cx_static_check,
*    "! Test if count can be retrieved successfully
*    get_count_success FOR TESTING RAISING cx_static_check,
*    "! Test if quiz can be retrieved successfully
*    get_quiz_success FOR TESTING RAISING cx_static_check,
*    "! Test if token can be retrieved successfully
*    get_token_success FOR TESTING RAISING cx_static_check,
*    "! Test if token can be reset successfully
*    reset_token_success FOR TESTING RAISING cx_static_check

*METHOD get_categories_success.
*    DATA: lt_category TYPE zcl_nept_qz_src_trivia_api=>ty_api_category_s.
*
*    TRY.
*        zcl_nept_qz_src_trivia_api=>get_categories( EXPORTING et_category = lt_category ).
*      CATCH zcx_nept_qz_src_trivia_api INTO DATA(lr_trivia_api).
*        DATA(lv_message) = lr_trivia_api->get_longtext(  ).
*        cl_abap_unit_assert=>fail( lv_message ).
*    ENDTRY.
*
*    cl_abap_unit_assert=>assert_not_initial( act = lt_category-trivia_categories ).
*  ENDMETHOD.
*
*  METHOD get_count_success.
*    DATA: ls_count TYPE zcl_nept_qz_src_trivia_api=>ty_api_count_s.
*
*    TRY.
*        zcl_nept_qz_src_trivia_api=>get_count( EXPORTING es_count = ls_count ).
*      CATCH zcx_nept_qz_src_trivia_api INTO DATA(lr_trivia_api).
*        DATA(lv_message) = lr_trivia_api->get_longtext(  ).
*        cl_abap_unit_assert=>fail( lv_message ).
*    ENDTRY.
*
*    cl_abap_unit_assert=>assert_not_initial( act = ls_count ).
*  ENDMETHOD.
*
*  METHOD get_quiz_success.
*    DATA: ls_quiz TYPE zcl_nept_qz_src_trivia_api=>ty_api_quiz_s.
*
*    TRY.
*        zcl_nept_qz_src_trivia_api=>get_quiz( iv_count = 10 EXPORTING es_results = ls_quiz ).
*      CATCH zcx_nept_qz_src_trivia_api INTO DATA(lr_trivia_api).
*        DATA(lv_message) = lr_trivia_api->get_longtext(  ).
*        cl_abap_unit_assert=>fail( lv_message ).
*    ENDTRY.
*
*    cl_abap_unit_assert=>assert_not_initial( act = ls_quiz-results ).
*  ENDMETHOD.
*
*  METHOD get_token_success.
*    DATA: lv_token TYPE zcl_nept_qz_src_trivia_api=>ty_api_token.
*
*    TRY.
*        zcl_nept_qz_src_trivia_api=>get_token( EXPORTING ev_token = lv_token ).
*      CATCH zcx_nept_qz_src_trivia_api INTO DATA(lr_trivia_api).
*        DATA(lv_message) = lr_trivia_api->get_longtext(  ).
*        cl_abap_unit_assert=>fail( lv_message ).
*    ENDTRY.
*
*    cl_abap_unit_assert=>assert_not_initial( act = lv_token ).
*  ENDMETHOD.
*
*  METHOD reset_token_success.
*    DATA: lv_token TYPE zcl_nept_qz_src_trivia_api=>ty_api_token,
*          ls_response TYPE zcl_nept_qz_src_trivia_api=>ty_api_token_reset_s.
*
*    lv_token = 'SOME_VALID_TOKEN'.
*
*    TRY.
*        zcl_nept_qz_src_trivia_api=>reset_token( iv_token = lv_token EXPORTING es_response = ls_response ).
*      CATCH zcx_nept_qz_src_trivia_api INTO DATA(lr_trivia_api).
*        DATA(lv_message) = lr_trivia_api->get_longtext(  ).
*        cl_abap_unit_assert=>fail( lv_message ).
*    ENDTRY.
*
*    cl_abap_unit_assert=>assert_equals( act = ls_response-response_code exp = 0 ).
*    cl_abap_unit_assert=>assert_not_initial( act = ls_response-token ).
*  ENDMETHOD.
