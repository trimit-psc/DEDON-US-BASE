/// <summary>
/// <see cref="#7YAB"/>
/// </summary>
table 51003 "DDN Universal Classification"
{
    Caption = 'Universal Classification';
    LookupPageId = "DDN Universal Classification";


    fields
    {
        field(1; Type; Option)
        {
            Caption = 'Type';
            OptionMembers = "",ItemPlanningStatus;
            OptionCaption = ',Item Planning Status';
        }
        field(2; Code; Code[20])
        {
            Caption = 'Code';
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; Type, Code)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Code, Description)
        {
        }
    }
}