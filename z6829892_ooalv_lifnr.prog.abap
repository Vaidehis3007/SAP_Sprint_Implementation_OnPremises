*&---------------------------------------------------------------------*
*& Report Z6829892_OOALV_LIFNR
*&---------------------------------------------------------------------*
REPORT Z6829892_OOALV_LIFNR.

*----------------------------------------------------------------------*
* Table
*----------------------------------------------------------------------*
TABLES: z6829892_lfa1.

*----------------------------------------------------------------------*
* Data Declarations
*----------------------------------------------------------------------*

TYPES: BEGIN OF ty_lfa1,
         lifnr TYPE z6829892_lfa1-lifnr,
         name1 TYPE z6829892_lfa1-name1,
         ort01 TYPE z6829892_lfa1-ort01,
         land1 TYPE z6829892_lfa1-land1,
       END OF ty_lfa1.

TYPES: BEGIN OF ty_eina,
         lifnr TYPE z6829892_eina-lifnr,
         infnr TYPE z6829892_eina-infnr,
         matnr TYPE z6829892_eina-matnr,
         matkl TYPE z6829892_eina-matkl,
         anzpu TYPE z6829892_eina-anzpu,
         maktx TYPE z6829892_makt-maktx,
       END OF ty_eina.

TYPES: BEGIN OF ty_final,
         lifnr TYPE z6829892_lfa1-lifnr,
         name1 TYPE z6829892_lfa1-name1,
         land1 TYPE z6829892_lfa1-land1,
         ort01 TYPE z6829892_lfa1-ort01,
         infnr TYPE z6829892_eina-infnr,
         matnr TYPE z6829892_eina-matnr,
         matkl TYPE z6829892_eina-matkl,
         anzpu TYPE z6829892_eina-anzpu,
         maktx TYPE z6829892_makt-maktx,
       END OF ty_final.

*----------------------------------------------------------------------*
* Internal Tables and Work Areas
*----------------------------------------------------------------------*
DATA: it_lfa1  TYPE TABLE OF ty_lfa1,
      wa_lfa1  TYPE ty_lfa1,
      it_eina  TYPE TABLE OF ty_eina,
      wa_eina  TYPE ty_eina,
      it_final TYPE TABLE OF ty_final,
      wa_final TYPE ty_final.

*----------------------------------------------------------------------*
* Grid and Header
*----------------------------------------------------------------------*
DATA: go_container     TYPE REF TO cl_gui_custom_container,
      go_splitter      TYPE REF TO cl_gui_splitter_container,
      go_container_top TYPE REF TO cl_gui_container,
      go_container_alv TYPE REF TO cl_gui_container,
      go_dyndoc        TYPE REF TO cl_dd_document,
      go_alv           TYPE REF TO cl_gui_alv_grid.

DATA: it_fcat   TYPE lvc_t_fcat,
      wa_fcat   TYPE lvc_s_fcat,
      wa_layout TYPE lvc_s_layo.

*----------------------------------------------------------------------*
* Selection Screen
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: s_lifnr FOR z6829892_lfa1-lifnr.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
  " RadioButton Group
  PARAMETERS: rb_alv  RADIOBUTTON GROUP rbg1 DEFAULT 'X',
              rb_adob RADIOBUTTON GROUP rbg1.
SELECTION-SCREEN END OF BLOCK b2.

*----------------------------------------------------------------------*
* Initialization
*----------------------------------------------------------------------*
INITIALIZATION.

*----------------------------------------------------------------------*
* Start of Selection
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM fetch_data.

  IF it_final IS INITIAL.
    MESSAGE 'No data found for the given Vendor Number.' TYPE 'S' DISPLAY LIKE 'E'.
  ELSE.
    IF rb_alv = 'X'.
      " Call OO ALV Screen
      CALL SCREEN 100.
    ELSEIF rb_adob = 'X'.
      " Adobe Form Logic
      PERFORM call_adobe_form.
    ENDIF.
  ENDIF.

