pageextension 51073 "COR-DDN Customer List" extends "Customer List"
{
    layout
    {
        addafter("Responsibility Center")
        {
            field("COR-DDN Respons. Person Code 2"; Rec."COR-DDN Respons. Person Code 2")
            {
                ApplicationArea = All;
            }
        }
    }
}
