"! AMDP procedure: ranking de clientes por faturamento, calculado no HANA.
"! Mostra um método de instância chamado do ABAP como qualquer outro.
CLASS zcl_ib_amdp_ranking DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_amdp_marker_hdb.

    TYPES:
      BEGIN OF ty_ranked_customer,
        customer_id   TYPE zib_amdp_order-customer_id,
        total_amount  TYPE zib_amdp_order-amount,
        rank_position TYPE i,
      END OF ty_ranked_customer,
      tt_ranked_customer TYPE STANDARD TABLE OF ty_ranked_customer WITH EMPTY KEY.

    "! Regras de assinatura de AMDP: parâmetros sempre por VALUE,
    "! sem RETURNING, tipos elementares ou tabelas de tipos elementares.
    METHODS get_top_customers
      IMPORTING VALUE(iv_top)     TYPE i
      EXPORTING VALUE(et_ranking) TYPE tt_ranked_customer.
ENDCLASS.


CLASS zcl_ib_amdp_ranking IMPLEMENTATION.

  METHOD get_top_customers
    BY DATABASE PROCEDURE FOR HDB LANGUAGE SQLSCRIPT
    OPTIONS READ-ONLY
    USING zib_amdp_order.

    -- Passo 1: totais por cliente (variável de tabela).
    lt_totals = SELECT customer_id,
                       CAST( SUM(amount) AS DECIMAL(15,2) ) AS total_amount
                  FROM zib_amdp_order
                 WHERE client = SESSION_CONTEXT('CLIENT')
                 GROUP BY customer_id;

    -- Passo 2: ranking com função de janela.
    lt_ranked = SELECT customer_id,
                       total_amount,
                       CAST( RANK() OVER (ORDER BY total_amount DESC) AS INTEGER ) AS rank_position
                  FROM :lt_totals;

    -- Passo 3: filtro pelo ranking (não dá para filtrar a janela no mesmo SELECT).
    et_ranking = SELECT customer_id, total_amount, rank_position
                   FROM :lt_ranked
                  WHERE rank_position <= :iv_top
                  ORDER BY rank_position;
  ENDMETHOD.

ENDCLASS.
