*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: Z6829892_LFA1...................................*
DATA:  BEGIN OF STATUS_Z6829892_LFA1                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_Z6829892_LFA1                 .
CONTROLS: TCTRL_Z6829892_LFA1
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *Z6829892_LFA1                 .
TABLES: Z6829892_LFA1                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
