pageextension 51074 "COR-DDN Complaint Order List" extends "trm Complaint Orders List"
{
    layout
    {
        addafter("Sell-to Customer Name")
        {
            field("COR-DDN Your Reference"; Rec."Your Reference")
            {
                ApplicationArea = All;
            }
        }
    }
}