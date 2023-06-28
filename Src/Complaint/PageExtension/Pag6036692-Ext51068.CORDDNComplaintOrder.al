pageextension 51068 "COR-DDN Complaint Order" extends "trm Complaint Order"
{
    layout
    {
        addafter("Attached Documents")
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
        modify("Order Type")
        {
            Visible = true;
            Caption = 'Order Type';
        }
    }
}
