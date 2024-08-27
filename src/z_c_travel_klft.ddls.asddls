@EndUserText.label: 'Vista de consumo - Travel'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity Z_C_TRAVEL_KLFT
  as projection on Z_I_TRAVEL_KLFT
{
  key     TravelID           as TravelID,
          @ObjectModel.text.element: [ 'AgencyName' ]
          AgencyID           as AgencyID,
          _Agency.Name       as AgencyName,
          @ObjectModel.text.element: [ 'CustomerName' ]
          CustomerID         as CustomerID,
          _Customer.LastName as CustomerName,
          BeginDate          as BeginDate,
          EndDate            as EndDate,
          @Semantics.amount.currencyCode: 'CurrencyCode'
          BookingFee         as BookingFee,
          @Semantics.amount.currencyCode: 'CurrencyCode'
          TotalPrice         as TotalPrice,
          @Semantics.currencyCode: true
          CurrencyCode       as CurrencyCode,
          Description        as Description,
          OverallStatus      as OverallStatus,
          LastChangedAt      as LastChangedAt,
          @Semantics.amount.currencyCode: 'CurrencyCode'
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ELEMENT_KLFT'
  virtual DiscountPrice : /dmo/total_price,
          /* Associations */
          _Agency,
          _Booking : redirected to composition child Z_C_BOOKING_KLFT,
          _Currency,
          _Customer

}
