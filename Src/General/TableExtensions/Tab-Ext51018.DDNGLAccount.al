tableextension 51018 "DDN G/L Account" extends "G/L Account"
{
    fields
    {
        field(51000; Confidential; Boolean)
        {
            Caption = 'Confidential';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                myInt: Integer;
            begin
                if not CurrentUserCanEditConfidentialFlag() then
                    error(ConfidentialFieldEditNotAllowedError);
            end;
        }
    }
    var
        // Sie dürfen nicht bestimmen, ob ein Konto confidential ist oder nicht.
        ConfidentialFieldEditNotAllowedError: Label 'You are not allowed to change confidentiality of an account.';
        AccountNotAccessableForUserError: Label 'Access to the account was denied';

    procedure CurrentUserCanSeeGLAccount(verbose_lBool: Boolean) ret_b: Boolean
    var
        UserSetup_lRec: Record "User Setup";
    begin
        if not Rec.Confidential then
            exit(true);
        // pessimistische Sicht: Wer nicht angelegt ist darf nichts sehen            
        if not UserSetup_lRec.get(UserId) then
            ret_b := false
        else
            ret_b := UserSetup_lRec."Access confidential G/L Accout";

        if verbose_lBool and not ret_b then
            error(AccountNotAccessableForUserError);
    end;

    procedure CurrentUserCanEditConfidentialFlag() ret_b: Boolean
    var
        UserSetup_lRec: Record "User Setup";
    begin
        if not UserSetup_lRec.get(UserId) then
            exit(false);
        exit(UserSetup_lRec."Access confidential G/L Accout");
    end;
}
