enum 51002 "COR DSDS Priority Model"
{

    value(0; fixedBySalesLinePriority)
    {
        Caption = 'Fixed by Sales Line';
    }
    value(1; CalculatedByOrderDate)
    {
        Caption = 'Calculated by Order Date';
    }
    value(2; CalculatedByOrderNo)
    {
        Caption = 'Calculated by Order No.';
    }
    value(3; CalculatedByShipmentDate)
    {
        Caption = 'Calculated by Shipment Date';
    }
    value(4; CalculatedByShipmentDateRegardingShifts)
    {
        Caption = 'Calculated by Shipment Date with shifts';
    }
}
