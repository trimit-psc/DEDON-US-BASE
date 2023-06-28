/// <summary>
/// TableExtension DDN Ship-to Address (ID 51017) extends Record Ship-to Address.
/// Buchungsgruppe via Lieferadresse bestimmen
/// <see cref="#CTDG"/>
/// </summary>
tableextension 51017 "DDN Ship-to Address" extends "Ship-to Address"
{
    fields
    {
        // #CTDG
        field(51000; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group";

            trigger OnValidate()
            var
                GenBusPostingGrp: Record "Gen. Business Posting Group";
            begin
                if xRec."Gen. Bus. Posting Group" <> "Gen. Bus. Posting Group" then
                    if GenBusPostingGrp.ValidateVatBusPostingGroup(GenBusPostingGrp, "Gen. Bus. Posting Group") then
                        Validate("VAT Bus. Posting Group", GenBusPostingGrp."Def. VAT Bus. Posting Group");
            end;
        }

        // #CTDG
        field(51001; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            TableRelation = "VAT Business Posting Group";

            trigger OnValidate()
            begin
                UpdateTaxAreaId;
            end;
        }

        // #CTDG
        field(51002; "Tax Area ID"; Guid)
        {
            Caption = 'Tax Area ID';

            trigger OnValidate()
            begin
                UpdateTaxAreaCode;
            end;
        }
    }


    /// <summary>
    /// Übernommen aus Table Customer
    /// </summary>
    procedure UpdateTaxAreaId()
    var
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
        TaxArea: Record "Tax Area";
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        if GeneralLedgerSetup.UseVat then begin
            if "VAT Bus. Posting Group" = '' then begin
                Clear("Tax Area ID");
                exit;
            end;

            if not VATBusinessPostingGroup.Get("VAT Bus. Posting Group") then
                exit;

            "Tax Area ID" := VATBusinessPostingGroup.SystemId;
        end else begin
            if "Tax Area Code" = '' then begin
                Clear("Tax Area ID");
                exit;
            end;

            if not TaxArea.Get("Tax Area Code") then
                exit;

            "Tax Area ID" := TaxArea.SystemId;
        end;
    end;

    /// <summary>
    /// Übernommen aus Table Customer
    /// </summary>
    local procedure UpdateTaxAreaCode()
    var
        TaxArea: Record "Tax Area";
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        if IsNullGuid("Tax Area ID") then
            exit;

        if GeneralLedgerSetup.UseVat then begin
            VATBusinessPostingGroup.GetBySystemId("Tax Area ID");
            "VAT Bus. Posting Group" := VATBusinessPostingGroup.Code;
        end else begin
            TaxArea.GetBySystemId("Tax Area ID");
            "Tax Area Code" := TaxArea.Code;
        end;
    end;
}
