pageextension 51066 "COR-DDN Posted Sales Shipment" extends "Posted Sales Shipment"
{
    layout
    {
        addafter(Control1905767507)
        {
            /// <summary>
            /// <see cref="#SMH1"/>
            /// </summary>
            part("Comments FactBox"; "Comments FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "Table Name" = const(Customer), "No." = field("Sell-to Customer No.");
            }
        }
        addafter("No.")
        {

            field("Your Reference"; Rec."Your Reference")
            {
                ApplicationArea = All;
            }
        }
    }
}
