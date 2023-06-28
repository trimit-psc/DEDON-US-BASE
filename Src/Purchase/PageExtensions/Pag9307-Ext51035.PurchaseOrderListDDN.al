pageextension 51035 "Purchase Order List (DDN)" extends "Purchase Order List" //9307
{
    layout
    {
        addlast(Control1)
        {
            field("Vendor Shipment No."; Rec."Vendor Shipment No.")
            {
                ApplicationArea = All;
            }

        }
    }
}