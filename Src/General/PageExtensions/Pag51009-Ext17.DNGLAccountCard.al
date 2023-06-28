pageextension 51009 "DDN G/L Account Card" extends "G/L Account Card"
{
    layout
    {
        addlast(content)
        {
            group(DEDON)
            {
                /// <summary>
                /// Steuerung der Sichtbarkeit von Konten
                /// <see cref="#Q2U8"/>
                /// </summary>
                Caption = 'DEDON';

                field(Confidential; Rec.Confidential)
                {
                    ApplicationArea = All;
                    Editable = ConfidentialFieldIsEditableAndVisible_gBool;
                    ToolTip = 'Only dedicated users have access to certain accounts.';
                    //Ein vertrauliches Konto darf nur von bestimmten Benutzern eingesehen werden
                }
            }
        }
    }

    var
        ConfidentialFieldIsEditableAndVisible_gBool: Boolean;

    trigger OnAfterGetRecord()
    var
    begin
        ConfidentialFieldIsEditableAndVisible_gBool := Rec.CurrentUserCanEditConfidentialFlag();
        // Fehlermeldung unterdrücken und Seite schließen
        if not Rec.CurrentUserCanSeeGLAccount(false) then begin
            CurrPage.Close();
            // Fehlermeldung ausgeben
            Rec.CurrentUserCanSeeGLAccount(true);
        end;
    end;
}
