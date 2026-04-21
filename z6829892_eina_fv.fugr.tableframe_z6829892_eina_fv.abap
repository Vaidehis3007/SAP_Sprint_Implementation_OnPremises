*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_Z6829892_EINA_FV
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_Z6829892_EINA_FV   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
