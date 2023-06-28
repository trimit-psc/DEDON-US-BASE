tableextension 51044 "COR-DDN Company Information" extends "Company Information"
{
    fields
    {
        field(51000; "COR-DDN Local Court City"; Text[50])
        {
            Caption = 'Local Court City';
            DataClassification = ToBeClassified;
        }
        field(51001; "COR-DDN Trade Register No."; Code[30])
        {
            Caption = 'Trade Register No.';
            DataClassification = ToBeClassified;
        }
        field(51002; "COR-DDN Manager"; Text[80])
        {
            Caption = '1. Manager';
            DataClassification = ToBeClassified;
        }
        field(51003; "COR-DDN Manager 2"; Text[80])
        {
            Caption = '2. Manager';
            DataClassification = ToBeClassified;
        }
    }
}
