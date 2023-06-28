pageextension 51075 "Customer Leder Entries DDN" extends "Customer Ledger Entries"
{
    layout
    {
        addafter(Description)
        {
            field("Last Issued Reminder Level"; Rec."Last Issued Reminder Level")
            {
                ApplicationArea = All;
            }
        }
    }
}