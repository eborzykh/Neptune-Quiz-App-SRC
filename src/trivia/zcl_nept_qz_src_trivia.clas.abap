CLASS zcl_nept_qz_src_trivia DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    CONSTANTS:
        gc_src_name TYPE string VALUE 'TRIVIA'.

    CLASS-METHODS get_quiz
      IMPORTING
        iv_count        TYPE int2
        iv_difficulty   TYPE znept_qz_trivia_diffparam_de OPTIONAL
        iv_category     TYPE znept_qz_trivia_category_id_de OPTIONAL
        iv_token        TYPE znept_qz_trivia_token_de OPTIONAL
      EXPORTING
        et_db_parts     TYPE znept_qz_db_parts_t
        et_db_questions TYPE znept_qz_db_questions_t
        et_db_variants  TYPE znept_qz_db_variants_t.

    CLASS-METHODS get_categories
      EXPORTING
        et_category TYPE znept_qz_trivia_categ_t.

    CLASS-METHODS get_count_overall
      EXPORTING
        ev_questions          TYPE i
        ev_pending_questions  TYPE i
        ev_verified_questions TYPE i
        ev_rejected_questions TYPE i.

  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-METHODS unescape IMPORTING iv_str TYPE string RETURNING VALUE(rv_str) TYPE string.

ENDCLASS.

CLASS zcl_nept_qz_src_trivia IMPLEMENTATION.

  METHOD get_quiz.
* ----------------------------------------------------------------

    DATA: ls_api_quiz       TYPE zcl_nept_qz_src_trivia_api=>ty_api_quiz_s,
          lv_api_count      TYPE zcl_nept_qz_src_trivia_api=>ty_api_count,
          lv_api_difficulty TYPE zcl_nept_qz_src_trivia_api=>ty_api_difficulty,
          lv_api_category   TYPE zcl_nept_qz_src_trivia_api=>ty_api_category,
          lv_api_token      TYPE zcl_nept_qz_src_trivia_api=>ty_api_token.

    DATA: lt_db_parts        TYPE znept_qz_db_parts_t,
          lt_db_questions    TYPE znept_qz_db_questions_t,
          lt_db_variants     TYPE znept_qz_db_variants_t,
          lt_db_variants_tmp TYPE znept_qz_db_variants_t.

    CLEAR: et_db_parts, et_db_questions, et_db_variants.

    MOVE iv_count TO lv_api_count.
    MOVE iv_difficulty TO lv_api_difficulty.
    MOVE iv_category TO lv_api_category.
    MOVE iv_token TO lv_api_token.

    zcl_nept_qz_src_trivia_api=>get_quiz( EXPORTING iv_count = lv_api_count
                                                    iv_difficulty = lv_api_difficulty
                                                    iv_category = lv_api_category
                                                    iv_token   = lv_api_token
                                          IMPORTING es_results = ls_api_quiz ).

    LOOP AT ls_api_quiz-results ASSIGNING FIELD-SYMBOL(<fs_results>).

      APPEND INITIAL LINE TO lt_db_questions ASSIGNING FIELD-SYMBOL(<fs_db_questions>).
      <fs_db_questions>-question_id = sy-tabix.
      <fs_db_questions>-question = unescape( <fs_results>-question ).

      DATA(lr_rnd) = cl_abap_random_int=>create( seed = + sy-tabix min = 1 max = lines( <fs_results>-incorrect_answers ) ).

      APPEND INITIAL LINE TO lt_db_variants_tmp ASSIGNING FIELD-SYMBOL(<fs_db_variants_tmp>).
      <fs_db_variants_tmp>-variant = unescape( <fs_results>-correct_answer ).
      <fs_db_variants_tmp>-correct = abap_true.
      <fs_db_variants_tmp>-sort = lr_rnd->get_next( ).

      LOOP AT <fs_results>-incorrect_answers ASSIGNING FIELD-SYMBOL(<fs_incorrect_answers>).
        APPEND INITIAL LINE TO lt_db_variants_tmp ASSIGNING <fs_db_variants_tmp>.
        <fs_db_variants_tmp>-variant = unescape( <fs_incorrect_answers> ).
        <fs_db_variants_tmp>-sort = lr_rnd->get_next( ).
      ENDLOOP.

      SORT lt_db_variants_tmp BY sort.

      LOOP AT lt_db_variants_tmp ASSIGNING <fs_db_variants_tmp>.
        <fs_db_variants_tmp>-question_id = <fs_db_questions>-question_id.
        <fs_db_variants_tmp>-variant_id = sy-tabix.
        CLEAR <fs_db_variants_tmp>-sort.
        APPEND <fs_db_variants_tmp> TO lt_db_variants.
      ENDLOOP.

      CLEAR lt_db_variants_tmp.

      DATA(lv_category) = unescape( <fs_results>-category ).
      READ TABLE lt_db_parts ASSIGNING FIELD-SYMBOL(<fs_db_parts>) WITH KEY description = lv_category.
      IF sy-subrc <> 0.
        APPEND INITIAL LINE TO lt_db_parts ASSIGNING <fs_db_parts>.
        <fs_db_parts>-part_id = lines( lt_db_parts ).
        <fs_db_parts>-description = lv_category.
      ENDIF.
      <fs_db_questions>-part_id = <fs_db_parts>-part_id.

    ENDLOOP.

    et_db_parts[] = lt_db_parts[].
    et_db_questions[] = lt_db_questions[].
    et_db_variants[] = lt_db_variants[].

  ENDMETHOD.

  METHOD get_categories.
