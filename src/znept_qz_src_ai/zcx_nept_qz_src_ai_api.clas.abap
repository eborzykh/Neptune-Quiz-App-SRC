CLASS zcx_nept_qz_src_ai_api DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES:
      if_t100_message,
      if_abap_behv_message.

    CONSTANTS:
      message_class TYPE symsgid VALUE 'ZNEPT_QZ_SRC_AI',

      BEGIN OF questions_limit,
        msgid TYPE symsgid VALUE message_class,
        msgno TYPE symsgno VALUE '120',
        attr1 TYPE scx_attrname VALUE 'MV_MAX_QUESTIONS',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF questions_limit,

      BEGIN OF read_referenced_error,
        msgid TYPE symsgid VALUE message_class,
        msgno TYPE symsgno VALUE '121',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF read_referenced_error,

      BEGIN OF missing_api_key,
        msgid TYPE symsgid VALUE message_class,
        msgno TYPE symsgno VALUE '122',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF missing_api_key,

      BEGIN OF missing_path,
        msgid TYPE symsgid VALUE message_class,
        msgno TYPE symsgno VALUE '123',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF missing_path,

      BEGIN OF invalid_param,
        msgid TYPE symsgid VALUE message_class,
        msgno TYPE symsgno VALUE '002',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF invalid_param,

      BEGIN OF response_unknown,
        msgid TYPE symsgid VALUE message_class,
        msgno TYPE symsgno VALUE '100',
        attr1 TYPE scx_attrname VALUE 'MV_RESPONSE_CODE',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF response_unknown,

      BEGIN OF no_response,
        msgid TYPE symsgid VALUE message_class,
        msgno TYPE symsgno VALUE '200',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF no_response,

      BEGIN OF blank_response,
        msgid TYPE symsgid VALUE message_class,
        msgno TYPE symsgno VALUE '201',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF blank_response,

      BEGIN OF quiz_tokens_limit,
        msgid TYPE symsgid VALUE message_class,
        msgno TYPE symsgno VALUE '202',
        attr1 TYPE scx_attrname VALUE 'MV_TOKENS_SPEND',
        attr2 TYPE scx_attrname VALUE 'MV_TOKENS_LIMIT',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF quiz_tokens_limit,

      BEGIN OF format_error,
        msgid TYPE symsgid VALUE message_class,
        msgno TYPE symsgno VALUE '203',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF format_error,

      BEGIN OF bad_response,
        msgid TYPE symsgid VALUE message_class,
        msgno TYPE symsgno VALUE '400',
        attr1 TYPE scx_attrname VALUE 'MV_RESPONSE_CODE',
        attr2 TYPE scx_attrname VALUE 'MV_REASON',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF bad_response,

      BEGIN OF not_available,
        msgid TYPE symsgid VALUE message_class,
        msgno TYPE symsgno VALUE '500',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF not_available.

    DATA mv_response_code TYPE i READ-ONLY.
    DATA mv_reason TYPE string READ-ONLY.
    DATA mv_tokens_spend TYPE int2 READ-ONLY.
    DATA mv_tokens_limit TYPE int2 READ-ONLY.
    DATA mv_max_questions TYPE int2 READ-ONLY.

    METHODS:
      constructor
        IMPORTING
          textid        LIKE if_t100_message=>t100key         OPTIONAL
          response_code LIKE mv_response_code                 OPTIONAL
          reason        LIKE mv_reason                        OPTIONAL
          previous      LIKE previous                         OPTIONAL
          tokens_spend  LIKE mv_tokens_spend                  OPTIONAL
          severity      TYPE if_abap_behv_message=>t_severity DEFAULT  if_abap_behv_message=>severity-error
            PREFERRED PARAMETER textid.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcx_nept_qz_src_ai_api IMPLEMENTATION.

  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    super->constructor( previous = previous ).

    me->if_abap_behv_message~m_severity = severity.

    me->mv_response_code = response_code.
    me->mv_reason = reason.

    me->mv_tokens_spend = tokens_spend.
    me->mv_tokens_limit = zcl_nept_qz_src_ai_api=>gv_max_quiz_tokens_limit.

    me->mv_max_questions = zcl_nept_qz_src_ai=>gc_max_questions.

    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
