FUNCTION znept_qz_f4_trivia.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      SHLP_TAB TYPE  SHLP_DESCT
*"      RECORD_TAB STRUCTURE  SEAHLPRES
*"  CHANGING
*"     VALUE(SHLP) TYPE  SHLP_DESCR
*"     VALUE(CALLCONTROL) LIKE  DDSHF4CTRL STRUCTURE  DDSHF4CTRL
*"----------------------------------------------------------------------
  DATA: lt_trivia_category TYPE znept_qz_trivia_categ_t.

  IF callcontrol-step = 'SELECT'.

    TRY.
        zcl_nept_qz_src_trivia=>get_categories( IMPORTING et_category = lt_trivia_category ).
      CATCH zcx_nept_qz_src_trivia_api.
        CLEAR lt_trivia_category.
    ENDTRY.

    CALL FUNCTION 'F4UT_RESULTS_MAP'
      TABLES
        shlp_tab    = shlp_tab
        record_tab  = record_tab
        source_tab  = lt_trivia_category
      CHANGING
        shlp        = shlp
        callcontrol = callcontrol.

    callcontrol-step = 'DISP'.
  ENDIF.

ENDFUNCTION.
