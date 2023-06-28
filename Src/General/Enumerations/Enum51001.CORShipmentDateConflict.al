enum 51001 "COR Shipment Date Conflict"
{
    Extensible = true;

    value(0; "")
    {
        Caption = ' ';
    }
    value(1; noConflict)
    {
        Caption = 'noConflict';
    }
    value(2; ShipmentDateTooEarly)
    {
        Caption = 'ShipmentDateTooEarly';
    }
    value(3; earlierShipmentPossible)
    {
        Caption = 'earlierShipmentPossible';
    }
}
