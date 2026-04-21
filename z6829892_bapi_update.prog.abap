*&---------------------------------------------------------------------*
*& Report z6829892_bapi_update
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z6829892_bapi_update.

*----------------------------------------------------------------------*
* 1. The UI Screen (Mandatory Fields)
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_matnr TYPE matnr OBLIGATORY,       " Material Number
              p_mbrsh TYPE mbrsh OBLIGATORY,       " Industry Sector (e.g., M)
              p_mtart TYPE mtart OBLIGATORY,       " Material Type (e.g., ROH)
              p_maktx TYPE maktx OBLIGATORY,       " Description
              p_meins TYPE meins OBLIGATORY.       " Base Unit (e.g., EA)
SELECTION-SCREEN END OF BLOCK b1.

*----------------------------------------------------------------------*
* 2. Triggering the RAP Unmanaged Scenario via EML
*----------------------------------------------------------------------*
START-OF-SELECTION.

  MODIFY ENTITIES OF ZI_MAT_6829892
    ENTITY Material
    CREATE SET FIELDS WITH VALUE #( (
      %cid                = 'MyNewMaterial_1'
      MaterialNumber      = p_matnr
      IndustrySector      = p_mbrsh
      MaterialType        = p_mtart
      MaterialDescription = p_maktx
      BaseUnit            = p_meins
    ) )
    MAPPED DATA(ls_mapped)
    FAILED DATA(ls_failed)
    REPORTED DATA(ls_reported).

  COMMIT ENTITIES.

*----------------------------------------------------------------------*
* 3. Display Success or Error to the User
*----------------------------------------------------------------------*
  IF ls_failed IS NOT INITIAL.
    WRITE: / 'ERROR: Material could not be created!'.
    WRITE: / '--------------------------------------'.
    LOOP AT ls_reported-material INTO DATA(ls_msg).
      WRITE: / ls_msg-%msg->if_message~get_text( ).
    ENDLOOP.
  ELSE.
    WRITE: / 'SUCCESS!'.
    WRITE: / '--------------------------------------'.
    WRITE: / 'Material', p_matnr, 'was successfully created using RAP & BAPI_MATERIAL_SAVEDATA.'.
  ENDIF.
