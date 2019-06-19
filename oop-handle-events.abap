TYPE-POOLS : abap.

TABLES: VBAK, VBAP, MAKT, KNA1, VBUK, MARA.

CLASS lcl_report DEFINITION DEFERRED.

TYPES: BEGIN OF IT_VBAK,
          T_VBELN  TYPE VBAK-VBELN,
          T_VKORG  TYPE VBAK-VKORG,
          T_VTWEG  TYPE VBAK-VTWEG,
          T_SPART  TYPE VBAK-SPART,
          T_AUDAT  TYPE VBAK-AUDAT,
          T_KUNNR  TYPE VBAK-KUNNR,
          T_NAME1  TYPE KNA1-NAME1,
          T_NAME2  TYPE KNA1-NAME2,
          T_NETWR  TYPE VBAK-NETWR,
          T_POSNR  TYPE VBAP-POSNR,
          T_MATNR  TYPE VBAP-MATNR,
          T_ARKTX  TYPE VBAP-ARKTX,
          T_MAKTX  TYPE MAKT-MAKTX,
          T_KWMENG TYPE VBAP-KWMENG,
          T_NETWR2  TYPE VBAP-NETWR,
          T_GBSTK  TYPE VBUK-GBSTK,
        END OF IT_VBAK.

DATA: gr_handle_events TYPE REF TO lcl_report,
      WA_VBAK TYPE IT_VBAK,
      T_VBAK TYPE STANDARD TABLE OF IT_VBAK.

** CLASS lcl_report DEFINITION
CLASS lcl_report DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_double_click FOR EVENT double_click OF cl_salv_events_table
        IMPORTING row column.
ENDCLASS.                    "lcl_report DEFINITION

** CLASS lcl_report IMPLEMENTATION
CLASS lcl_report IMPLEMENTATION.
  METHOD on_double_click.
    DATA ls_IT_VBAK TYPE IT_VBAK.
    READ TABLE T_VBAK
    INTO ls_IT_VBAK
    INDEX row.  "get selected row
    MESSAGE i000(0k) WITH 'Fila' row ls_IT_VBAK-T_NAME1  ls_IT_VBAK-T_NETWR. "#EC NOTEXT
  ENDMETHOD.                    "on_double_click
ENDCLASS.                    "lcl_report IMPLEMENTATION

START-OF-SELECTION.
** Select data
   SELECT VBAK~VBELN VBAK~VKORG VBAK~VTWEG VBAK~SPART VBAK~AUDAT VBAK~KUNNR KNA1~NAME1 KNA1~NAME2
       VBAK~NETWR VBAP~POSNR VBAP~MATNR VBAP~ARKTX MAKT~MAKTX VBAP~KWMENG VBAK~NETWR VBUK~GBSTK
    FROM VBAK INNER JOIN VBAP ON VBAK~VBELN = VBAP~VBELN
    INNER JOIN MAKT ON VBAP~MATNR = MAKT~MATNR
    INNER JOIN KNA1 ON KNA1~KUNNR = VBAK~KUNNR
    INNER JOIN VBUK ON VBAK~VBELN = VBUK~VBELN
    INTO TABLE  T_VBAK.

    LOOP AT T_VBAK INTO WA_VBAK.
       CONCATENATE WA_VBAK-T_NAME1 WA_VBAK-T_NAME2 INTO WA_VBAK-T_NAME1 SEPARATED BY space.
       MODIFY T_VBAK FROM WA_VBAK.
    ENDLOOP.
** Create Instance
  DATA: gr_table  TYPE REF TO cl_salv_table.

  CALL METHOD cl_salv_table=>factory
    IMPORTING
      r_salv_table = gr_table
    CHANGING
      t_table      = T_VBAK.

** Enable Generic ALV functions
  DATA: gr_functions TYPE REF TO cl_salv_functions_list.
  gr_functions = gr_table->get_functions( ).
  gr_functions->set_default( ).
* gr_functions->set_all( ).

** register to double click event
  DATA: lr_events TYPE REF TO cl_salv_events_table.

  lr_events = gr_table->get_event( ).
  CREATE OBJECT gr_handle_events.
  SET HANDLER gr_handle_events->on_double_click FOR lr_events.

** Display table
  gr_table->display( ).