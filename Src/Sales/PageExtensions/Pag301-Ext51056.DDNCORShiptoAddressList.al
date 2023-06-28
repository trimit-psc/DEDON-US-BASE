pageextension 51056 "DDN-COR Ship-to Address List" extends "Ship-to Address List"
{
    layout
    {
        addafter(Name)
        {
            field("Name 2"; Rec."Name 2")
            {
                ApplicationArea = All;
            }
        }
        addlast(Control1)
        {

            field("trm Default Ship-to Code"; Rec."trm Default Ship-to Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Default Ship-to Code field.';
            }
        }
    }
}
