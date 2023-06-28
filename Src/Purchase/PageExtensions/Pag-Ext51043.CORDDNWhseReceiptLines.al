pageextension 51043 "COR-DDN Whse. Receipt Lines" extends "Whse. Receipt Lines"
{
    layout
    {
        addbefore("Source No.")
        {

            field("Due Date"; Rec."No.")
            {
                ApplicationArea = All;
            }
        }
        addfirst(Control1)
        {
            field("COR-DDN No."; Rec."No.")
            {
                ApplicationArea = All;
            }
        }
    }
}
