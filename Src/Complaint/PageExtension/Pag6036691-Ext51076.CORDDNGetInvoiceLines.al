pageextension 51076 "COR-DDN Get Invoice Lines" extends "trm Get Invoice Lines"
{
    layout
    {
        addafter(Quantity)
        {
            field("COR-DDN Order No."; Rec."Order No.")
            {
                ApplicationArea = All;
            }
            field("COR-DDN Shipment No."; Rec."Shipment No.")
            {
                ApplicationArea = All;
            }
        }
    }
}