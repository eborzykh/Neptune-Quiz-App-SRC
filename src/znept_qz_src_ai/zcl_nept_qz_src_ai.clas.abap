CLASS zcl_nept_qz_src_ai DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS:
        gc_src_name TYPE string VALUE 'AI'.

    CONSTANTS:
      gc_max_questions      TYPE int2 VALUE 20, " restriction due to variant_id domain
      gc_def_questions      TYPE int2 VALUE 10,
      gc_token_per_question TYPE int2 VALUE 250,
      gc_max_variants       TYPE int2 VALUE 4.

    CLASS-METHODS get_quiz_clone
      IMPORTING
        is_db_tests     TYPE znept_qz_db_tests_s
        iv_count        TYPE int2
        iv_descriptiopn TYPE znept_qz_test_name_de
        iv_max_token    TYPE int2 OPTIONAL
        iv_progress     TYPE znept_qz_ai_progress_de OPTIONAL
        iv_difficulty   TYPE znept_qz_ai_diffparam_de OPTIONAL
        iv_model        TYPE znept_qz_ai_model_de OPTIONAL
        iv_api_key      TYPE znept_qz_ai_api_key_de
      EXPORTING
        et_db_parts     TYPE znept_qz_db_parts_t
        et_db_questions TYPE znept_qz_db_questions_t
        et_db_variants  TYPE znept_qz_db_variants_t
        es_usage        TYPE zcl_nept_qz_src_ai_api=>ty_api_usage_s
      RAISING
        zcx_nept_qz_src_ai_api.

    CLASS-METHODS get_quiz_create
      IMPORTING
        iv_descriptiopn TYPE znept_qz_test_name_de
        iv_topic        TYPE string
        iv_count        TYPE int2
        iv_max_token    TYPE int2 OPTIONAL
        iv_model        TYPE znept_qz_ai_model_de OPTIONAL
        iv_api_key      TYPE znept_qz_ai_api_key_de
      EXPORTING
        et_db_parts     TYPE znept_qz_db_parts_t
        et_db_questions TYPE znept_qz_db_questions_t
        et_db_variants  TYPE znept_qz_db_variants_t
        es_usage        TYPE zcl_nept_qz_src_ai_api=>ty_api_usage_s
      RAISING
        zcx_nept_qz_src_ai_api.

    CLASS-METHODS get_models
      IMPORTING
        iv_api_key TYPE znept_qz_ai_api_key_de
      EXPORTING
        et_model   TYPE znept_qz_ai_model_t
      RAISING
        zcx_nept_qz_src_ai_api.

    CLASS-METHODS check_availability
      RETURNING VALUE(rv_api_available) TYPE abap_bool.

  PROTECTED SECTION.
  PRIVATE SECTION.

    CONSTANTS: gc_pc_count TYPE string VALUE '{COUNT}',
               gc_eol      LIKE cl_abap_char_utilities=>newline VALUE cl_abap_char_utilities=>newline.

    CLASS-METHODS get_quiz
      IMPORTING
        iv_prompt_task  TYPE string
        iv_count        TYPE int2
        iv_api_key      TYPE znept_qz_ai_api_key_de
        iv_max_token    TYPE int2 OPTIONAL
        iv_model        TYPE znept_qz_ai_model_de OPTIONAL
      EXPORTING
        et_db_parts     TYPE znept_qz_db_parts_t
        et_db_questions TYPE znept_qz_db_questions_t
        et_db_variants  TYPE znept_qz_db_variants_t
        es_usage        TYPE zcl_nept_qz_src_ai_api=>ty_api_usage_s
      RAISING
        zcx_nept_qz_src_ai_api.

ENDCLASS.