*&---------------------------------------------------------------------*
*& Form FETCH_DATA
*&---------------------------------------------------------------------*
FORM fetch_data.
  " Select required fields from LFA1
  SELECT lifnr land1 name1 ort01
    INTO TABLE it_lfa1
    FROM z6829892_lfa1
    WHERE lifnr IN s_lifnr.

  IF it_lfa1 IS NOT INITIAL.
    " Join EINA and MAKT for all entries in IT_LFA1
    SELECT a~lifnr a~infnr a~matnr a~matkl a~anzpu b~maktx
      INTO TABLE it_eina
      FROM z6829892_eina AS a
      INNER JOIN z6829892_makt AS b ON a~matnr = b~matnr
      FOR ALL ENTRIES IN it_lfa1
      WHERE a~lifnr = it_lfa1-lifnr
        AND b~spras = sy-langu.

    " Final Table
    SORT it_lfa1 BY lifnr.

    LOOP AT it_eina INTO wa_eina.
      CLEAR wa_final.

      " EINA + MAKT data
      wa_final-lifnr = wa_eina-lifnr.
      wa_final-infnr = wa_eina-infnr.
      wa_final-matnr = wa_eina-matnr.
      wa_final-matkl = wa_eina-matkl.
      wa_final-anzpu = wa_eina-anzpu.
      wa_final-maktx = wa_eina-maktx.

      " Read LFA1 data for current LIFNR
      READ TABLE it_lfa1 INTO wa_lfa1 WITH KEY lifnr = wa_eina-lifnr BINARY SEARCH.
      IF sy-subrc = 0.
        wa_final-name1 = wa_lfa1-name1.
        wa_final-land1 = wa_lfa1-land1.
        wa_final-ort01 = wa_lfa1-ort01.
      ENDIF.

      APPEND wa_final TO it_final.
    ENDLOOP.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form BUILD_FCAT
*&---------------------------------------------------------------------*
FORM build_fcat.
  DATA: lv_col_pos TYPE i VALUE 1.  "automatic counter for position

  DEFINE add_field.
    wa_fcat-col_pos   = lv_col_pos.
    wa_fcat-fieldname = &1.
    wa_fcat-scrtext_m = &2.
    APPEND wa_fcat TO it_fcat.
    CLEAR wa_fcat.
    lv_col_pos = lv_col_pos + 1.
  END-OF-DEFINITION.

  add_field 'LIFNR' 'Vendor No'.
  add_field 'NAME1' 'Name'.
  add_field 'ORT01' 'City'.
  add_field 'LAND1' 'Country'.
  add_field 'INFNR' 'Info Record'.
  add_field 'MATNR' 'Material No'.
  add_field 'MATKL' 'Mat. Group'.
  add_field 'ANZPU' 'No. of Points'.
  add_field 'MAKTX' 'Description'.
ENDFORM.

*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
   SET PF-STATUS 'ZSTAT'. "Back Button
   SET TITLEBAR 'ZTITL'.  "Title

  IF go_container IS INITIAL.
    " Create main container
    CREATE OBJECT go_container
      EXPORTING
        container_name = 'Z026_CONT'.

    " Split into 2 Rows for Header and ALV
    CREATE OBJECT go_splitter
      EXPORTING
        parent  = go_container
        rows    = 2
        columns = 1.

    " Top row height for the Logo and Header
    go_splitter->set_row_height( id = 1 height = 33 ).

    " Assign containers
    go_container_top = go_splitter->get_container( row = 1 column = 1 ).
    go_container_alv = go_splitter->get_container( row = 2 column = 1 ).

    " Build Header & Logo
    CREATE OBJECT go_dyndoc
      EXPORTING
        style = 'ALV_GRID'.

    CALL METHOD go_dyndoc->add_text
      EXPORTING
        text      = 'Purchasing Info Records Details'
        sap_style = cl_dd_document=>heading.

    CALL METHOD go_dyndoc->new_line.

    " logo name
    CALL METHOD go_dyndoc->add_picture
      EXPORTING
        picture_id = 'Z026_SAP_LOGO1'.

    CALL METHOD go_dyndoc->display_document
      EXPORTING
        parent = go_container_top.

    " ALV in container
    CREATE OBJECT go_alv
      EXPORTING
        i_parent = go_container_alv.

    PERFORM build_fcat.

    " Alternately shaded rows and auto column width
    wa_layout-zebra      = 'X'.
    wa_layout-cwidth_opt = 'X'.

    CALL METHOD go_alv->set_table_for_first_display
      EXPORTING
        is_layout       = wa_layout
      CHANGING
        it_outtab       = it_final
        it_fieldcatalog = it_fcat.
  ENDIF.
