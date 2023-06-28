pageextension 51070 "COR-DDN E-Mail Log Card" extends "trm E-Mail Log Card"
{
    layout
    {
        addafter("Transaction Info")
        {
            group("COR-DDN Document Info")
            {
                Caption = 'Document Info';
                field("COR-DDN Source Doc. No."; rec."COR-DDN Source Doc. No.")
                {
                }
            }
        }
    }
}
