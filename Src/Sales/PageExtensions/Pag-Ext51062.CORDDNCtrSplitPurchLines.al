pageextension 51062 "COR-DDN Ctr Split Purch Lines" extends "trm Temp Ctr Split Purch Lines"
{
    layout
    {
        addafter("trm No.")
        {

            field("COR-DDN Legacy System Item No."; Rec."COR-DDN Legacy System Item No.")
            {
                ApplicationArea = All;
            }
        }
    }
}
