/// <summary>
/// <see cref="#SMH1"/>
/// </summary>
page 51008 "Comments FactBox"
{
    Caption = 'Comments FactBox';
    Editable = false;
    PageType = ListPart;
    SourceTable = "Comment Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field(Date; Rec.Date)
                {
                    ApplicationArea = All;
                    visible = false;
                }
                field(Comment; Rec.Comment)
                {
                    ApplicationArea = All;
                }

            }
        }
    }
}

