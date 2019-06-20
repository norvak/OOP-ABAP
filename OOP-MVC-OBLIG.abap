TYPE-POOLS : abap.

TABLES: VBAK, VBAP, MAKT, KNA1, VBUK.

DATA : l_AUDAT TYPE VBAK-AUDAT.

* Create selection screen
 SELECTION-SCREEN BEGIN OF BLOCK b1
                       WITH FRAME TITLE title.
  PARAMETERS:  F_VKORG TYPE VBAK-VKORG OBLIGATORY.
  PARAMETERS:  F_VTWEG TYPE VBAK-VTWEG OBLIGATORY.
  PARAMETERS:  F_SPART TYPE VBAK-SPART  OBLIGATORY.
  PARAMETERS:  F_VBELN TYPE VBAK-VBELN OBLIGATORY.
  PARAMETERS:  F_KUNNR TYPE VBAK-KUNNR OBLIGATORY.
  SELECT-OPTIONS: F_AUDAT FOR  l_AUDAT.
SELECTION-SCREEN END OF BLOCK b1.

* Create selection screen class
CLASS cl_sel DEFINITION FINAL.

  PUBLIC SECTION.

  TYPES: T_AUDAT TYPE RANGE OF AUDAT.
  DATA : S_AUDAT TYPE T_AUDAT.
  DATA : S_VKORG TYPE VBAK-VKORG.
  DATA : S_VTWEG TYPE VBAK-VTWEG.
  DATA : S_SPART TYPE VBAK-SPART.
  DATA : S_VBELN TYPE VBAK-VBELN.
  DATA : S_KUNNR TYPE VBAK-KUNNR.

  METHODS : get_screen IMPORTING V_VKORG TYPE VBAK-VKORG
                                 V_VTWEG TYPE VBAK-VTWEG
                                 V_SPART TYPE VBAK-SPART
                                 V_VBELN TYPE VBAK-VBELN
                                 V_KUNNR TYPE VBAK-KUNNR
                                 V_AUDAT TYPE T_AUDAT.

ENDCLASS.
*&---------------------------------------------------------------------*
*&       CLASS (IMPLEMENTATION)  SEL
*&---------------------------------------------------------------------*
*        Get Selection Screen Information
*----------------------------------------------------------------------*
CLASS cl_sel IMPLEMENTATION.

  METHOD get_screen.
    me->S_VKORG  = V_VKORG.
    me->S_VTWEG  = V_VTWEG.
    me->S_SPART  = V_SPART.
    me->S_VBELN  = V_VBELN.
    me->S_KUNNR  = V_KUNNR.
    me->S_AUDAT = V_AUDAT[].
  ENDMETHOD.

ENDCLASS.

* Create DATA MODEL to  fetch  recordes
CLASS cl_fetch DEFINITION.

  PUBLIC SECTION .
    DATA : sel_obj TYPE REF TO cl_sel.
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
          T_NETWR2 TYPE VBAP-NETWR,
          T_GBSTK  TYPE VBUK-GBSTK,
        END OF IT_VBAK.

    DATA : WA_VBAK TYPE IT_VBAK,
            T_VBAK TYPE STANDARD TABLE OF IT_VBAK.


    METHODS constructor IMPORTING ref_sel TYPE REF TO cl_sel.
    METHODS : fetch_data.

ENDCLASS.
*&---------------------------------------------------------------------*
*&       CLASS (IMPLEMENTATION)  FETCH
*&---------------------------------------------------------------------*
*        Fetch Sales Info
*----------------------------------------------------------------------*
CLASS cl_fetch IMPLEMENTATION.

  METHOD constructor.
    me->sel_obj = ref_sel.
  ENDMETHOD .

  METHOD fetch_data.

   SELECT VBAK~VBELN VBAK~VKORG VBAK~VTWEG VBAK~SPART VBAK~AUDAT VBAK~KUNNR KNA1~NAME1 KNA1~NAME2
          VBAK~NETWR VBAP~POSNR VBAP~MATNR VBAP~ARKTX MAKT~MAKTX VBAP~KWMENG VBAK~NETWR VBUK~GBSTK
    FROM VBAK INNER JOIN VBAP ON VBAK~VBELN = VBAP~VBELN
    INNER JOIN MAKT ON VBAP~MATNR = MAKT~MATNR
    INNER JOIN KNA1 ON KNA1~KUNNR = VBAK~KUNNR
    INNER JOIN VBUK ON VBAK~VBELN = VBUK~VBELN
    INTO TABLE  me->T_VBAK WHERE VBAK~AUDAT  IN me->sel_obj->S_AUDAT
    AND VBAK~VTWEG EQ me->sel_obj->S_VTWEG
    AND VBAK~SPART EQ me->sel_obj->S_SPART
    AND VBAK~VBELN EQ me->sel_obj->S_VBELN
    AND VBAK~KUNNR EQ me->sel_obj->S_KUNNR
    AND VBAK~VKORG EQ me->sel_obj->S_VKORG.

    LOOP AT me->T_VBAK INTO me->WA_VBAK.
       CONCATENATE me->WA_VBAK-T_NAME1 me->WA_VBAK-T_NAME2 INTO me->WA_VBAK-T_NAME1 SEPARATED BY space.
       MODIFY me->T_VBAK FROM me->WA_VBAK.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

