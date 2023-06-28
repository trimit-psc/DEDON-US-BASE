/// <summary>
/// Konten als "confidential" klassifizieren
/// <see cref="#Q2U8"/>
/// </summary>
pageextension 51011 "DDN User Setup" extends "User Setup"
{
    layout
    {
        addlast(Control1)
        {
            // #Q2U8
            field(Confidential; Rec."Access confidential G/L Accout")
            {
                ApplicationArea = All;
                ToolTip = 'Enable this field if you want the user to see confidential G/L Accounts.';
            }
        }
    }
}