CLASS zcl_nept_qz_src_ai IMPLEMENTATION.

  METHOD get_quiz_clone.

    TYPES:
      BEGIN OF ty_api_sample_s,
        question TYPE string,
        weight   TYPE i,
      END OF ty_api_sample_s,
      ty_api_sample_t TYPE STANDARD TABLE OF ty_api_sample_s.

    DATA: lt_sample     TYPE ty_api_sample_t.

    DATA: lt_db_parts_ref     TYPE znept_qz_db_parts_t,
          lt_db_questions_ref TYPE znept_qz_db_questions_t,
          lt_db_variants_ref  TYPE znept_qz_db_variants_t,
          lv_db_error         TYPE abap_bool.

    DATA: lt_db_parts     TYPE znept_qz_db_parts_t,
          lt_db_questions TYPE znept_qz_db_questions_t,
          lt_db_variants  TYPE znept_qz_db_variants_t.

    DATA: lv_prompt_task TYPE string,
          lv_p_level     TYPE string.

    DATA: lt_sync_by_ra   TYPE RANGE OF znept_qz_sync_user_de,
          ls_db_tests_key TYPE znept_qz_db_tests_key_s,
          lt_db_metrics   TYPE znept_qz_db_metrics_t,
          lv_attempts     TYPE i.

    CLEAR: et_db_parts, et_db_questions, et_db_variants, es_usage.

    CALL METHOD zcl_nept_qz_data_provider=>get
      EXPORTING
        is_db_tests_key = CORRESPONDING znept_qz_db_tests_key_s( is_db_tests )
        iv_version      = -1
      IMPORTING
        et_db_parts     = lt_db_parts_ref
        et_db_questions = lt_db_questions_ref
        et_db_variants  = lt_db_variants_ref
        ev_db_error     = lv_db_error.

    IF lv_db_error = abap_true OR lt_db_questions_ref IS INITIAL.
      RAISE EXCEPTION TYPE zcx_nept_qz_src_ai_api EXPORTING textid = zcx_nept_qz_src_ai_api=>read_referenced_error.
    ENDIF.

    IF NOT iv_progress IS INITIAL.

      IF iv_progress = 'personal'.
        lt_sync_by_ra = VALUE #( ( sign = 'I' option = 'EQ' low = sy-uname ) ).
      ENDIF.

      SELECT SINGLE test_id, upload_on, upload_at
        FROM znept_qz_tst
        WHERE test_id = @is_db_tests-test_id
        INTO ( @ls_db_tests_key-test_id, @ls_db_tests_key-upload_on, @ls_db_tests_key-upload_at ).

      IF sy-subrc = 0.

        SELECT * FROM znept_qz_mts
          INTO TABLE @DATA(lt_db_sync)
          WHERE sync_by IN @lt_sync_by_ra
            AND test_id = @ls_db_tests_key-test_id AND upload_on = @ls_db_tests_key-upload_on AND upload_at = @ls_db_tests_key-upload_at.

        IF sy-subrc = 0 AND NOT lt_db_sync IS INITIAL.

          SELECT * FROM znept_qz_mtd
            INTO TABLE @lt_db_metrics
            FOR ALL ENTRIES IN @lt_db_sync
            WHERE sync_id = @lt_db_sync-sync_id AND ( progress <> @zcl_nept_qz_data_provider=>gc_progress_unanswered AND progress <> @zcl_nept_qz_data_provider=>gc_progress_correct ).
          IF sy-subrc = 0.
