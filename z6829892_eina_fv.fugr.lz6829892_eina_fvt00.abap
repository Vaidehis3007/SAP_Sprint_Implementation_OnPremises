*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: Z6829892_EINA...................................*
DATA:  BEGIN OF STATUS_Z6829892_EINA                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_Z6829892_EINA                 .
CONTROLS: TCTRL_Z6829892_EINA
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *Z6829892_EINA                 .
TABLES: Z6829892_EINA                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
