/// <summary>
/// <see cref="#7YAB"/>
/// </summary>

page 51006 "DDN Universal Classification"
{
    Caption = 'DDN Universal Classification';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "DDN Universal Classification";
    DelayedInsert = true;
    PopulateAllFields = true;

    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                }
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}