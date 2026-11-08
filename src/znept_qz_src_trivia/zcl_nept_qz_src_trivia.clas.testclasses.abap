CLASS ltc_nept_qz_src_trivia DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA cut TYPE REF TO zcl_nept_qz_src_trivia.

    METHODS:
      setup,
      "! Test get_categories method with valid data
      get_categories FOR TESTING,

      "! Test get_categories method raises exception
      get_categories_exception FOR TESTING,

      "! Test get_count_overall method with valid data
      get_count_overall FOR TESTING,

      "! Test get_count_overall method raises exception
      get_count_overall_exception FOR TESTING,

      "! Test get_quiz method with valid data
      get_quiz FOR TESTING,

      "! Test get_quiz method raises exception
      get_quiz_exception FOR TESTING.

ENDCLASS.

CLASS ltc_nept_qz_src_trivia IMPLEMENTATION.

  METHOD setup.
    cut = NEW #( ).
  ENDMETHOD.

  METHOD get_categories.
    DATA: lt_category TYPE znept_qz_trivia_categ_t.

    TRY.
        zcl_nept_qz_src_trivia=>get_categories( IMPORTING et_category = lt_category ).
      CATCH zcx_nept_qz_src_trivia_api INTO DATA(lx_exception).
        cl_abap_unit_assert=>fail( msg = lx_exception->get_text( ) ).
    ENDTRY.

    cl_abap_unit_assert=>assert_not_initial( act = lt_category ).
  ENDMETHOD.

  METHOD get_categories_exception.
    DATA: lt_category TYPE znept_qz_trivia_categ_t.

    TRY.
        zcl_nept_qz_src_trivia=>get_categories( IMPORTING et_category = lt_category ).
        cl_abap_unit_assert=>fail( msg = 'Expected exception not raised' ).
      CATCH zcx_nept_qz_src_trivia_api INTO DATA(lx_exception).
        cl_abap_unit_assert=>assert_not_initial( act = lx_exception ).
    ENDTRY.
  ENDMETHOD.

  METHOD get_count_overall.
    DATA: lv_questions          TYPE i,
          lv_pending_questions  TYPE i,
          lv_verified_questions TYPE i,
          lv_rejected_questions TYPE i.

    TRY.
        zcl_nept_qz_src_trivia=>get_count_overall(
          IMPORTING
            ev_questions          = lv_questions
            ev_pending_questions  = lv_pending_questions
            ev_verified_questions = lv_verified_questions
            ev_rejected_questions = lv_rejected_questions ).
      CATCH zcx_nept_qz_src_trivia_api INTO DATA(lx_exception).
        cl_abap_unit_assert=>fail( msg = lx_exception->get_text( ) ).
    ENDTRY.

    cl_abap_unit_assert=>assert_not_initial( act = lv_questions ).
  ENDMETHOD.

  METHOD get_count_overall_exception.
    DATA: lv_questions          TYPE i,
          lv_pending_questions  TYPE i,
          lv_verified_questions TYPE i,
          lv_rejected_questions TYPE i.

    TRY.
        zcl_nept_qz_src_trivia=>get_count_overall(
          IMPORTING
            ev_questions          = lv_questions
            ev_pending_questions  = lv_pending_questions
            ev_verified_questions = lv_verified_questions
            ev_rejected_questions = lv_rejected_questions ).
        cl_abap_unit_assert=>fail( msg = 'Expected exception not raised' ).
      CATCH zcx_nept_qz_src_trivia_api INTO DATA(lx_exception).
        cl_abap_unit_assert=>assert_not_initial( act = lx_exception ).
    ENDTRY.
  ENDMETHOD.

  METHOD get_quiz.
    DATA: lt_db_parts     TYPE znept_qz_db_parts_t,
          lt_db_questions TYPE znept_qz_db_questions_t,
          lt_db_variants  TYPE znept_qz_db_variants_t.

    TRY.
        zcl_nept_qz_src_trivia=>get_quiz(
          EXPORTING
            iv_count      = 10
            iv_difficulty = 'medium'
            iv_category   = '01'
            iv_token      = 'some_token'
          IMPORTING
            et_db_parts     = lt_db_parts
            et_db_questions = lt_db_questions
            et_db_variants  = lt_db_variants ).
      CATCH zcx_nept_qz_src_trivia_api INTO DATA(lx_exception).
        cl_abap_unit_assert=>fail( msg = lx_exception->get_text( ) ).
    ENDTRY.

    cl_abap_unit_assert=>assert_not_initial( act = lt_db_parts ).
  ENDMETHOD.

  METHOD get_quiz_exception.
    DATA: lt_db_parts     TYPE znept_qz_db_parts_t,
          lt_db_questions TYPE znept_qz_db_questions_t,
          lt_db_variants  TYPE znept_qz_db_variants_t.

    TRY.
        zcl_nept_qz_src_trivia=>get_quiz(
          EXPORTING
            iv_count      = 10
            iv_difficulty = 'medium'
            iv_category   = '01'
            iv_token      = 'some_token'
          IMPORTING
            et_db_parts     = lt_db_parts
            et_db_questions = lt_db_questions
            et_db_variants  = lt_db_variants ).
        cl_abap_unit_assert=>fail( msg = 'Expected exception not raised' ).
      CATCH zcx_nept_qz_src_trivia_api INTO DATA(lx_exception).
        cl_abap_unit_assert=>assert_not_initial( act = lx_exception ).
    ENDTRY.
  ENDMETHOD.

