codeunit 51026 "COR-DDN Report Tools"
{
    /// <summary>
    /// Aufbau von Fußzeilen für Ausgangsbelege. In dieser Extension für OPPlus-Belege genutzt.
    /// <see cref="#2A3U"/>
    /// </summary>
    /// <param name="footerLine"></param>
    procedure prepareFooterLines(var footerLine: Array[5] of Text)
    var
        CompanyInfo: Record "Company Information";
        Country: Record "Country/Region";
    begin
        CompanyInfo.get();

        // Zeile 1
        footerLine[1] := CompanyInfo.Name + ' · ' + CompanyInfo.Address;
        if CompanyInfo."Address 2" <> '' then begin
            footerLine[1] += ' ' + CompanyInfo."Address 2";
        end;
        footerLine[1] += ' · ' + CompanyInfo."Post Code" + ' ' + CompanyInfo.City;
        if CompanyInfo."Country/Region Code" <> '' then begin
            if Country.get(CompanyInfo."Country/Region Code") then
                footerLine[1] += ' / ' + Country.Name;
        end;

        // Zeile 2
        footerLine[2] := 'Fon: ' + CompanyInfo."Phone No." + ' · Fax:' + CompanyInfo."Fax No.";
        if CompanyInfo."E-Mail" <> '' then
            footerLine[2] += ' · ' + CompanyInfo."E-Mail";
        if CompanyInfo."Home Page" <> '' then
            footerLine[2] += ' · ' + CompanyInfo."Home Page";

        // Zeile 3
        footerLine[3] := CompanyInfo."Bank Name" + ': BLZ / Branch-No: ' + CompanyInfo."Bank Branch No." + ' · Konto-Nr / Account-No.: ' + CompanyInfo."Bank Account No.";

        // Zeile 4
        footerLine[4] := 'Swift: ' + CompanyInfo."SWIFT Code" + ' · IBAN: ' + CompanyInfo.IBAN + ' · Amtsgericht ' + CompanyInfo."COR-DDN Local Court City" + ': ' + CompanyInfo."COR-DDN Trade Register No." + ' USt-Id-Nr.: ' + CompanyInfo."VAT Registration No.";

        // Zeile 5
        footerLine[5] := 'Geschäftsführer / Managing Director: ' + CompanyInfo."COR-DDN Manager";
        if CompanyInfo."COR-DDN Manager 2" <> '' then
            footerLine[5] += ', ' + CompanyInfo."COR-DDN Manager 2";
        footerLine[5] += ' · Sitz der Gesellschaft: ' + CompanyInfo.City;

        if CompanyInfo."Country/Region Code" <> '' then begin
            if Country.get(CompanyInfo."Country/Region Code") then
                footerLine[5] += ' / ' + Country.Name;
        end;
    end;


    procedure ExpandDocumentTypeForOpp(DocType: Enum "Gen. Journal Document Type") ret: text
    var
        Payment_lLbl: Label 'Payment';
        Invoice_lLbl: Label 'Invoice';
        CreditMemo_lLbl: Label 'Credit Memo';
        FinanceChargeMemo_lLbl: Label 'Finance Charge Memo';
        Reminder_lLbl: Label 'Reminder';
        Refund_lLbl: Label 'Refund';
    begin
        case DocType of

            DocType::Payment:
                ret := Payment_lLbl;
            DocType::Invoice:
                ret := Invoice_lLbl;
            DocType::"Credit Memo":
                ret := CreditMemo_lLbl;
            DocType::"Finance Charge Memo":
                ret := FinanceChargeMemo_lLbl;
            DocType::Reminder:
                ret := Reminder_lLbl;
            DocType::Refund:
                ret := Refund_lLbl;
        end;
    end;
}
