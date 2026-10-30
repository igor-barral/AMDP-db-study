@EndUserText.label: 'Customer totals (table function)'
@ClientHandling.type: #CLIENT_DEPENDENT
@ClientHandling.algorithm: #SESSION_VARIABLE
define table function ZI_IB_CustTotalsTF
  with parameters
    p_min_total : abap.dec(15,2)
  returns
  {
    client       : abap.clnt;
    customer_id  : abap.char(10);
    order_count  : abap.int4;
    total_amount : abap.dec(15,2);
    last_order   : abap.dats;
  }
  implemented by method zcl_ib_amdp_customer_tf=>get_customer_totals;
