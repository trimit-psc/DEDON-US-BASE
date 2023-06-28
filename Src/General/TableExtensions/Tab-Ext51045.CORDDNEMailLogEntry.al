/// <summary>
/// TableExtension COR-DDN E-Mail Log Entry (ID 51045) extends Record trm E-Mail Log Entry.
/// </summary>
/// <see cref="https://dedongroup.atlassian.net/browse/DEDT-554"/>
tableextension 51045 "COR-DDN E-Mail Log Entry" extends "trm E-Mail Log Entry"
{
    fields
    {
        field(51000; "COR-DDN Source Table Id"; Integer)
        {
            Caption = 'Table Id';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(51001; "COR-DDN Source Doc. Type"; Integer)
        {
            Caption = 'Document Type';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(51002; "COR-DDN Source Doc. Subtype"; Integer)
        {
            Caption = 'Document Sub Type';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(51003; "COR-DDN Source Doc. No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }
}
