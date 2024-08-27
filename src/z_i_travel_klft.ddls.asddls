@AbapCatalog.sqlViewName: 'ZV_TRAVEL_KLFT'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Intreface - Travel'
define root view Z_I_TRAVEL_KLFT
  as select from ztb_travel_klft as _Travel
  composition [0..*] of Z_I_BOOKING_KLFT as _Booking
  association [0..1] to /DMO/I_Agency    as _Agency   on $projection.AgencyID = _Agency.AgencyID
  association [0..1] to /DMO/I_Customer  as _Customer on $projection.CustomerID = _Customer.CustomerID
  association [0..1] to I_Currency       as _Currency on $projection.CurrencyCode = _Currency.Currency
{
  key travel_id as TravelID, 
      agency_id as AgencyID, 
      _Agency.Name as AgencyName,
      customer_id as CustomerID, 
      _Customer.LastName as CustomerName, 
      begin_date as BeginDate, 
      end_date as EndDate, 
      @Semantics.amount.currencyCode: 'CurrencyCode'
      booking_fee as BookingFee, 
      @Semantics.amount.currencyCode: 'CurrencyCode'
      total_price as TotalPrice,
      @Semantics.currencyCode: true
      currency_code as CurrencyCode, 
      description as Description,
      overall_status as OverallStatus, 
      @Semantics.user.createdBy: true
      created_by as CreatedBy, 
      @Semantics.systemDateTime.createdAt: true
      created_at as CreatedAt, 
      @Semantics.user.lastChangedBy: true
      last_changed_by as LastChangedBy, 
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at as LastChangedAt, 
      _Booking,
      _Agency,
      _Customer,
      _Currency
}