ENDMODULE.

*&---------------------------------------------------------------------*
*& Module USER_COMMAND_0100 INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.

*&---------------------------------------------------------------------*
*& Form CALL_ADOBE_FORM
*&---------------------------------------------------------------------*
FORM call_adobe_form.
  DATA: fm_name            TYPE rs38l_fnam,
        fp_docparams       TYPE sfpdocparams,
        fp_outputparams    TYPE sfpoutputparams,
        it_vendorwise_eina TYPE z6829892_tt_eina,
        wa_vendorwise_eina TYPE z6829892_s_eina,
        wa_vendor_lfa1     TYPE z6829892_lfa1.

  " Job Open
  fp_outputparams-preview = 'X'.
  fp_outputparams-nodialog = 'X'. "hides the popup window for physical printing

  CALL FUNCTION 'FP_JOB_OPEN'
    CHANGING
      ie_outputparams = fp_outputparams
    EXCEPTIONS
      cancel          = 1
      usage_error     = 2
      system_error    = 3
      internal_error  = 4
      OTHERS          = 5.
  IF sy-subrc <> 0.
    MESSAGE 'Error opening Adobe Form Job' TYPE 'E'.
  ENDIF.

  CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
    EXPORTING
      i_name     = 'Z6829892_VENDOR_FORM'
    IMPORTING
      e_funcname = fm_name.

  " Group Data Vendor-wise
  SORT it_eina BY lifnr.

  LOOP AT it_eina INTO wa_eina.
    " Move local EINA data to DDIC structure and append to ITAB
    CLEAR wa_vendorwise_eina.
    MOVE-CORRESPONDING wa_eina TO wa_vendorwise_eina.
    APPEND wa_vendorwise_eina TO it_vendorwise_eina.

    " At the end of each Vendor, read header and call the form
    AT END OF lifnr.

      " Safely read local LFA1 data into DDIC LFA1 structure
      READ TABLE it_lfa1 INTO wa_lfa1 WITH KEY lifnr = wa_eina-lifnr BINARY SEARCH.
      IF sy-subrc = 0.
        CLEAR wa_vendor_lfa1.
        MOVE-CORRESPONDING wa_lfa1 TO wa_vendor_lfa1.
      ENDIF.

      " Call the Generated Adobe Form FM
      CALL FUNCTION fm_name
        EXPORTING
          /1bcdwb/docparams = fp_docparams
          wa_lfa1           = wa_vendor_lfa1
          it_eina           = it_vendorwise_eina
        EXCEPTIONS
          usage_error       = 1
          system_error      = 2
          internal_error    = 3
          OTHERS            = 4.

      " Clear the intermediate structures for the next Vendor
      CLEAR: wa_vendor_lfa1, it_vendorwise_eina.
    ENDAT.
  ENDLOOP.

  CALL FUNCTION 'FP_JOB_CLOSE'
    EXCEPTIONS
      usage_error    = 1
      system_error   = 2
      internal_error = 3
      OTHERS         = 4.

  MESSAGE 'Adobe Form logic executed successfully.' TYPE 'S'.
ENDFORM.
