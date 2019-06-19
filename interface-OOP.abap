INTERFACE employee.
  METHODS: add_employee
    IMPORTING im_no   TYPE i
              im_name TYPE string
              im_wage TYPE i.
ENDINTERFACE.

*******************************************************
* Super class CL_CompanyEmployees
*******************************************************

CLASS cl_company_employees DEFINITION.
  PUBLIC SECTION.
    INTERFACES employee.
    TYPES:
      BEGIN OF t_employee,
            no  TYPE i,
            name TYPE string,
            wage TYPE i,
     END OF t_employee.
    METHODS: constructor,
             display_employee_list,
             display_not_employees.
  PRIVATE SECTION.
    CLASS-DATA: i_employee_list TYPE TABLE OF t_employee,
                no_of_employees TYPE i.
ENDCLASS.

*-- CLASS CL_CompanyEmployees IMPLEMENTATION

CLASS cl_company_employees IMPLEMENTATION.
  METHOD constructor.
    no_of_employees = no_of_employees + 1. " INCREMENTA EL CONTADOR
  ENDMETHOD.
  METHOD employee~add_employee.
*   Adds a new employee to the list of employees
    DATA: l_employee TYPE t_employee.
    l_employee-no = im_no.
    l_employee-name = im_name.
    l_employee-wage = im_wage.
    APPEND l_employee TO i_employee_list.
  ENDMETHOD.
  METHOD display_employee_list.
*   Displays all employees and there wage
    DATA: l_employee TYPE t_employee.
    WRITE: / 'Lista de empleado'.
    WRITE: / '             nro    name         wage' COLOR 5.
    LOOP AT i_employee_list INTO l_employee.
      WRITE: / 'data', l_employee-no, l_employee-name, l_employee-wage.
    ENDLOOP.
  ENDMETHOD.
  METHOD display_not_employees.
*   Displays total number of employees
    SKIP 3.
    WRITE: / 'Total numero de empleados:' COLOR 5, no_of_employees.
  ENDMETHOD.
ENDCLASS.

*******************************************************
* Sub class CL_Blue_Collar_Employee
*******************************************************

CLASS cl_blue_collar_employee DEFINITION
          INHERITING FROM cl_company_employees.
  PUBLIC SECTION.
    METHODS:
        constructor
          IMPORTING im_no             TYPE i
                    im_name           TYPE string
                    im_hours          TYPE i
                    im_hourly_payment TYPE i,
         employee~add_employee REDEFINITION..
  PRIVATE SECTION.
    DATA:no             TYPE i,
         name           TYPE string,
         hours          TYPE i,
         hourly_payment TYPE i.
ENDCLASS.

*---- CLASS CL_Blue_Collar_Employee IMPLEMENTATION
CLASS cl_blue_collar_employee IMPLEMENTATION.
  METHOD constructor.
*   The superclass constructor method must be called from the subclass
*   constructor method
    CALL METHOD super->constructor.
    no = im_no.
    name = im_name.
    hours = im_hours.
    hourly_payment = im_hourly_payment.
  ENDMETHOD.
  METHOD employee~add_employee.
*   Calculate wage an call the superclass method add_employee to add
*   the employee to the employee list
    DATA: l_wage TYPE i.
    l_wage = hours * hourly_payment.
    CALL METHOD super->employee~add_employee
      EXPORTING im_no = no
                im_name = name
                im_wage = l_wage.
  ENDMETHOD.
ENDCLASS.

*******************************************************
* Sub class CL_White_Collar_Employee
*******************************************************
CLASS cl_white_collar_employee DEFINITION
    INHERITING FROM cl_company_employees.
  PUBLIC SECTION.
    METHODS:
        constructor
          IMPORTING im_no                 TYPE i
                    im_name               TYPE string
                    im_monthly_salary     TYPE i
                    im_monthly_deducations TYPE i,
         employee~add_employee REDEFINITION.
  PRIVATE SECTION.
    DATA:
      no                    TYPE i,
      name                  TYPE string,
      monthly_salary        TYPE i,
      monthly_deducations    TYPE i.
ENDCLASS.
*---- CLASS CL_White_Collar_Employee IMPLEMENTATION
CLASS cl_white_collar_employee IMPLEMENTATION.
  METHOD constructor.
*   The superclass constructor method must be called from the subclass
*   constructor method

    CALL METHOD super->constructor.
    no = im_no.
    name = im_name.
    monthly_salary = im_monthly_salary.
    monthly_deducations = im_monthly_deducations.
  ENDMETHOD.
  METHOD employee~add_employee.
*   Calculate wage an call the superclass method add_employee to add
*   the employee to the employee list
    DATA: l_wage TYPE i.
    l_wage = monthly_salary - monthly_deducations.
    CALL METHOD super->employee~add_employee
      EXPORTING im_no = no
                im_name = name
                im_wage = l_wage.
  ENDMETHOD.
ENDCLASS.

*******************************************************
* R E P O R T
*******************************************************
DATA:
* Object references
  blue_collar_employee1  TYPE REF TO cl_blue_collar_employee,
  white_collar_employee1 TYPE REF TO cl_white_collar_employee.
START-OF-SELECTION.
* Create blue_collar employee obeject
  CREATE OBJECT blue_collar_employee1
      EXPORTING im_no  = 1
                im_name  = 'jorge c.'
                im_hours = 30
                im_hourly_payment = 75.
* Add blue_collar employee to employee list
  CALL METHOD blue_collar_employee1->employee~add_employee
      EXPORTING im_no  = 1
                im_name  = 'jorge c.'
                im_wage = 0.
* Create whitecollar employee obeject
  CREATE OBJECT white_collar_employee1
      EXPORTING im_no  = 2
                im_name  = 'raquel r.'
                im_monthly_salary = 10000
                im_monthly_deducations = 2500.
* Add bluecollar employee to employee list
  CALL METHOD white_collar_employee1->employee~add_employee
      EXPORTING im_no  = 2
                im_name  = 'raquel r.'
                im_wage = 0.
* Display employee list and number of employees. Note that the result
* will be the same when called from white_collar_employee1 or
* blue_colarcollar_employee1, because the methods are defined
* as static (CLASS-METHODS)
  CALL METHOD white_collar_employee1->display_employee_list.
  CALL METHOD white_collar_employee1->display_not_employees.
  SKIP 4.
  CALL METHOD blue_collar_employee1->display_employee_list.
  CALL METHOD blue_collar_employee1->display_not_employees.