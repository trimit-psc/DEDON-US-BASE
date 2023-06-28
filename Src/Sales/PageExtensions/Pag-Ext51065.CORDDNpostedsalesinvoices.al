pageextension 51065 "COR-DDN posted sales invoices" extends "posted sales invoices"
{
    layout
    {
        addafter("No.")
        {
            /// <summary>
            /// Feld einblenden
            /// <see cref="https://dedongroup.atlassian.net/browse/DEDT-418"/>
            /// </summary>
            field("Prepayment Invoice"; Rec."Prepayment Invoice")
            {
                ApplicationArea = All;
            }
        }
    }
}
