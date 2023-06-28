pageextension 51063 "COR-DDN Company Information" extends "Company Information"
{
    layout
    {
        addlast(content)
        {
            group(CORDDNadditionalInfo)
            {
                Caption = 'Trade Court and Management';

                field("COR-DDN Local Court City"; Rec."COR-DDN Local Court City")
                {
                    ApplicationArea = All;
                }
                field("COR-DDN Trade Register No."; Rec."COR-DDN Trade Register No.")
                {
                    ApplicationArea = All;
                }
                field("COR-DDN Manager"; Rec."COR-DDN Manager")
                {
                    ApplicationArea = All;
                }
                field("COR-DDN Manager 2"; Rec."COR-DDN Manager 2")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
