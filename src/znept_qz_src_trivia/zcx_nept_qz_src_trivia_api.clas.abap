CLASS zcx_nept_qz_src_trivia_api DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES:
      if_t100_message,
      if_abap_behv_message.

    CONSTANTS:
      message_class TYPE symsgid VALUE 'ZNEPT_QZ_SRC_TRIVIA',

      BEGIN OF questions_limit,
        msgid TYPE symsgid VALUE message_class,
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF questions_limit,

      BEGIN OF invalid_param,
        msgid TYPE symsgid VALUE message_class,
        msgno TYPE symsgno VALUE '002',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF invalid_param,

      BEGIN OF token_not_found,
        msgid TYPE symsgid VALUE message_class,
        msgno TYPE symsgno VALUE '003',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF token_not_found,

      BEGIN OF token_ret_empty,
        msgid TYPE symsgid VALUE message_class,
        msgno TYPE symsgno VALUE '004',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF token_ret_empty,

      BEGIN OF limit_requests,
        msgid TYPE symsgid VALUE message_class,
        msgno TYPE symsgno VALUE '005',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF limit_requests,

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

      BEGIN OF not_available,
        msgid TYPE symsgid VALUE message_class,
        msgno TYPE symsgno VALUE '500',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF not_available.

    DATA mv_response_code TYPE i READ-ONLY.

    METHODS:
      constructor
        IMPORTING
          textid        LIKE if_t100_message=>t100key         OPTIONAL
          response_code LIKE mv_response_code                 OPTIONAL
          previous      LIKE previous                         OPTIONAL
          severity      TYPE if_abap_behv_message=>t_severity DEFAULT  if_abap_behv_message=>severity-error
            PREFERRED PARAMETER textid.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCX_NEPT_QZ_SRC_TRIVIA_API IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    super->constructor( previous = previous ).

    me->if_abap_behv_message~m_severity = severity.

    me->mv_response_code = response_code.

    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
