@AbapCatalog.sqlViewName: 'ZV_BOOK_KLFT'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Booking'
define view Z_I_BOOKING_KLFT
  as select from ztb_booking_klft
  composition [0..*] of z_i_booksup_klft  as _Booksup
  association        to parent Z_I_TRAVEL_KLFT   as _Travel on $projection.TravelID = _Travel.TravelID
  association [1..1] to /DMO/I_Customer   as _Customer      on $projection.CustomerID = _Customer.CustomerID
  association [1..1] to /DMO/I_Carrier    as _Carrier       on $projection.CarrierID = _Carrier.AirlineID
  association [1..*] to /DMO/I_Connection as _Connection    on $projection.ConnectionID = _Connection.ConnectionID
{
  key travel_id       as TravelID,
  key booking_id      as BookingID,
      booking_date    as BookingDate,
      customer_id     as CustomerID,
      carrier_id      as CarrierID,
      connection_id   as ConnectionID,
      flight_date     as FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      flight_price    as FlightPrice,
      @Semantics.currencyCode: true
      currency_code   as CurrencyCode,
      booking_status  as BookingStatus,
      last_changed_at as LastChangedAt,
      _Travel,
      _Booksup,
      _Customer,
      _Carrier,
      _Connection
}
