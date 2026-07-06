REPORT z_listofusers.


TYPES: BEGIN OF ty_usr02,
         bname TYPE usr02-bname,
         ustyp TYPE usr02-ustyp,
         class TYPE usr02-class,
         accnt TYPE usr02-accnt,
         trdat TYPE usr02-trdat,
         ltime TYPE usr02-ltime,
       END OF ty_usr02.

DATA: lt_users TYPE STANDARD TABLE OF ty_usr02.

DATA: lr_events TYPE REF TO cl_salv_events_table.


CLASS lcl_alv DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      on_link_click
        FOR EVENT double_click OF cl_salv_events_table
        IMPORTING
          row
          column  .
ENDCLASS.


CLASS lcl_alv IMPLEMENTATION.
  METHOD on_link_click.
    DATA: ls_user TYPE ty_usr02.

    READ TABLE lt_users INTO ls_user INDEX row.
    IF sy-subrc = 0.
      SET PARAMETER ID 'XUS' FIELD ls_user-bname.
      CALL TRANSACTION 'SU01' AND SKIP FIRST SCREEN.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.

  SELECT bname ustyp class  accnt trdat ltime FROM usr02 INTO TABLE lt_users
   where trdat ne  ' '  .
    .

  DATA: lr_alv TYPE REF TO cl_salv_table.

  CALL METHOD cl_salv_table=>factory
    IMPORTING
      r_salv_table = lr_alv
    CHANGING
      t_table      = lt_users.


  DATA: lr_columns TYPE REF TO cl_salv_columns_table.

  lr_columns = lr_alv->get_columns( ).


  DATA: ls_column TYPE REF TO cl_salv_column_table.
  TRY.
      ls_column ?= lr_columns->get_column( 'BNAME' ).

  ENDTRY.

  TRY.
      ls_column ?= lr_columns->get_column( 'USTYP' ).

  ENDTRY.

  TRY.
      ls_column ?= lr_columns->get_column( 'CLASS' ).

  ENDTRY.
  TRY.
      ls_column ?= lr_columns->get_column( 'ACCNT' ).
  ENDTRY.

  TRY.
      ls_column ?= lr_columns->get_column( 'TRDAT' ).
  ENDTRY.

  TRY.
      ls_column ?= lr_columns->get_column( 'LTIME' ).
  ENDTRY.


  lr_events = lr_alv->get_event( ).

  DATA(lo_lcl) = NEW lcl_alv( ).


  SET HANDLER lo_lcl->on_link_click FOR lr_events.



  lr_alv->display( ).
