@AbapCatalog.sqlViewName: 'ZV_BOOKSUP_KL'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Booking Sup'
define view z_i_booksup_klft
  as select from ztb_booksuppl_kl
  association        to parent Z_I_BOOKING_KLFT as _Booking  on  $projection.TravelID  = _Booking.TravelID
                                                             and $projection.BookingID = _Booking.BookingID
  association [1..1] to Z_I_TRAVEL_KLFT         as _Travel   on  $projection.TravelID = _Travel.TravelID
  association [1..1] to /DMO/I_Supplement       as _Product  on  $projection.BookingSupplementID = _Product.SupplementID
  association [1..*] to /DMO/I_SupplementText   as _SuppText on  $projection.BookingSupplementID = _SuppText.SupplementID
{
  key travel_id as TravelID, 
  key booking_id as BookingID, 
  key booking_supplement_id as BookingSupplementID, 
      @Semantics.amount.currencyCode: 'CurrencyCode'
      price as Price, 
      @Semantics.currencyCode: true
      currency_code as CurrencyCode, 
      last_changed_at as LastChangedAt, 
      _Booking,
      _Travel,
      _Product,
      _SuppText
}
