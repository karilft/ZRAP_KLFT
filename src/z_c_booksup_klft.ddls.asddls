@EndUserText.label: 'Vista de consumo - BookSup'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity Z_C_BOOKSUP_KLFT as projection on z_i_booksup_klft
{
    key TravelID as TravelID,
    key BookingID as BookingID,
    key BookingSupplementID as BookingSupplementID,
    _SuppText.Description as SuppDescription : localized, 
    @Semantics.amount.currencyCode: 'CurrencyCode'
    Price as Price, 
    @Semantics.currencyCode: true
    CurrencyCode as CurrencyCode,
    /* Associations */
    _Booking : redirected to parent Z_C_BOOKING_KLFT,  
    _Product,
    _SuppText,
    _Travel : redirected to Z_C_TRAVEL_KLFT
}