* Display data class
CLASS cl_alv DEFINITION.

  PUBLIC SECTION .
    DATA : fetch_obj  TYPE REF TO cl_fetch .
    METHODS : constructor IMPORTING ref_fetch TYPE REF TO cl_fetch.
    METHODS : display_alv .
  PRIVATE SECTION.
   METHODS: set_pf_status CHANGING  co_alv    TYPE REF TO cl_salv_table.
*   Set Top of page
   METHODS: set_top_of_page CHANGING co_alv   TYPE REF TO cl_salv_table.
*   Set End of page
   METHODS: set_end_of_page CHANGING co_alv   TYPE REF TO cl_salv_table.

ENDCLASS.
*&---------------------------------------------------------------------*
*&       Class (Implementation)  CL_ALV
*&---------------------------------------------------------------------*
*        Display the Output
*----------------------------------------------------------------------*
CLASS cl_alv IMPLEMENTATION.

  METHOD constructor.
    me->fetch_obj = ref_fetch.
  ENDMETHOD.

  METHOD display_alv.

    DATA: lx_msg TYPE REF TO cx_salv_msg.
    DATA: o_alv TYPE REF TO cl_salv_table.

    TRY.
        cl_salv_table=>factory(
          IMPORTING
            r_salv_table = o_alv
          CHANGING
            t_table      = me->fetch_obj->T_VBAK ).


**   Setting up the PF-Status
        CALL METHOD set_pf_status
          CHANGING
          co_alv = o_alv.
**   Calling the top of page method
        CALL METHOD me->set_top_of_page
          CHANGING
            co_alv = o_alv.
**   Calling the End of Page method
        CALL METHOD me->set_end_of_page
          CHANGING
            co_alv = o_alv.

      CATCH cx_salv_msg INTO lx_msg.
    ENDTRY.

    o_alv->display( ).

  ENDMETHOD.

  METHOD set_pf_status.
    DATA: lo_functions TYPE REF TO cl_salv_functions_list.
    lo_functions = co_alv->get_functions( ).
    lo_functions->set_default( abap_true ).
  ENDMETHOD.

  METHOD set_top_of_page.

    DATA: lo_header  TYPE REF TO cl_salv_form_layout_grid,
          lo_h_label TYPE REF TO cl_salv_form_label,
          lo_h_flow  TYPE REF TO cl_salv_form_layout_flow.

**   header object
    CREATE OBJECT lo_header.
**   To create a Lable or Flow we have to specify the target
*     row and column number where we need to set up the output
*     text.
**   information in Bold
    lo_h_label = lo_header->create_label( row = 1 column = 1 ).
    lo_h_label->set_text( 'Header in Bold' ).
**   information in tabular format
    lo_h_flow = lo_header->create_flow( row = 2  column = 1 ).
    lo_h_flow->create_text( text = 'This is text of flow' ).
*    lo_h_flow = lo_header->create_flow( row = 3  column = 1 ).
    lo_h_flow->create_text( text = 'Number of Records in the output' ).

    lo_h_flow = lo_header->create_flow( row = 3  column = 2 ).
    lo_h_flow->create_text( text = 20 ).
**   set the top of list using the header for Online.
    co_alv->set_top_of_list( lo_header ).
**   set the top of list using the header for Print.
    co_alv->set_top_of_list_print( lo_header ).

  ENDMETHOD.

  METHOD set_end_of_page.

    DATA: lo_footer  TYPE REF TO cl_salv_form_layout_grid,
          lo_f_label TYPE REF TO cl_salv_form_label,
          lo_f_flow  TYPE REF TO cl_salv_form_layout_flow.

**   footer object
    CREATE OBJECT lo_footer.
**   information in bold
    lo_f_label = lo_footer->create_label( row = 1 column = 1 ).
    lo_f_label->set_text( 'Footer .. here it goes' ).

**   tabular information
    lo_f_flow = lo_footer->create_flow( row = 2  column = 1 ).
    lo_f_flow->create_text( text = 'This is text of flow in footer' ).

    lo_f_flow = lo_footer->create_flow( row = 3  column = 1 ).
    lo_f_flow->create_text( text = 'Footer number' ).

    lo_f_flow = lo_footer->create_flow( row = 3  column = 2 ).
    lo_f_flow->create_text( text = 1 ).

**   Online footer
    co_alv->set_end_of_list( lo_footer ).

**   Footer in print
    co_alv->set_end_of_list_print( lo_footer ).

  ENDMETHOD.

ENDCLASS.

* Declare TYPE REF TO class objects
DATA: o_sel     TYPE REF TO cl_sel,
      o_fetch   TYPE REF TO cl_fetch,
      o_display TYPE REF TO cl_alv.

INITIALIZATION.
  title = 'Selection'.
  
* Creating Objects of the Class
  CREATE OBJECT : o_sel,
                  o_fetch   EXPORTING ref_sel = o_sel, " ref_sel is in Constructor
                  o_display EXPORTING ref_fetch = o_fetch. " ref_fetch is in Constructor

START-OF-SELECTION .
* Import screen data to class screen
  o_sel->get_screen( EXPORTING V_VKORG = F_VKORG
                               V_VTWEG = F_VTWEG
                               V_SPART = F_SPART
                               V_VBELN = F_VBELN
                               V_KUNNR = F_KUNNR
                               V_AUDAT = F_AUDAT[] ).

* Call fetch data to fetch the records
  o_fetch->fetch_data( ).

END-OF-SELECTION .
* Display data
  o_display->display_alv( ).
  