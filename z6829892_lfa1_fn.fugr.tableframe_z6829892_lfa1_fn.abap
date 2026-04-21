*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_Z6829892_LFA1_FN
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_Z6829892_LFA1_FN   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
