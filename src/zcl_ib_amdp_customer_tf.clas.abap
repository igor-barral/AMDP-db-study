"! Implementação AMDP da CDS table function ZI_IB_CustTotalsTF.
"! O método é estático e declarado com FOR TABLE FUNCTION: a assinatura
"! (parâmetros e resultado) vem da definição CDS, não do ABAP.
CLASS zcl_ib_amdp_customer_tf DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_amdp_marker_hdb.

    CLASS-METHODS get_customer_totals FOR TABLE FUNCTION zi_ib_custtotalstf.
ENDCLASS.


CLASS zcl_ib_amdp_customer_tf IMPLEMENTATION.

  METHOD get_customer_totals
    BY DATABASE FUNCTION FOR HDB LANGUAGE SQLSCRIPT
    OPTIONS READ-ONLY
    USING zib_amdp_order.

    -- Daqui até ENDMETHOD o código é SQLScript, executado no HANA.
    -- Comentários usam "--" (SQL), não aspas (ABAP).
    -- O filtro de mandante é responsabilidade do AMDP: a table function é
    -- client-dependent com algoritmo SESSION_VARIABLE, então lemos o
    -- mandante da sessão.
    lt_orders = SELECT client, customer_id, order_date, amount
                  FROM zib_amdp_order
                 WHERE client = SESSION_CONTEXT('CLIENT');

    -- A ordem e os tipos das colunas devem bater com o "returns" da CDS.
    RETURN SELECT client,
                  customer_id,
                  CAST( COUNT(*) AS INTEGER )          AS order_count,
                  CAST( SUM(amount) AS DECIMAL(15,2) ) AS total_amount,
                  MAX(order_date)                      AS last_order
             FROM :lt_orders
            GROUP BY client, customer_id
           HAVING SUM(amount) >= :p_min_total;
  ENDMETHOD.

ENDCLASS.
