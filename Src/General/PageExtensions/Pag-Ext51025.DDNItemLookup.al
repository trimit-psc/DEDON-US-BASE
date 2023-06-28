pageextension 51025 "DDN Item Lookup" extends "Item Lookup"
{
    layout
    {
        addafter("No.")
        {
            field("DDN No. 2"; Rec."No. 2")
            {
                ApplicationArea = All;
                width = 30;
            }
        }
        modify(Description)
        {
            width = 60;
        }
        addafter("trm Description 2")
        {
            field("DDN Item Status Code"; Rec.getStatusCode())
            {
                ApplicationArea = All;
                editable = false;
                Caption = 'Status Code (Matrix/Item)';
                ToolTip = 'This is a DEDON field that is stored in the table MatrixCell of the corresponding master.';
            }
        }
        modify("No.")
        {
            width = 30;
        }
    }
}
