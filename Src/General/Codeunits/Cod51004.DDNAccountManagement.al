/// <summary>
/// Konten als "confidential" klassifizieren
/// <see cref="#Q2U8"/>
/// </summary>
codeunit 51004 "DDN Account Management"
{
    procedure ApplyConfidentialFilter(var GLAccount_iRec: Record "G/L Account")
    var
    begin
        if doFilterCurrentUser() then begin
            GLAccount_iRec.FilterGroup(2);
            GLAccount_iRec.SetRange(Confidential, false);
            GLAccount_iRec.FilterGroup(0);
        end;
    end;

    procedure ApplyConfidentialFilter(var GLEntry_iRec: Record "G/L Entry")
    var
    begin
        if doFilterCurrentUser() then begin
            GLEntry_iRec.FilterGroup(2);
            GLEntry_iRec.SetRange("DDN Account confidential", false);
            GLEntry_iRec.FilterGroup(0);
        end;
    end;

    local procedure doFilterCurrentUser() doFilter_lBool: Boolean
    var
        UserSetup_lRec: Record "User Setup";
    begin
        if not UserSetup_lRec.get(UserId) then
            doFilter_lBool := true
        else
            doFilter_lBool := not UserSetup_lRec."Access confidential G/L Accout";

    end;
}
