class ZCL_Z6829892_ODATA1_DPC_EXT definition
  public
  inheriting from ZCL_Z6829892_ODATA1_DPC
  create public .

public section.
protected section.

  methods Z6829892_ODATA_D_CREATE_ENTITY
    redefinition .
  methods Z6829892_ODATA_D_GET_ENTITY
    redefinition .
  methods Z6829892_ODATA_D_GET_ENTITYSET
    redefinition .
  methods Z6829892_ODATA_D_UPDATE_ENTITY
    redefinition .
  methods Z6829892_ODATA_D_DELETE_ENTITY
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_Z6829892_ODATA1_DPC_EXT IMPLEMENTATION.


  METHOD z6829892_odata_d_create_entity.
    DATA: ls_data TYPE zcl_z6829892_odata1_mpc=>ts_z6829892_odata_ddic,
          ls_lfa1 TYPE z6829892_lfa1.

    io_data_provider->read_entry_data(
     IMPORTING es_data = ls_data ).

    IF NOT ls_data IS INITIAL.
      MOVE-CORRESPONDING ls_data TO ls_lfa1.
      INSERT z6829892_lfa1 FROM ls_lfa1.
    ENDIF.

  ENDMETHOD.


  METHOD z6829892_odata_d_delete_entity.
    READ TABLE it_key_tab INTO DATA(ls_k)
      WITH KEY name = 'Lifnr'.

    IF sy-subrc = 0.

      DELETE FROM z6829892_lfa1
        WHERE lifnr = ls_k-value.

    ENDIF.

endmethod.


  METHOD z6829892_odata_d_get_entity.

    READ TABLE it_key_tab INTO DATA(ls_k) WITH KEY name = 'Lifnr'.

    IF sy-subrc = 0.
      SELECT SINGLE * FROM z6829892_lfa1
        INTO @DATA(ls_lfa1)
        WHERE lifnr = @ls_k-value.

      MOVE-CORRESPONDING ls_lfa1 TO er_entity.
    ENDIF.

  ENDMETHOD.


  METHOD z6829892_odata_d_get_entityset.
**TRY.
*CALL METHOD SUPER->Z6829892_ODATA_D_GET_ENTITYSET
*  EXPORTING
*    IV_ENTITY_NAME           =
*    IV_ENTITY_SET_NAME       =
*    IV_SOURCE_NAME           =
*    IT_FILTER_SELECT_OPTIONS =
*    IS_PAGING                =
*    IT_KEY_TAB               =
*    IT_NAVIGATION_PATH       =
*    IT_ORDER                 =
*    IV_FILTER_STRING         =
*    IV_SEARCH_STRING         =
**    io_tech_request_context  =
**  IMPORTING
**    et_entityset             =
**    es_response_context      =
*    .
**  CATCH /iwbep/cx_mgw_busi_exception.
**  CATCH /iwbep/cx_mgw_tech_exception.
**ENDTRY.


    " Fetch all records from your custom Vendor Master table
    SELECT *
      FROM z6829892_lfa1
      INTO TABLE @DATA(lt_lfa1).

    IF lt_lfa1 IS NOT INITIAL.
      MOVE-CORRESPONDING lt_lfa1 TO et_entityset.
    ENDIF.

  ENDMETHOD.


  method Z6829892_ODATA_D_UPDATE_ENTITY.
  DATA: ls_data TYPE ZCL_Z6829892_ODATA1_MPC=>TS_Z6829892_ODATA_DDIC,
          ls_lfa1 TYPE Z6829892_LFA1.

    io_data_provider->read_entry_data(
     IMPORTING es_data = ls_data ).

    IF NOT ls_data IS INITIAL.
      MOVE-CORRESPONDING ls_data TO ls_lfa1.
      MODIFY Z6829892_LFA1 FROM ls_lfa1.
    ENDIF.
  endmethod.
ENDCLASS.
