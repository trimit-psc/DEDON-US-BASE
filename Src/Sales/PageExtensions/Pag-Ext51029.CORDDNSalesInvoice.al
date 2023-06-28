pageextension 51029 "COR-DDN Sales Invoice" extends "Sales Invoice"
{
    layout
    {
        /// <summary>
        /// <see cref="#U29F"/>
        /// </summary>
        addafter("trm Salesperson 3")
        {
            field("COR-DDN Respons. Person Code"; Rec."COR-DDN Respons. Person Code")
            {
                ApplicationArea = All;
            }
        }

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