* ----------------------------------------------------------------

    DATA: ls_api_category    TYPE zcl_nept_qz_src_trivia_api=>ty_api_category_s,
          lt_trivia_category TYPE znept_qz_trivia_categ_t.

    CLEAR et_category.

    zcl_nept_qz_src_trivia_api=>get_categories( IMPORTING et_category = ls_api_category ).

    LOOP AT ls_api_category-trivia_categories ASSIGNING FIELD-SYMBOL(<fs_api_category>).
      APPEND INITIAL LINE TO lt_trivia_category ASSIGNING FIELD-SYMBOL(<fs_trivia_category>).
      <fs_trivia_category>-category_id = <fs_api_category>-id.
      <fs_trivia_category>-category_name = unescape( <fs_api_category>-name ).
    ENDLOOP.

    et_category = lt_trivia_category.

  ENDMETHOD.

  METHOD unescape.

    CLEAR rv_str.

    DATA(lv_str) = iv_str.

    REPLACE ALL OCCURRENCES OF '&quot;' IN lv_str WITH '"'.
    REPLACE ALL OCCURRENCES OF '&#039;' IN lv_str WITH '`'.
    REPLACE ALL OCCURRENCES OF '&amp;' IN lv_str WITH '&'.
    REPLACE ALL OCCURRENCES OF '&lt;' IN lv_str WITH '<'.
    REPLACE ALL OCCURRENCES OF '&gt;' IN lv_str WITH '>'.
    REPLACE ALL OCCURRENCES OF '&ldquo;' IN lv_str WITH '”'.
    REPLACE ALL OCCURRENCES OF '&rdquo;' IN lv_str WITH '“'.

    rv_str = lv_str.

  ENDMETHOD.

  METHOD get_count_overall.
* ----------------------------------------------------------------

    DATA: ls_api_count TYPE zcl_nept_qz_src_trivia_api=>ty_api_count_s.

    CLEAR: ev_questions, ev_pending_questions, ev_verified_questions, ev_rejected_questions.

    zcl_nept_qz_src_trivia_api=>get_count( IMPORTING es_count = ls_api_count ).

    ev_questions = ls_api_count-overall-total_num_of_questions.
    ev_pending_questions = ls_api_count-overall-total_num_of_pending_questions.
    ev_verified_questions = ls_api_count-overall-total_num_of_verified_question.
    ev_rejected_questions = ls_api_count-overall-total_num_of_rejected_question.

  ENDMETHOD.

ENDCLASS.
