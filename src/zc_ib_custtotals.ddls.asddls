@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Customer totals with tier'
define view entity ZC_IB_CustTotals
  with parameters
    p_min_total : abap.dec(15,2)
  as select from ZI_IB_CustTotalsTF( p_min_total: $parameters.p_min_total )
{
  key customer_id,
      order_count,
      total_amount,
      last_order,
      case
        when total_amount >= 10000 then 'A'
        when total_amount >= 1000  then 'B'
        else 'C'
      end as customer_tier
}
