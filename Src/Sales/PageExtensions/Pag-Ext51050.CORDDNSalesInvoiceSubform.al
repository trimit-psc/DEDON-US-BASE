pageextension 51050 "COR-DDN Sales Invoice Subform" extends "Sales Invoice Subform"
{
    layout
    {
        addafter("Qty. to Assign")
        {

            field("DDN Item Planning Status Code"; Rec."DDN Item Planning Status Code")
            {
                ApplicationArea = All;
            }
        }
        modify("Qty. Assigned")
        {
            Visible = true;
        }
    }
}