ENDCLASS.

**********************************************************************
* made by Joule
**********************************************************************
*CLASS ltc_nept_qz_src_trivia_api DEFINITION FINAL FOR TESTING
*  DURATION SHORT RISK LEVEL HARMLESS.
*
*  PRIVATE SECTION.
*    DATA: cut TYPE REF TO zcl_nept_qz_src_trivia_api.
*
*    METHODS:
*      setup,
*
*      "! Test get_categories method
*      get_categories_success FOR TESTING,
*      get_categories_exception FOR TESTING,
*
*      "! Test get_count method
*      get_count_success FOR TESTING,
*      get_count_exception FOR TESTING,
*
*      "! Test get_quiz method
*      get_quiz_success FOR TESTING,
*      get_quiz_exception FOR TESTING,
*
*      "! Test get_token method
*      get_token_success FOR TESTING,
*      get_token_exception FOR TESTING,
*
*      "! Test reset_token method
*      reset_token_success FOR TESTING,
*      reset_token_exception FOR TESTING.
*
*ENDCLASS.
*
*CLASS ltc_nept_qz_src_trivia_api IMPLEMENTATION.
*
*  METHOD setup.
*    cut = NEW #( ).
*  ENDMETHOD.
*
*  METHOD get_categories_success.
*    DATA: lt_category TYPE zcl_nept_qz_src_trivia_api=>ty_api_category_s.
*
*    cut=>get_categories( IMPORTING et_category = lt_category ).
*
*    cl_abap_unit_assert=>assert_not_initial( act = lt_category ).
*  ENDMETHOD.
*
*  METHOD get_categories_exception.
*    TRY.
*        cut=>get_categories( IMPORTING et_category = DATA(lt_category) ).
*      CATCH zcx_nept_qz_src_trivia_api INTO DATA(lx_exception).
*        cl_abap_unit_assert=>assert_not_initial( act = lx_exception ).
*    ENDTRY.
*  ENDMETHOD.
*
*  METHOD get_count_success.
*    DATA: ls_count TYPE zcl_nept_qz_src_trivia_api=>ty_api_count_s.
*
*    cut=>get_count( IMPORTING es_count = ls_count ).
*
*    cl_abap_unit_assert=>assert_not_initial( act = ls_count ).
*  ENDMETHOD.
*
*  METHOD get_count_exception.
*    TRY.
*        cut=>get_count( IMPORTING es_count = DATA(ls_count) ).
*      CATCH zcx_nept_qz_src_trivia_api INTO DATA(lx_exception).
*        cl_abap_unit_assert=>assert_not_initial( act = lx_exception ).
*    ENDTRY.
*  ENDMETHOD.
*
*  METHOD get_quiz_success.
*    DATA: ls_results TYPE zcl_nept_qz_src_trivia_api=>ty_api_quiz_s.
*
*    cut=>get_quiz(
*      EXPORTING
*        iv_count     = 10
*        iv_difficulty = 'medium'
*        iv_category  = '9'
*        iv_token     = 'exampletoken'
*      IMPORTING
*        es_results   = ls_results ).
*
*    cl_abap_unit_assert=>assert_not_initial( act = ls_results ).
*  ENDMETHOD.
*
*  METHOD get_quiz_exception.
*    TRY.
*        cut=>get_quiz(
*          EXPORTING
*            iv_count     = 10
*            iv_difficulty = 'medium'
*            iv_category  = '9'
*            iv_token     = 'exampletoken'
*          IMPORTING
*            es_results   = DATA(ls_results) ).
*      CATCH zcx_nept_qz_src_trivia_api INTO DATA(lx_exception).
*        cl_abap_unit_assert=>assert_not_initial( act = lx_exception ).
*    ENDTRY.
*  ENDMETHOD.
*
*  METHOD get_token_success.
*    DATA: lv_token TYPE zcl_nept_qz_src_trivia_api=>ty_api_token.
*
*    cut=>get_token( IMPORTING ev_token = lv_token ).
*
*    cl_abap_unit_assert=>assert_not_initial( act = lv_token ).
*  ENDMETHOD.
*
*  METHOD get_token_exception.
*    TRY.
*        cut=>get_token( IMPORTING ev_token = DATA(lv_token) ).
*      CATCH zcx_nept_qz_src_trivia_api INTO DATA(lx_exception).
*        cl_abap_unit_assert=>assert_not_initial( act = lx_exception ).
*    ENDTRY.
*  ENDMETHOD.
*
*  METHOD reset_token_success.
*    DATA: ls_response TYPE zcl_nept_qz_src_trivia_api=>ty_api_token_reset_s.
*
*    cut=>reset_token(
*      EXPORTING
*        iv_token    = 'exampletoken'
*      IMPORTING
*        es_response = ls_response ).
*
*    cl_abap_unit_assert=>assert_not_initial( act = ls_response ).
*  ENDMETHOD.
*
*  METHOD reset_token_exception.
*    TRY.
*        cut=>reset_token(
*          EXPORTING
*            iv_token    = 'exampletoken'
*          IMPORTING
*            es_response = DATA(ls_response) ).
*      CATCH zcx_nept_qz_src_trivia_api INTO DATA(lx_exception).
*        cl_abap_unit_assert=>assert_not_initial( act = lx_exception ).
*    ENDTRY.
*  ENDMETHOD.
*
*ENDCLASS.
