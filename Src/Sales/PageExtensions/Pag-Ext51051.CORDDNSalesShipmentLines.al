pageextension 51051 "COR-DDN Sales Shipment Lines" extends "Sales Shipment Lines"
{
    layout
    {
        addafter("No.")
        {
            field("DDN Item Planning Status Code"; Rec."DDN Item Planning Status Code")
            {
                ApplicationArea = All;
            }
        }
    }
}
