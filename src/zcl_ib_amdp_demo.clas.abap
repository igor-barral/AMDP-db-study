"! Classe executável (F9 no ADT): popula a tabela de estudo, chama a
"! procedure AMDP e lê a CDS view entity que consome a table function.
CLASS zcl_ib_amdp_demo DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PRIVATE SECTION.
    METHODS seed_orders.
ENDCLASS.


CLASS zcl_ib_amdp_demo IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    seed_orders( ).

    " 1) Procedure AMDP: chamada como método ABAP comum.
    NEW zcl_ib_amdp_ranking( )->get_top_customers(
      EXPORTING iv_top     = 2
      IMPORTING et_ranking = DATA(ranking) ).
    out->write( name = `Top 2 customers (AMDP procedure)` data = ranking ).

    " 2) Table function consumida por CDS e lida com ABAP SQL.
    "    O mandante é tratado automaticamente pela CDS.
    SELECT FROM zc_ib_custtotals( p_min_total = 500 )
      FIELDS customer_id, order_count, total_amount, last_order, customer_tier
      ORDER BY total_amount DESCENDING
      INTO TABLE @DATA(totals).
    out->write( name = `Customers with total >= 500 (CDS over table function)` data = totals ).
  ENDMETHOD.


  METHOD seed_orders.
    DATA orders TYPE STANDARD TABLE OF zib_amdp_order WITH EMPTY KEY.

    orders = VALUE #(
      ( order_id = '0000000001' customer_id = 'C001' order_date = '20260901' amount = '12000.00' )
      ( order_id = '0000000002' customer_id = 'C001' order_date = '20260910' amount = '800.00' )
      ( order_id = '0000000003' customer_id = 'C002' order_date = '20260905' amount = '1500.00' )
      ( order_id = '0000000004' customer_id = 'C003' order_date = '20260907' amount = '300.00' )
      ( order_id = '0000000005' customer_id = 'C003' order_date = '20260912' amount = '350.00' )
      ( order_id = '0000000006' customer_id = 'C004' order_date = '20260915' amount = '90.00' ) ).

    DELETE FROM zib_amdp_order.
    INSERT zib_amdp_order FROM TABLE @orders.
  ENDMETHOD.

ENDCLASS.
