CLASS lcl_buffer DEFINITION.
  PUBLIC SECTION.
    " Buffer to hold data between the MODIFY and SAVE phases
    CLASS-DATA: mt_create TYPE TABLE OF z6829892_mat.
ENDCLASS.

CLASS lhc_Material DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE Material.
ENDCLASS.

CLASS lhc_Material IMPLEMENTATION.
  METHOD create.
    LOOP AT entities INTO DATA(ls_entity).
      " Move the UI data into our temporary memory buffer
      APPEND VALUE #( matnr = ls_entity-MaterialNumber
                      mbrsh = ls_entity-IndustrySector
                      mtart = ls_entity-MaterialType
                      maktx = ls_entity-MaterialDescription
                      meins = ls_entity-BaseUnit ) TO lcl_buffer=>mt_create.

      " Tell RAP we mapped it successfully
      APPEND VALUE #( %cid = ls_entity-%cid materialnumber = ls_entity-MaterialNumber ) TO mapped-material.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

CLASS lsc_ZI_MAT_6829892 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    " FIXED: Redefining the correct SAVE method required for Unmanaged Save
    METHODS save REDEFINITION.
ENDCLASS.

CLASS lsc_ZI_MAT_6829892 IMPLEMENTATION.
  METHOD save.
    DATA: ls_headdata    TYPE bapimathead,
          ls_clientdata  TYPE bapi_mara,
          ls_clientdatax TYPE bapi_marax,
          lt_matdesc     TYPE TABLE OF bapi_makt,
          ls_return      TYPE bapiret2.

    " Loop through whatever is sitting in the memory buffer
    LOOP AT lcl_buffer=>mt_create INTO DATA(ls_buffer).

      ls_headdata-material   = ls_buffer-matnr.
      ls_headdata-ind_sector = ls_buffer-mbrsh.
      ls_headdata-matl_type  = ls_buffer-mtart.
      ls_headdata-basic_view = abap_true.

      ls_clientdata-base_uom  = ls_buffer-meins.
      ls_clientdatax-base_uom = abap_true.

      APPEND VALUE #( langu     = sy-langu
                      matl_desc = ls_buffer-maktx ) TO lt_matdesc.

      " Call the BAPI to save the material
      CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
        EXPORTING
          headdata            = ls_headdata
          clientdata          = ls_clientdata
          clientdatax         = ls_clientdatax
        IMPORTING
          return              = ls_return
        TABLES
          materialdescription = lt_matdesc.

      CLEAR: ls_headdata, ls_clientdata, ls_clientdatax, lt_matdesc, ls_return.
    ENDLOOP.

    " Clear the buffer for the next transaction
    CLEAR lcl_buffer=>mt_create.
  ENDMETHOD.
ENDCLASS.
