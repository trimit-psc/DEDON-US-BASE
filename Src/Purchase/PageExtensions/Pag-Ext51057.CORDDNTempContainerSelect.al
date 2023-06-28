pageextension 51057 "COR-DDN Temp Container Select" extends "Trm Temp Container Content Sel"
{
    layout
    {
        addafter("No.")
        {

            field("COR-DDN Legacy System Item No."; Rec."COR-DDN Legacy System Item No.")
            {
                ApplicationArea = All;
            }
        }
    }
}
