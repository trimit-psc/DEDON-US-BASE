/// <summary>
/// #M5EZ Vergabe der GTIN aus Nummernkreis
/// </summary>
codeunit 51025 "COR-DDN Gtin Functions"
{
    procedure getNextGtin() ret: Code[20]
    var
        NoSeriesMgmt: Codeunit NoSeriesManagement;
        DDNSetup: Record "DDN Setup";
    begin
        DDNSetup.Get();
        DDNSetup.testfield("GTIN Number Series");

        ret := NoSeriesMgmt.GetNextNo3(DDNSetup."GTIN Number Series", WorkDate(), true, true);
        ret := strsubstno('%1%2', ret, STRCHECKSUM(ret, '131313131313'));
    end;

    /// <summary>
    /// Prüft, ob die EAN ggf. mehr als einem Artikel zugewiesen wurde
    /// </summary>
    procedure CheckDublicate(var item_vRec: Record Item)
    var
        ddnSetup_lRec: Record "DDN Setup";
        otherItems_lRec: Record Item;
        otherItemsFoundConfirmation_lLbl: Label '%1 items carry the identical GTIN. The first one is %2 %3. Do you really want to apply the GTIN?';
        otherItemsFoundError_lLbl: Label '%1 items carry the identical GTIN. The first one is %2 %3.';
    begin
        otherItems_lRec.setfilter("No.", '<>%1', item_vRec."No.");
        otherItems_lRec.setrange(GTIN, item_vRec.GTIN);
        if otherItems_lRec.FindFirst() then begin
            ddnSetup_lRec.FindFirst();
            case ddnSetup_lRec."Check GTIN Duplicate" of
                ddnSetup_lRec."Check GTIN Duplicate"::ignore:
                    begin

                    end;
                ddnSetup_lRec."Check GTIN Duplicate"::notify:
                    begin
                        if not confirm(otherItemsFoundConfirmation_lLbl, false, otherItems_lRec.count(), otherItems_lRec."No.", otherItems_lRec.Description) then begin
                            error('');
                        end;
                    end;
                ddnSetup_lRec."Check GTIN Duplicate"::error:
                    begin
                        error(otherItemsFoundError_lLbl, otherItems_lRec.count(), otherItems_lRec."No.", otherItems_lRec.Description);
                    end;
            end;

        end;
    end;

    procedure GtinIsValid(EANToCheck_iCod: Code[50]) ret: Boolean
    var
        EANWithoutChecksum_lCod: Code[12];
        Checksum_lInt: Integer;
        i: Integer;
    begin
        ret := true;
        IF EANToCheck_iCod = '' THEN
            EXIT(false);

        IF STRLEN(EANToCheck_iCod) <> 13 THEN
            exit(false);

        // Zeichen abfangen weil die Checksummenberechnung sonst ggf. scheitert.
        for i := 1 to StrLen(EANToCheck_iCod) do begin
            if not (EANToCheck_iCod[i] in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']) then
                exit(false);
        end;

        EANWithoutChecksum_lCod := COPYSTR(EANToCheck_iCod, 1, 12);
        Checksum_lInt := CalculateChecksum_gFnc(EANWithoutChecksum_lCod);

        IF COPYSTR(EANToCheck_iCod, 13, 1) <> FORMAT(Checksum_lInt) THEN begin
            exit(false);
        end;
    end;

    local procedure CalculateChecksum_gFnc(EANWithoutChecksum_iCod: Code[12]) Checksum_rInt: Integer
    var
        Factor_lInt: Integer;
        lInt: Integer;
        Temp_lInt: Integer;
        EANNotNumericalError_lLbl: Label 'EAN %1 is not completely numerical.';
    begin
        IF EANWithoutChecksum_iCod = '' THEN
            EXIT;

        Factor_lInt := 1;
        Checksum_rInt := 0;
        FOR lInt := 1 TO 12 DO BEGIN
            IF NOT EVALUATE(Temp_lInt, COPYSTR(EANWithoutChecksum_iCod, lInt, 1)) THEN
                ERROR(EANNotNumericalError_lLbl, EANWithoutChecksum_iCod);
            Checksum_rInt := Checksum_rInt + Factor_lInt * Temp_lInt;
            IF Factor_lInt = 1 THEN
                Factor_lInt := 3
            ELSE
                Factor_lInt := 1;
        END;
        Checksum_rInt := 10 - (Checksum_rInt MOD 10);
        IF Checksum_rInt = 10 THEN
            Checksum_rInt := 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterValidateEvent', 'GTIN', false, false)]
    local procedure ItemOnAfterValidateGTIN(Rec: Record Item)
    var
        gtinInvalidError_lLbl: Label 'The GTIN %1 is not a valid GTIN.';
    begin
        // lere GTIN ist immer ok
        if rec.GTIN = '' then
            exit;
        if not GtinIsValid(Rec.GTIN) then
            error(gtinInvalidError_lLbl, rec.GTIN);
        CheckDublicate(Rec);
    end;
}