*
          ENDIF.
        ENDIF.
      ENDIF.

      LOOP AT lt_db_questions_ref INTO DATA(ls_db_questions_ref).
        APPEND INITIAL LINE TO lt_sample ASSIGNING FIELD-SYMBOL(<fs_sample>).
        <fs_sample>-question = ls_db_questions_ref-question.

        lv_attempts = 0.
        LOOP AT lt_db_metrics INTO DATA(ls_db_metrics) WHERE question_id = ls_db_questions_ref-question_id.

          CASE ls_db_metrics-progress.
            WHEN zcl_nept_qz_data_provider=>gc_progress_incorrect.
              <fs_sample>-weight = <fs_sample>-weight + 4.
            WHEN zcl_nept_qz_data_provider=>gc_progress_improved_low.
              <fs_sample>-weight = <fs_sample>-weight + 3.
            WHEN zcl_nept_qz_data_provider=>gc_progress_improved_medium.
              <fs_sample>-weight = <fs_sample>-weight + 2.
            WHEN zcl_nept_qz_data_provider=>gc_progress_improved_high.
              <fs_sample>-weight = <fs_sample>-weight + 1.
          ENDCASE.

          lv_attempts = lv_attempts + 1.
        ENDLOOP.
        IF lv_attempts > 0.
          <fs_sample>-weight = <fs_sample>-weight / lv_attempts.
        ENDIF.
      ENDLOOP.
    ENDIF.

    lv_p_level = iv_difficulty.

    lv_prompt_task =
      |You are generating new quiz questions based on the patterns and weight from 0 to 4 that represents how difficult the question was for me to answer.| && gc_eol &&
      |Analyze the topics, concepts, and patterns covered by the following example questions:| && gc_eol.

    lv_prompt_task = lv_prompt_task && '[' && gc_eol.
    LOOP AT lt_sample INTO DATA(ls_sample).
      IF sy-tabix > 1.
        lv_prompt_task = lv_prompt_task && ',' && gc_eol.
      ENDIF.
      lv_prompt_task = lv_prompt_task && '{' && gc_eol && |"question": "{ ls_sample-question }",| && gc_eol && |"weight": { ls_sample-weight }| && gc_eol && '}'.
    ENDLOOP.
    lv_prompt_task = lv_prompt_task && gc_eol && ']' && gc_eol.

    lv_prompt_task = lv_prompt_task &&
      |Infer my strengths and weaknesses from the assigned weights and prioritize areas where I struggled most.| && gc_eol &&
      |Generate { gc_pc_count } new quiz questions that focuses on topics associated with higher-weight questions.| && gc_eol &&
      |New questions must be | &&
        COND #( WHEN NOT lv_p_level IS INITIAL
        THEN lv_p_level  && | to answer than|
        ELSE |with the same lever of difficulty and complexity as| ) && | provided in the examples.| && gc_eol &&
      |Ensure the new questions are original but clearly aligned with the topic in the examples.| && gc_eol &&
      |Avoid duplicates, near-duplicates, or trivial variations of the examples.| && gc_eol &&
      |Do not create trick questions, misleading questions, or "gotcha" questions.| && gc_eol &&
      |The objective is to assess understanding, not confuse the learner.| && gc_eol.
*      |If there is not enough token budget to generate { gc_pc_count } high-quality questions, generate fewer questions instead.| && gc_eol &&

    CALL METHOD get_quiz
      EXPORTING
        iv_prompt_task  = lv_prompt_task
        iv_count        = iv_count
        iv_api_key      = iv_api_key
        iv_model        = iv_model
        iv_max_token    = iv_max_token
      IMPORTING
        et_db_parts     = et_db_parts
        et_db_questions = et_db_questions
        et_db_variants  = et_db_variants
        es_usage        = es_usage.

  ENDMETHOD.

  METHOD get_quiz_create.

    DATA: lt_db_parts     TYPE znept_qz_db_parts_t,
          lt_db_questions TYPE znept_qz_db_questions_t,
          lt_db_variants  TYPE znept_qz_db_variants_t.

    DATA: lv_prompt_task TYPE string,
          lv_p_sample    TYPE string,
          lv_p_schema    TYPE string,
          lv_p_level     TYPE string.

    lv_prompt_task =
      |You are generating new quiz questions based on the following request:| && gc_eol &&
      |"""| && iv_topic && |"""| && gc_eol &&
      |Analyze the request to understand the topic and difficulty.| && gc_eol &&
      |Then produce { gc_pc_count } new questions.| && gc_eol &&
      |Ensure the new questions are clearly aligned with the original request.| && gc_eol &&
      |Avoid duplicates, near-duplicates, or trivial variations.| && gc_eol &&
      |Do not create trick questions, misleading questions, or "gotcha" questions.| && gc_eol &&
      |The objective is to assess understanding, not confuse the learner.| && gc_eol.
