pageextension 51067 "COR-DDN Posted Sales Cr.Memo" extends "Posted Sales Credit Memo"
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
    }
}
