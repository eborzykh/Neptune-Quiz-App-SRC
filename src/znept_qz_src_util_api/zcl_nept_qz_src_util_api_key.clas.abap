CLASS zcl_nept_qz_src_util_api_key DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      ty_util_api_param(50)    TYPE c.

    CONSTANTS: gc_default_mask TYPE ty_util_api_param VALUE '*****'.

    CLASS-METHODS utilize
      IMPORTING
                iv_value        TYPE ty_util_api_param OPTIONAL
                iv_mask         TYPE ty_util_api_param OPTIONAL
      RETURNING VALUE(rv_value) TYPE ty_util_api_param.

    CLASS-METHODS mask
      IMPORTING
                iv_mask         TYPE ty_util_api_param OPTIONAL
      RETURNING VALUE(rv_value) TYPE ty_util_api_param.

  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-METHODS get
      RETURNING VALUE(rv_value) TYPE ty_util_api_param.

ENDCLASS.


CLASS zcl_nept_qz_src_util_api_key IMPLEMENTATION.

  METHOD mask.

    IF NOT get( ) IS INITIAL.
      rv_value = gc_default_mask.
    ENDIF.

  ENDMETHOD.

  METHOD utilize.

    IF iv_value IS INITIAL OR iv_value = gc_default_mask.
      rv_value = get( ).
    ELSE.
      rv_value = iv_value.
    ENDIF.

  ENDMETHOD.

  METHOD get.

    rv_value = ''.

  ENDMETHOD.

ENDCLASS.
