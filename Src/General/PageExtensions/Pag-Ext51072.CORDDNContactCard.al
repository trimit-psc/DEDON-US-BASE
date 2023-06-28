pageextension 51072 "COR-DDN Contact Card" extends "Contact Card"
{
    layout
    {
        addafter("trm Salesperson 3")
        {
            field("COR-DDN Respons. Person Code"; Rec."COR-DDN Respons. Person Code 2")
            {
                ApplicationArea = All;
            }
        }
    }
}
