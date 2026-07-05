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

    zcl_nept_qz_src_trivia_api=>get_count( IMPORTING es_count = ls_api_count ).

    IF ls_api_count-overall-total_num_of_questions = 0.
      cl_abap_unit_assert=>fail( 'Trivia API returns no data or call failed' ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