*      |If there is not enough token budget to generate { gc_pc_count } high-quality questions, generate fewer questions instead.| && gc_eol.

    CALL METHOD get_quiz
      EXPORTING
        iv_prompt_task  = lv_prompt_task
        iv_count        = iv_count
        iv_api_key      = iv_api_key
        iv_model        = iv_model
        iv_max_token    = iv_max_token
      IMPORTING
        et_db_parts     = et_db_parts
        et_db_questions = et_db_questions
        et_db_variants  = et_db_variants
        es_usage        = es_usage.

  ENDMETHOD.

  METHOD check_availability.

    CLEAR rv_api_available.

    TRY.
        zcl_nept_qz_src_ai_api=>check_availability( ).
      CATCH zcx_nept_qz_src_ai_api.
        RETURN.
    ENDTRY.

    rv_api_available = abap_true.

  ENDMETHOD.

  METHOD get_models.

    DATA: ls_api_model TYPE zcl_nept_qz_src_ai_api=>ty_api_model_s,
          lv_api_key   TYPE zcl_nept_qz_src_ai_api=>ty_api_key,
          lt_model     TYPE znept_qz_ai_model_t.

    CLEAR et_model.

    lv_api_key = iv_api_key.

    zcl_nept_qz_src_ai_api=>get_models( EXPORTING iv_api_key = lv_api_key IMPORTING es_model = ls_api_model ).

    LOOP AT ls_api_model-models ASSIGNING FIELD-SYMBOL(<fs_api_model>).
      APPEND INITIAL LINE TO lt_model ASSIGNING FIELD-SYMBOL(<fs_model>).
      <fs_model>-model = <fs_api_model>-model.
      <fs_model>-model_name = <fs_api_model>-description.
    ENDLOOP.

    et_model = lt_model.

  ENDMETHOD.

  METHOD get_quiz.

    DATA: lt_db_parts     TYPE znept_qz_db_parts_t,
          lt_db_questions TYPE znept_qz_db_questions_t,
          lt_db_variants  TYPE znept_qz_db_variants_t.

    DATA:
      lv_max_completion_tokens TYPE int2,
      lv_max_token             TYPE zcl_nept_qz_src_ai_api=>ty_api_max_token,
      lv_api_key               TYPE zcl_nept_qz_src_ai_api=>ty_api_key,
      lv_prompt                TYPE zcl_nept_qz_src_ai_api=>ty_api_prompt,
      lv_model                 TYPE zcl_nept_qz_src_ai_api=>ty_api_model,
      ls_api_quiz              TYPE zcl_nept_qz_src_ai_api=>ty_api_quiz_s,
      ls_api_usage             TYPE zcl_nept_qz_src_ai_api=>ty_api_usage_s.

    DATA:
      lv_p_task         TYPE string,
      lv_p_sample       TYPE string,
      lv_p_rules        TYPE string,
      lv_p_schema       TYPE string,
      lv_p_count        TYPE string,
      lv_p_max_variants TYPE string,
      lv_p_level        TYPE string,
      lv_pr_count       TYPE string.

    CLEAR: et_db_parts, et_db_questions, et_db_variants, es_usage.

    IF iv_count <= 0.
      RAISE EXCEPTION TYPE zcx_nept_qz_src_ai_api EXPORTING textid = zcx_nept_qz_src_ai_api=>invalid_param.
    ENDIF.

    IF iv_count > gc_max_questions.
      RAISE EXCEPTION TYPE zcx_nept_qz_src_ai_api EXPORTING textid = zcx_nept_qz_src_ai_api=>questions_limit.
    ENDIF.

    lv_api_key = iv_api_key.
    lv_model = iv_model.
    lv_max_token = iv_max_token.

    lv_p_task = iv_prompt_task.

    lv_p_count = iv_count.
    CONDENSE lv_p_count NO-GAPS.
    lv_pr_count = gc_pc_count.
    REPLACE ALL OCCURRENCES OF lv_pr_count IN lv_p_task WITH lv_p_count.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_nept_qz_src_ai_api EXPORTING textid = zcx_nept_qz_src_ai_api=>invalid_param.
    ENDIF.

    lv_p_max_variants = gc_max_variants.
    CONDENSE lv_p_max_variants NO-GAPS.

