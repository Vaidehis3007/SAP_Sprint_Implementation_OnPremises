*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: Z6829892_MAKT...................................*
DATA:  BEGIN OF STATUS_Z6829892_MAKT                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_Z6829892_MAKT                 .
CONTROLS: TCTRL_Z6829892_MAKT
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *Z6829892_MAKT                 .
TABLES: Z6829892_MAKT                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
