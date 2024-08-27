@EndUserText.label: 'Vista de consumo - Travel Approval'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity Z_C_ATRAVEL_KLFT as projection on Z_I_TRAVEL_KLFT
{
key TravelID as TravelID,
AgencyID as AgencyID,
@ObjectModel.text.element: [ 'AgencyName' ]
_Agency.Name as AgencyName, 
CustomerID as CustomerID,
@ObjectModel.text.element: [ 'CustomerName' ]
_Customer.LastName as CustomerName, 
BeginDate as BeginDate,
EndDate as EndDate,
@Semantics.amount.currencyCode: 'CurrencyCode'
BookingFee as BookingFee,
@Semantics.amount.currencyCode: 'CurrencyCode'
TotalPrice as TotalPrice,
@Semantics.currencyCode: true 
CurrencyCode as CurrencyCode,
Description as Description,
OverallStatus as OverallStatus,
LastChangedAt as LastChangedAt,
/* Associations */ 
_Booking : redirected to composition child Z_C_ABOOKING_KLFT, 
_Customer, 
_Agency     

}
