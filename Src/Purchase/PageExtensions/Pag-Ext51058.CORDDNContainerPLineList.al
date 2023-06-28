pageextension 51058 "COR-DDN Container P. Line List" extends "trm Container Purch Line List"
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
