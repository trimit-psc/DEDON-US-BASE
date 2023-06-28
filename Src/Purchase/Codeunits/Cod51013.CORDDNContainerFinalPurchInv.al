/// <summary>
/// EK-Schluss-Rechnung basierend auf Container-Lieferungen erstellen
/// <see cref="#AT4L"/>
/// </summary>
codeunit 51013 "COR-DDN Cont. Fin. Purch. Inv."
{
    TableNo = "trm Container";

    var
        DestPurchaseHeader_gRec: record "Purchase Header";
        SrcPurchaseInvoiceHeader_gRec: record "Purch. Inv. Header";
        ConfirmContainersLabel1: Label 'Do you want to create an incoming invoice for Container %1?';
        ConfirmContainersLabel2: Label 'Do you want to create an incoming invoice for Container %1 and %2 more?';
        NoLinesAddedErrorLabel: Label 'No receipt lines were could be found. For that reason no invoice was created.';

    trigger OnRun()
    var
        CountLines_lInt: Integer;
        ddnSetup: Record "DDN Setup";
    begin
        if not Rec.FindSet() then
            exit;
        if Rec.count() = 1 then begin
            if not confirm(ConfirmContainersLabel1, true, Rec."No.") then
                exit;
        end else begin
            if not confirm(ConfirmContainersLabel2, true, Rec."No.", Rec.Count() - 1) then
                exit;
        end;

        createInvoiceHeader(Rec);
        repeat
            CheckContainerPlausibility(Rec);
            CountLines_lInt += addContainerToInvoice(Rec);
        until Rec.Next() = 0;
        if CountLines_lInt = 0 then
            error(NoLinesAddedErrorLabel);

        ddnSetup.get();
        case ddnSetup."G/L Lines in Cont. item Inv." of
            ddnSetup."G/L Lines in Cont. item Inv."::viaPurchaseReceiptLine:
                begin
                    repeat
                        addBalanceLinesViaPurchaseReceipt(Rec);
                    until Rec.Next() = 0;
                end;
            ddnSetup."G/L Lines in Cont. item Inv."::viaPurchaseInvoiceLine:
                begin
                    repeat
                        addBalanceLinesViaPurchaseInvoice();
                    until Rec.Next() = 0;
                end;
        end;

        OpenPurchaseInvoice();
    end;

    local procedure addContainerToInvoice(var Container_vRec: Record "trm Container") LineCount: Integer
    var
        PurchGetReceipt_lCu: codeunit "Purch.-Get Receipt";
        PurchRcptLine_lRec: Record "Purch. Rcpt. Line";
    begin
        PurchRcptLine_lRec.SetRange("trm Container No.", Container_vRec."No.");
        PurchRcptLine_lRec.SetFilter("Qty. Rcd. Not Invoiced", '<>0');
        PurchRcptLine_lRec.setrange("Buy-from Vendor No.", DestPurchaseHeader_gRec."Buy-from Vendor No.");
        PurchRcptLine_lRec.setrange("Pay-to Vendor No.", DestPurchaseHeader_gRec."Pay-to Vendor No.");
        lineCount := PurchRcptLine_lRec.Count;

        PurchGetReceipt_lCu.SetPurchHeader(DestPurchaseHeader_gRec);
        PurchGetReceipt_lCu.CreateInvLines(PurchRcptLine_lRec);
    end;

    local procedure createInvoiceHeader(var Container_vRec: Record "trm Container")
    var
        ddnSetup: Record "DDN Setup";
        VendorInvoiceNo_lCode: code[35];
        srcInvoiceDocumentNo_lCode: code[20];
    begin
        VendorInvoiceNo_lCode := EnterInvoiceNumber(Container_vRec);
        ddnSetup.get();
        DestPurchaseHeader_gRec.init;
        DestPurchaseHeader_gRec."Document Type" := DestPurchaseHeader_gRec."Document Type"::Invoice;
        DestPurchaseHeader_gRec.insert(true);
        DestPurchaseHeader_gRec.validate("Buy-from Vendor No.", getVendorNo(Container_vRec, 0));
        DestPurchaseHeader_gRec."Pay-to Vendor No." := getVendorNo(Container_vRec, 1);
        if DestPurchaseHeader_gRec."Pay-to Vendor No." <> DestPurchaseHeader_gRec."Buy-from Vendor No." then
            DestPurchaseHeader_gRec.Validate("Pay-to Vendor No.");
        DestPurchaseHeader_gRec.TestField("Buy-from Vendor No.");
        DestPurchaseHeader_gRec.TestField("Pay-to Vendor No.");
        if ddnSetup."Reason Code Cont. Final Inv." <> '' then
            DestPurchaseHeader_gRec.validate("Reason Code", ddnSetup."Reason Code Cont. Final Inv.");
        DestPurchaseHeader_gRec."Vendor Invoice No." := VendorInvoiceNo_lCode;

        // Wechselkurs aus dem ursprünglichen Beleg übernehmen
        srcInvoiceDocumentNo_lCode := getDocumentNoForPostedGLInvoice();
        if srcInvoiceDocumentNo_lCode <> '' then begin
            if DestPurchaseHeader_gRec."Currency Factor" <> SrcPurchaseInvoiceHeader_gRec."Currency Factor" then
                DestPurchaseHeader_gRec.validate("Currency Factor", SrcPurchaseInvoiceHeader_gRec."Currency Factor");
        end;
        DestPurchaseHeader_gRec.Modify(true);
    end;

    local procedure CheckContainerPlausibility(var Container_vRec: Record "trm Container")
    var
        Container_lRec: Record "trm Container";
    begin
        Container_vRec.findfirst;
        Container_lRec.CopyFilters(Container_vRec);

        if Container_lRec.FindSet() then
            repeat
                Container_lRec.TestField(Container_lRec.Type, Container_lRec.Type::Inbound);
            until Container_lRec.Next() = 0;
    end;

    local procedure OpenPurchaseInvoice()
    var

    begin
        Page.Run(Page::"Purchase Invoice", DestPurchaseHeader_gRec);
    end;

    local procedure getVendorNo(var Container_vRec: Record "trm Container"; BuyFromOrPayTo: Option BuyFrom,PayTo) VendorNo: Code[20]
    var
        PurchRcptLine_lRec: Record "Purch. Rcpt. Line";
    begin
        Container_vRec.TestField("No.");
        PurchRcptLine_lRec.SetRange("trm Container No.", Container_vRec."No.");
        PurchRcptLine_lRec.SetFilter("Qty. Rcd. Not Invoiced", '<>0');

        if PurchRcptLine_lRec.FindFirst() then begin
            if BuyFromOrPayTo = BuyFromOrPayTo::BuyFrom then begin
                PurchRcptLine_lRec.SetFilter("Buy-from Vendor No.", '<>''''');
                VendorNo := PurchRcptLine_lRec."Buy-from Vendor No."
            end
            else begin
                PurchRcptLine_lRec.SetFilter("Pay-to Vendor No.", '<>''''');
                VendorNo := PurchRcptLine_lRec."Pay-to Vendor No.";
            end;
        end
        else begin
            error(NoLinesAddedErrorLabel)
        end;
    end;

    /// <summary>
    /// Platzhalter um später einen Ausgleich der EK-Rechnung
    /// zu der erstmalig, gegen Sachkonto gebuchten EK-Rechnung zu ermöglichen
    /// </summary>
    local procedure addBalanceLines()
    var
        PurchaseLine_lRec: Record "Purchase Line";
        LineNo: Integer;
        ddnSetup: Record "DDN Setup";
    begin
        ddnSetup.get();
        // keine Zeilen geneireren
        if ddnSetup."G/L Lines in Cont. item Inv." = ddnSetup."G/L Lines in Cont. item Inv."::skip then
            exit;
        PurchaseLine_lRec.SetRange("Document Type", DestPurchaseHeader_gRec."Document Type");
        PurchaseLine_lRec.SetRange("Document No.", DestPurchaseHeader_gRec."No.");
        LineNo := 10000;
        if PurchaseLine_lRec.findlast then begin
            LineNo += PurchaseLine_lRec."Line No.";
        end;


        PurchaseLine_lRec.Reset();
        PurchaseLine_lRec.init;
        PurchaseLine_lRec."Document Type" := DestPurchaseHeader_gRec."Document Type";
        PurchaseLine_lRec."Document No." := DestPurchaseHeader_gRec."No.";
        PurchaseLine_lRec."Line No." := LineNo;
        PurchaseLine_lRec.Insert(true);

        PurchaseLine_lRec.type := PurchaseLine_lRec.Type::" ";
        clear(PurchaseLine_lRec."No.");
        PurchaseLine_lRec.Description := 'Platzhalter für Ausgleich mit Sachkontorechnung';
        PurchaseLine_lRec.Modify(true);
    end;

    /// <summary>
    /// Als Basis dienen die Bestellzeilen bzw. die Lieferzeilen
    /// </summary>
    local procedure addBalanceLinesViaPurchaseReceipt(var Container_vRec: Record "trm Container")
    var
        PurchRcptLine_lRec: Record "Purch. Rcpt. Line";
        DestPurchaseLine_lRec: Record "Purchase Line";
        LineNo: Integer;
        Master: Record "trm Master";
    begin
        PurchRcptLine_lRec.SetRange("trm Container No.", Container_vRec."No.");
        PurchRcptLine_lRec.SetFilter("Qty. Rcd. Not Invoiced", '<>0');
        PurchRcptLine_lRec.setrange("Buy-from Vendor No.", DestPurchaseHeader_gRec."Buy-from Vendor No.");
        PurchRcptLine_lRec.setrange("Pay-to Vendor No.", DestPurchaseHeader_gRec."Pay-to Vendor No.");

        DestPurchaseLine_lRec.SetRange("Document Type", DestPurchaseHeader_gRec."Document Type");
        DestPurchaseLine_lRec.SetRange("Document No.", DestPurchaseHeader_gRec."No.");
        LineNo := 10000;
        if DestPurchaseLine_lRec.findlast then begin
            LineNo += DestPurchaseLine_lRec."Line No.";
        end;

        DestPurchaseLine_lRec.Reset();

        if PurchRcptLine_lRec.FindSet() then
            repeat
                DestPurchaseLine_lRec.init;
                DestPurchaseLine_lRec."Document Type" := DestPurchaseHeader_gRec."Document Type";
                DestPurchaseLine_lRec."Document No." := DestPurchaseHeader_gRec."No.";
                DestPurchaseLine_lRec."Line No." := LineNo;
                DestPurchaseLine_lRec.Insert(true);

                DestPurchaseLine_lRec.Type := DestPurchaseLine_lRec.type::"G/L Account";
                DestPurchaseLine_lRec.validate("No.", findGlAccount(PurchRcptLine_lRec));
                DestPurchaseLine_lRec.Validate(Quantity, -PurchRcptLine_lRec.Quantity);
                if PurchRcptLine_lRec."direct unit cost" > 0 then
                    DestPurchaseLine_lRec.Validate("Direct unit cost", PurchRcptLine_lRec."Direct Unit Cost");
                if PurchRcptLine_lRec."Line Discount %" <> 0 then
                    DestPurchaseLine_lRec.Validate("Line Discount %", PurchRcptLine_lRec."Line Discount %");
                PurchRcptLine_lRec.CalcFields("Item No. 2");

                DestPurchaseLine_lRec."Description" := PurchRcptLine_lRec."Description";
                DestPurchaseLine_lRec."Description 2" := PurchRcptLine_lRec."Description 2";

                DestPurchaseLine_lRec.Description := copystr(PurchRcptLine_lRec.Description + ', ' + PurchRcptLine_lRec."Description 2", 1, maxstrlen(DestPurchaseLine_lRec."Description 2"));
                DestPurchaseLine_lRec.validate("Dimension Set ID", PurchRcptLine_lRec."Dimension Set ID");

                DestPurchaseLine_lRec."Order No." := PurchRcptLine_lRec."Order No.";
                DestPurchaseLine_lRec."Order Line No." := PurchRcptLine_lRec."Order Line No.";
                DestPurchaseLine_lRec.Modify(true);
                LineNo += 10000;
            until PurchRcptLine_lRec.Next() = 0;
    end;

    /// <summary>
    /// Ermittlet für die Artikelrechnung die zugehörige, erste Sachkontorechnungh
    /// </summary>
    /// <returns></returns>
    local procedure getDocumentNoForPostedGLInvoice() srcInvoiceDocumentNo: Code[20]
    var
        SrcPurchaseInvoiceHeader_lRec: Record "purch. inv. header";
        ddnSetup: Record "DDN Setup";
    begin
        // wir verhindern unnötige doppelte Aufrufe 
        if SrcPurchaseInvoiceHeader_lRec."No." <> '' then
            exit(SrcPurchaseInvoiceHeader_lRec."No.");
        ddnSetup.get();
        SrcPurchaseInvoiceHeader_lRec.SetRange("Vendor Invoice No.", buildVendorInvoiceNoFilterExpression(DestPurchaseHeader_gRec."Vendor Invoice No."));
        SrcPurchaseInvoiceHeader_lRec.SetRange("Reason Code", ddnSetup."Reason Code Cont. Prepay");
        SrcPurchaseInvoiceHeader_lRec.setrange("Buy-from Vendor No.", DestPurchaseHeader_gRec."Buy-from Vendor No.");
        if SrcPurchaseInvoiceHeader_lRec.count = 1 then begin
            SrcPurchaseInvoiceHeader_lRec.FindFirst();
            srcInvoiceDocumentNo := SrcPurchaseInvoiceHeader_lRec."No.";
        end
        else begin
            // Falls die Suche über die Nummer uneindeutig war oder kein Ergebnis brachte wird der Anwender dei Rechnung manuell auswählen müssen
            SrcPurchaseInvoiceHeader_lRec.SetRange("Vendor Invoice No.");
            SrcPurchaseInvoiceHeader_lRec.SetRange("Reason Code");
            if page.RunModal(Page::"Posted Purchase Invoices", SrcPurchaseInvoiceHeader_lRec) = Action::LookupOK then begin
                srcInvoiceDocumentNo := SrcPurchaseInvoiceHeader_lRec."No.";
            end;
        end;
        if srcInvoiceDocumentNo <> '' then
            SrcPurchaseInvoiceHeader_gRec.get(srcInvoiceDocumentNo);
    end;

    /// <summary>
    /// Sucht basierend auf den gebuchten EK-Rechnungen 
    /// </summary>
    local procedure addBalanceLinesViaPurchaseInvoice()
    var
        SrcPurchaseInvoiceHeader: Record "purch. inv. header";
        SrcPurchaseInvoiceLine: Record "purch. inv. line";
        //ddnSetup: Record "DDN Setup";
        srcInvoiceDocumentNo: Code[20];
        DestPurchaseLine_lRec: Record "Purchase Line";
        LineNo: integer;
    begin
        // Suche die Einkaufsrechnung, die über Sachkonten gelaufen ist anhand der externen Belegnummer
        srcInvoiceDocumentNo := getDocumentNoForPostedGLInvoice();
        if srcInvoiceDocumentNo = '' then exit;

        SrcPurchaseInvoiceLine.setrange("Document No.", srcInvoiceDocumentNo);
        SrcPurchaseInvoiceLine.setrange(Type, SrcPurchaseInvoiceLine.type::"G/L Account");
        if not SrcPurchaseInvoiceLine.FindSet() then
            exit;

        DestPurchaseLine_lRec.SetRange("Document Type", DestPurchaseHeader_gRec."Document Type");
        DestPurchaseLine_lRec.SetRange("Document No.", DestPurchaseHeader_gRec."No.");
        LineNo := 10000;
        if DestPurchaseLine_lRec.findlast then begin
            LineNo += DestPurchaseLine_lRec."Line No.";
        end;
        repeat
            DestPurchaseLine_lRec.init;
            DestPurchaseLine_lRec."Document Type" := DestPurchaseHeader_gRec."Document Type";
            DestPurchaseLine_lRec."Document No." := DestPurchaseHeader_gRec."No.";
            DestPurchaseLine_lRec."Line No." := LineNo;
            DestPurchaseLine_lRec.Insert(true);

            DestPurchaseLine_lRec.Type := SrcPurchaseInvoiceLine.Type;
            DestPurchaseLine_lRec.validate("No.", SrcPurchaseInvoiceLine."No.");
            // GANZ WICHTIG: Die Meng ewird hier negativ
            DestPurchaseLine_lRec.Validate(Quantity, -SrcPurchaseInvoiceLine.Quantity);
            if SrcPurchaseInvoiceLine."direct unit cost" > 0 then
                DestPurchaseLine_lRec.Validate("Direct unit cost", SrcPurchaseInvoiceLine."Direct Unit Cost");
            if SrcPurchaseInvoiceLine."Line Discount %" <> 0 then
                DestPurchaseLine_lRec.Validate("Line Discount %", SrcPurchaseInvoiceLine."Line Discount %");

            DestPurchaseLine_lRec."Description" := SrcPurchaseInvoiceLine."Description";
            DestPurchaseLine_lRec."Description 2" := SrcPurchaseInvoiceLine."Description 2";

            DestPurchaseLine_lRec.validate("Dimension Set ID", SrcPurchaseInvoiceLine."Dimension Set ID");
            DestPurchaseLine_lRec."Order No." := SrcPurchaseInvoiceLine."Order No.";
            DestPurchaseLine_lRec."Order Line No." := SrcPurchaseInvoiceLine."Order Line No.";

            DestPurchaseLine_lRec.Modify(true);
            LineNo += 10000;
        until SrcPurchaseInvoiceLine.Next() = 0;
    end;

    local procedure EnterInvoiceNumber(var Container_vRec: Record "trm Container") VendorInvoiceNo: code[35]
    var
        dialog_lPage: page "COR-DDN Container Inv. Dialog";
        missingVendorInvoiceNoError_lLbl: Label 'You did not enter the vendors invoice no. Without this number it will not be possible to determine a link between the G/L Invoices and the item Invoices.';
    begin
        dialog_lPage.SetContext(getVendorNo(Container_vRec, 0), 1);
        if dialog_lPage.Runmodal() <> Action::OK then
            error('');
        VendorInvoiceNo := dialog_lPage.getVendorInvoiceNo(true);
        if VendorInvoiceNo = '' then
            error(missingVendorInvoiceNoError_lLbl);
        exit(VendorInvoiceNo);
    end;

    local procedure findGlAccount(var RcptLine_lRec: Record "Purch. Rcpt. Line") ret: Code[20]
    var
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        if GeneralPostingSetup.get(RcptLine_lRec."Gen. Bus. Posting Group", RcptLine_lRec."Gen. Prod. Posting Group") then
            ret := GeneralPostingSetup."Purch. Account";
    end;

    /// <summary>
    /// Baut basierend auf einer Kreditorenrechnungsnummer für eine Artikel.-rechnung eine
    /// Kreditorenrechnung für Sachkontorechnung um den ursprünglichen Belge zu finden gegen den auszugleichen ist.
    /// </summary>
    /// <returns></returns>
    local procedure buildVendorInvoiceNoFilterExpression(VendorInvoiceNoForItemInvoice_iCod: Code[35]) VendorInvoiceNoForAccountInvoice_Cod: code[35]
    var
        i: Integer;
        ddnSetup: Record "DDN Setup";
    begin
        ddnSetup.get;
        // VendorInvoiceNo_iCod z.B. aus CEBU-12345/A soll werden CEBU-12345/S
        // aus CEBU-12345/A wird CEBU-12345
        VendorInvoiceNoForAccountInvoice_Cod := CopyStr(VendorInvoiceNoForItemInvoice_iCod, 1, strlen(VendorInvoiceNoForItemInvoice_iCod) - StrLen(ddnSetup."Appendix Cont. Final Inv."));
        // aus CEBU-12345 wird CEBU-12345/S
        VendorInvoiceNoForAccountInvoice_Cod += ddnSetup."Appendix Cont. Prepay";
    end;
}
