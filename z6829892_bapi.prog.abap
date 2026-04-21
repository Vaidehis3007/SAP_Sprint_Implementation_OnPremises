*&---------------------------------------------------------------------*
*& Report Z6829892_BAPI
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z6829892_BAPI.

*--- Include for SAP Icons ---*
TYPE-POOLS: icon.

*----------------------------------------------------------------------*
* Data Declarations
*----------------------------------------------------------------------*
DATA: lv_matnr18     TYPE matnr18,
      ls_mat_general TYPE bapimatdoa,
      ls_return_get  TYPE bapireturn,
      ls_headdata    TYPE bapimathead,
      ls_clientdata  TYPE bapi_mara,
      ls_clientdatax TYPE bapi_marax,
      ls_return_save TYPE bapiret2.

*----------------------------------------------------------------------*
* Selection Screen
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_matnr TYPE mara-matnr OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1.

*----------------------------------------------------------------------*
* Start of Execution
*----------------------------------------------------------------------*
START-OF-SELECTION.

  " STEP 1: VERIFY THE MATERIAL EXISTS
  lv_matnr18 = p_matnr.

  CALL FUNCTION 'BAPI_MATERIAL_GET_DETAIL'
    EXPORTING
      material              = lv_matnr18
    IMPORTING
      material_general_data = ls_mat_general
      return                = ls_return_get.

  " --- Error UI for Missing Material ---
  IF ls_return_get-type = 'E'.
    PERFORM display_header USING 'HALTED' icon_alert.
    WRITE: / 'Material', p_matnr, 'was not found in the system database.' COLOR COL_NEGATIVE.
    EXIT.
  ENDIF.

  " STEP 2: PREPARE THE UPDATE
  ls_headdata-material   = p_matnr.
  ls_headdata-basic_view = 'X'.
  ls_clientdata-net_weight  = 10.
  ls_clientdatax-net_weight = 'X'.

  " STEP 3: EXECUTE BAPI
  CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
    EXPORTING
      headdata    = ls_headdata
      clientdata  = ls_clientdata
      clientdatax = ls_clientdatax
    IMPORTING
      return      = ls_return_save.

  " STEP 4: ENHANCED UI OUTPUT
  IF ls_return_save-type = 'E' OR ls_return_save-type = 'A'.
    " --- FAILURE UI ---
    PERFORM display_header USING 'UPDATE FAILED' icon_message_error.

    ULINE /1(60).
    WRITE: / '|' NO-GAP, (58) 'Reason for failure:' INTENSIFIED OFF, '|' NO-GAP.
    WRITE: / '|' NO-GAP, (58) ls_return_save-message COLOR COL_NEGATIVE, '|' NO-GAP.
    ULINE /1(60).

  ELSE.
    " --- SUCCESS UI ---
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    PERFORM display_header USING 'UPDATE SUCCESSFUL' icon_okay.

    " Displaying a "Result Box"
    ULINE /1(60).
    WRITE: / '|' NO-GAP, (20) ' Material Number:' INTENSIFIED OFF, (37) p_matnr, '|' NO-GAP.
    WRITE: / '|' NO-GAP, (20) ' Updated Field:'    INTENSIFIED OFF, (37) 'Net Weight (MARA-NTGEW)', '|' NO-GAP.
    WRITE: / '|' NO-GAP, (20) ' New Value:'        INTENSIFIED OFF, (37) '10.00' COLOR COL_POSITIVE, '|' NO-GAP.
    WRITE: / '|' NO-GAP, (20) ' Database Status:'  INTENSIFIED OFF, (37) 'Commit Work Executed' COLOR COL_TOTAL, '|' NO-GAP.
    ULINE /1(60).

    SKIP 1.
    WRITE: / icon_information AS ICON, 'Please verify changes in Transaction MM03.' COLOR COL_HEADING.
  ENDIF.

*&---------------------------------------------------------------------*
*& Form display_header
*&---------------------------------------------------------------------*
FORM display_header USING p_text p_icon.
  FORMAT COLOR COL_HEADING.
  WRITE: / '============================================================' .
  WRITE: / '|', p_icon AS ICON, (54) p_text CENTERED, '|'.
  WRITE: / '============================================================'.
  FORMAT COLOR OFF.
  SKIP 1.
ENDFORM.