* Rules and instructions for the AI model to generate the quiz questions and answers

    lv_prompt = lv_p_task && gc_eol &&
      |Requirements:| && gc_eol &&
      |Use a mix of question types:| && gc_eol &&
      |- Multiple Choice with single correct answer| && gc_eol &&
      |- Multiple Choice with multiple (but not all) correct answers| && gc_eol &&
      |- Two variants True/False| && gc_eol &&
      |For each question:| && gc_eol &&
      |- question = the actual question text| && gc_eol &&
      |- explanation = explanation must explain why the correct answer is right.| && gc_eol &&
      |- variants = each multiple choice question can have minimum 2 and maximum { lv_p_max_variants } variants.|  && gc_eol &&
      |For each variant:| && gc_eol &&
      |- variant = possible answer text| && gc_eol &&
      |- correct = "X" for the correct answer, "" for incorrect answers.| && gc_eol.

* Response in the expected JSON format

    lv_prompt = lv_prompt && gc_eol &&
      |Expected response:| && gc_eol &&
      |The response must be ONLY valid JSON according to the provided JSON structure.| && gc_eol &&
      |Do not include markdown, comments, or any text outside the JSON.| && gc_eol &&
      |Ensure that all required fields are present in the JSON output.| && gc_eol &&
      |Validate the JSON against the provided schema before returning it.| && gc_eol.

    lv_prompt = lv_prompt                                                   && gc_eol &&
       'Expected JSON structure:'                                           && gc_eol &&
       '{'                                                                  && gc_eol &&
       '  "questions": ['                                                   && gc_eol &&
       '    {'                                                              && gc_eol &&
       '      "question": "Question text",'                                 && gc_eol &&
       '      "explanation": "Explanation of the correct answer",'          && gc_eol &&
       '      "variants": ['                                                && gc_eol &&
       '        {'                                                          && gc_eol &&
       '          "variant": "Possible answer 1",'                          && gc_eol &&
       '          "correct": ""'                                            && gc_eol &&
       '        },'                                                         && gc_eol &&
       '        {'                                                          && gc_eol &&
       '          "variant": "Possible answer 2",'                          && gc_eol &&
       '          "correct": "X"'                                           && gc_eol &&
       '        }'                                                          && gc_eol &&
       '      ]'                                                            && gc_eol &&
       '    }'                                                              && gc_eol &&
       '  ]'                                                                && gc_eol &&
       '}'                                                                  && gc_eol.

    IF lv_max_token IS INITIAL.
      lv_max_token = strlen( lv_prompt ) * 4 / 3 + iv_count * gc_token_per_question.
    ENDIF.

    zcl_nept_qz_src_ai_api=>get_quiz( EXPORTING iv_prompt = lv_prompt
                                                iv_api_key = lv_api_key
                                                iv_model = lv_model
                                                iv_max_token = lv_max_token
                                      IMPORTING es_results = ls_api_quiz
                                                es_usage = ls_api_usage ).

    LOOP AT ls_api_quiz-questions INTO DATA(ls_question).
      APPEND INITIAL LINE TO lt_db_questions ASSIGNING FIELD-SYMBOL(<fs_db_question>).
      <fs_db_question>-question_id = sy-tabix.
      <fs_db_question>-question = ls_question-question.
      <fs_db_question>-explanation = ls_question-explanation.
      LOOP AT ls_question-variants INTO DATA(ls_variant).
        APPEND INITIAL LINE TO lt_db_variants ASSIGNING FIELD-SYMBOL(<fs_db_variant>).
        <fs_db_variant>-question_id = <fs_db_question>-question_id.
        <fs_db_variant>-variant_id = sy-tabix.
        <fs_db_variant>-variant = ls_variant-variant.
        <fs_db_variant>-correct = ls_variant-correct.
      ENDLOOP.
    ENDLOOP.

    et_db_parts[] = lt_db_parts[].
    et_db_questions[] = lt_db_questions[].
    et_db_variants[] = lt_db_variants[].

    es_usage = ls_api_usage.

  ENDMETHOD.

ENDCLASS.
