**----------------------------------------------------------------------
* Definition of class LCL_SUM_PADRE , parent class
* ADD METODO SUMA IMPORT VAR1, VAR2 AND EXPORT VAR3
* ADD CLASS METHODS STATIC: SUMA_STATIC
*----------------------------------------------------------------------
CLASS LCL_SUM_PADRE DEFINITION.
  PUBLIC SECTION.
    DATA : ATTR_SUM TYPE INTEGER.
    METHODS: SUMA IMPORTING var1 TYPE integer
                            var2 TYPE integer
          EXPORTING var3 TYPE integer.

    CLASS-METHODS : SUMA_STATIC IMPORTING var1 TYPE integer
                                          var2 TYPE integer
          EXPORTING var3 TYPE integer.
ENDCLASS.                    "LCL_SUM_PADRE Definition
*
*----------------------------------------------------------------------*
* Implementation of class SUMA
*----------------------------------------------------------------------*
CLASS LCL_SUM_PADRE IMPLEMENTATION.
  METHOD SUMA.
    var3 = var1 + var2.
  ENDMETHOD.
  METHOD SUMA_STATIC.
    var3 = var1 + var2.
  ENDMETHOD.
ENDCLASS.                    "LCL_SUM_PADRE implementation
*
*----------------------------------------------------------------------*
* Definition of CL_SUM_HIJO , sub class
*----------------------------------------------------------------------*
CLASS CL_SUM_HIJO DEFINITION INHERITING FROM LCL_SUM_PADRE.
  PUBLIC SECTION.
    METHODS: SUMA REDEFINITION ."can't change the signature of method
    "can't redefine static methods
*   CLASS-METHODS : static_sum REDEFINITION .
ENDCLASS.                    "CL_SUM_HIJO implementation
*
*----------------------------------------------------------------------*
* Implementation of SUM_SUBCLASS
*----------------------------------------------------------------------*
CLASS CL_SUM_HIJO IMPLEMENTATION.
  METHOD SUMA.
    var3 = var1 + var2 + 10.
  ENDMETHOD.
ENDCLASS.
*
START-OF-SELECTION.

  DATA : p1 TYPE integer,
         p2 TYPE integer,
         ATTR_SUM TYPE integer.

  DATA: PADRE TYPE REF TO LCL_SUM_PADRE.
  CREATE OBJECT PADRE.

  p1 = 2. p2 = 5. ATTR_SUM = 0. " p1 and p2 add data static
  CALL METHOD : PADRE->SUMA " call to sum from super class
                 EXPORTING var1 = P1
                           var2 = P2
                 IMPORTING var3 = ATTR_SUM.
  PADRE->ATTR_SUM = ATTR_SUM.
  WRITE /: 'METODO DE SUMA PADRE :',PADRE->ATTR_SUM.

   p1 = 6. p2 = 2. ATTR_SUM = 0. " p1 and p2 add data static
   "call to static method SUMA_STATIC
  CALL METHOD : LCL_SUM_PADRE=>SUMA_STATIC " para llamar un metodo estatico de la clase es =>
                 EXPORTING var1 = P1
                           var2 = P2
                 IMPORTING var3 = ATTR_SUM.
  WRITE /: 'METODO SUMA ESTATICO  : ',ATTR_SUM.

  DATA: HIJO TYPE REF TO CL_SUM_HIJO. "call to sum in child class
  CREATE OBJECT HIJO.

   p1 = 0. p2 = 3. ATTR_SUM = 0. " si p1 y p2 no son inicializados entonces su valor sera el definido anteriormente
  CALL METHOD : HIJO->SUMA
                 EXPORTING var1 = P1
                           var2 = P2
                 IMPORTING var3 = ATTR_SUM.
  HIJO->ATTR_SUM = ATTR_SUM.
  WRITE /:'OBJETO METODO DE SUMA HIJO : ', HIJO->ATTR_SUM.

  " Runtime polymorphism, since obj_super stores obj_sub, the call
  "obj_super->v_sum automatically calls sum from sub class
  PADRE = HIJO.
  WRITE /: 'OBJETO METODO DE SUMA PADRE : ',PADRE->ATTR_SUM.