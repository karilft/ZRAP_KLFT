@EndUserText.label: 'Vista de consumo - Booking Approval'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity Z_C_ABOOKING_KLFT as projection on Z_I_BOOKING_KLFT
{
  key TravelId      as TravelID,
  key BookingId     as BookingID,
      BookingDate   as BookingDate,
      CustomerId    as CustomerID,
      CarrierId     as CarrierID,
      @ObjectModel.text.element: [ 'CarrierName' ]
      _Carrier.Name as CarrierName, 
      ConnectionId  as ConnectionID,
      FlightDate    as FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      FlightPrice   as FlightPrice,
      @Semantics.currencyCode: true
      CurrencyCode  as CurrencyCode,
      BookingStatus as BookingStatus,
      LastChangedAt as LastChangedAt,
      /* Associations */
      _Travel : redirected to parent Z_C_ATRAVEL_KLFT,  
      _Customer,
      _Carrier
}
