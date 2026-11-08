CLASS ltcl_trivia_ai DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS:
      api_available FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_trivia_ai IMPLEMENTATION.

  METHOD api_available.

    TRY.
        zcl_nept_qz_src_ai_api=>check_availability(  ).

      CATCH zcx_nept_qz_src_ai_api INTO DATA(lr_ai_api).
        DATA(lv_message) = lr_ai_api->get_longtext(  ).

        IF lv_message IS INITIAL.
          lv_message = 'AI Source API failed'.
        ENDIF.

        cl_abap_unit_assert=>fail( lv_message ).
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
