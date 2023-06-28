pageextension 51061 "COR-DDN Posted Sales Shipments" extends "Posted Sales Shipments"
{
    layout
    {
        addafter("No.")
        {

            field("Order No."; Rec."Order No.")
            {
                ApplicationArea = All;
            }
            field("Your Reference"; Rec."Your Reference")
            {
                ApplicationArea = All;
            }
        }
    }
}
