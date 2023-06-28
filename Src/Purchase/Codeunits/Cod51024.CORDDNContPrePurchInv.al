/// <summary>
/// EK-Sachkonto-Rechnung basierend auf Container-Lieferungen erstellen
/// <see cref="#AT4L"/>
/// </summary>
codeunit 51024 "COR-DDN Cont. Pre. Purch. Inv."
{
    TableNo = "trm Container";

    var
        PurchaseHeader_gRec: record "Purchase Header";
        ConfirmContainersLabel1: Label 'Do you want to create an incoming invoice for Container %1?';
        ConfirmContainersLabel2: Label 'Do you want to create an incoming invoice for Container %1 and %2 more?';
        NoLinesAddedErrorLabel: Label 'No receipt lines were could be found. For that reason no invoice was created.';

    trigger OnRun()
    var
        CountLines_lInt: Integer;

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

        createInvoice(Rec);
        repeat
            CheckContainerPlausibility(Rec);
            CountLines_lInt += addContainerToInvoice(Rec);
        until Rec.Next() = 0;
        if CountLines_lInt = 0 then
            error(NoLinesAddedErrorLabel);
        OpenPurchaseInvoice();
    end;

    local procedure createInvoice(var Container_vRec: Record "trm Container")
    var
        ddnSetup: Record "DDN Setup";
        VendorInvoiceNo_lCode: code[35];
    begin
        VendorInvoiceNo_lCode := EnterInvoiceNumber(Container_vRec);
        ddnSetup.get();
        PurchaseHeader_gRec.init;
        PurchaseHeader_gRec."Document Type" := PurchaseHeader_gRec."Document Type"::Invoice;
        PurchaseHeader_gRec.insert(true);
        PurchaseHeader_gRec.validate("Buy-from Vendor No.", getVendorNo(Container_vRec, 0));
        PurchaseHeader_gRec."Pay-to Vendor No." := getVendorNo(Container_vRec, 1);
        if PurchaseHeader_gRec."Pay-to Vendor No." <> PurchaseHeader_gRec."Buy-from Vendor No." then
            PurchaseHeader_gRec.Validate("Pay-to Vendor No.");
        PurchaseHeader_gRec.TestField("Buy-from Vendor No.");
        PurchaseHeader_gRec.TestField("Pay-to Vendor No.");
        if ddnSetup."Reason Code Cont. Prepay" <> '' then
            PurchaseHeader_gRec.validate("Reason Code", ddnSetup."Reason Code Cont. Prepay");
        PurchaseHeader_gRec."Vendor Invoice No." := VendorInvoiceNo_lCode;
        PurchaseHeader_gRec.Modify(true);
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

    /// <summary>
    /// Ermittlung des Kreditors via Bestellzeile
    /// </summary>
    /// <param name="Container_vRec"></param>
    /// <param name="BuyFromOrPayTo"></param>
    /// <returns></returns>
    local procedure getVendorNo(var Container_vRec: Record "trm Container"; BuyFromOrPayTo: Option BuyFrom,PayTo) VendorNo: Code[20]
    var
        PurchLine_lRec: Record "Purchase Line";
    begin
        Container_vRec.TestField("No.");
        PurchLine_lRec.SetRange("trm Container No.", Container_vRec."No.");

        if PurchLine_lRec.FindFirst() then begin
            if BuyFromOrPayTo = BuyFromOrPayTo::BuyFrom then begin
                PurchLine_lRec.SetFilter("Buy-from Vendor No.", '<>''''');
                VendorNo := PurchLine_lRec."Buy-from Vendor No."
            end
            else begin
                PurchLine_lRec.SetFilter("Pay-to Vendor No.", '<>''''');
                VendorNo := PurchLine_lRec."Pay-to Vendor No.";
            end;
        end
        else begin
            error(NoLinesAddedErrorLabel)
        end;
    end;

    local procedure addContainerToInvoice(var Container_vRec: Record "trm Container") LineCount: Integer
    var
        PurchGetReceipt_lCu: codeunit "Purch.-Get Receipt";
        SrcPurchaseLine_lRec: Record "Purchase Line";
        DestPurchaseLine_lRec: Record "Purchase Line";
        LineNo: Integer;
    begin
        SrcPurchaseLine_lRec.SetRange("trm Container No.", Container_vRec."No.");
        SrcPurchaseLine_lRec.setrange("Buy-from Vendor No.", PurchaseHeader_gRec."Buy-from Vendor No.");
        SrcPurchaseLine_lRec.setrange("Pay-to Vendor No.", PurchaseHeader_gRec."Pay-to Vendor No.");
        SrcPurchaseLine_lRec.SetRange(type, SrcPurchaseLine_lRec.type::Item);
        lineCount := SrcPurchaseLine_lRec.Count;


        if SrcPurchaseLine_lRec.FindSet() then begin
            repeat
                // Textzeile mit Daten zum Vorgang
                LineNo += 100000;
                DestPurchaseLine_lRec.init;
                DestPurchaseLine_lRec."Document Type" := PurchaseHeader_gRec."Document Type";
                DestPurchaseLine_lRec."Document No." := PurchaseHeader_gRec."No.";
                DestPurchaseLine_lRec."Line No." := LineNo;
                DestPurchaseLine_lRec.insert(true);



                DestPurchaseLine_lRec.Description := 'Artikel Nr. ' + SrcPurchaseLine_lRec."No.";
                SrcPurchaseLine_lRec.CalcFields("Item No. 2", "COR-DDN Legacy System Item No.");
                if SrcPurchaseLine_lRec."Item No. 2" <> '' then begin
                    DestPurchaseLine_lRec.Description += ', Artikel Nr. Nav18 ' + SrcPurchaseLine_lRec."COR-DDN Legacy System Item No.";
                end;
                DestPurchaseLine_lRec."Description 2" := copystr(SrcPurchaseLine_lRec."trm Container No." + ', ' + SrcPurchaseLine_lRec."Document No.", 1, MaxStrLen(DestPurchaseLine_lRec."Description 2"));
                DestPurchaseLine_lRec.Modify(true);

                // Sachkonto-Zeile
                LineNo += 100000;
                DestPurchaseLine_lRec.init;
                DestPurchaseLine_lRec."Document Type" := PurchaseHeader_gRec."Document Type";
                DestPurchaseLine_lRec."Document No." := PurchaseHeader_gRec."No.";
                DestPurchaseLine_lRec."Line No." := LineNo;
                DestPurchaseLine_lRec.insert(true);
                DestPurchaseLine_lRec.Type := DestPurchaseLine_lRec.type::"G/L Account";
                DestPurchaseLine_lRec.validate("No.", findGlAccount(SrcPurchaseLine_lRec));
                DestPurchaseLine_lRec.Validate(Quantity, SrcPurchaseLine_lRec."Outstanding Quantity");
                if SrcPurchaseLine_lRec."direct unit cost" > 0 then
                    DestPurchaseLine_lRec.Validate("Direct unit cost", SrcPurchaseLine_lRec."Direct Unit Cost");
                if SrcPurchaseLine_lRec."Line Discount %" <> 0 then
                    DestPurchaseLine_lRec.Validate("Line Discount %", SrcPurchaseLine_lRec."Line Discount %");
                SrcPurchaseLine_lRec.CalcFields("Item No. 2");

                DestPurchaseLine_lRec."Description" := SrcPurchaseLine_lRec.Description;
                DestPurchaseLine_lRec."Description 2" := SrcPurchaseLine_lRec."Description 2";

                DestPurchaseLine_lRec.Description := copystr(SrcPurchaseLine_lRec.Description + ', ' + SrcPurchaseLine_lRec."Description 2", 1, maxstrlen(DestPurchaseLine_lRec."Description 2"));
                DestPurchaseLine_lRec.validate("Dimension Set ID", SrcPurchaseLine_lRec."Dimension Set ID");

                // Verweis auf Bestellzeile
                DestPurchaseLine_lRec."Order No." := SrcPurchaseLine_lRec."Document No.";
                DestPurchaseLine_lRec."Order Line No." := SrcPurchaseLine_lRec."Line No.";

                DestPurchaseLine_lRec.Modify(true);
            until SrcPurchaseLine_lRec.next = 0;
        end;
    end;

    local procedure OpenPurchaseInvoice()
    var

    begin
        Page.Run(Page::"Purchase Invoice", PurchaseHeader_gRec);
    end;

    local procedure findGlAccount(var SrcPurchaseLine_lRec: Record "Purchase Line") ret: Code[20]
    var
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        if GeneralPostingSetup.get(SrcPurchaseLine_lRec."Gen. Bus. Posting Group", SrcPurchaseLine_lRec."Gen. Prod. Posting Group") then
            ret := GeneralPostingSetup."Purch. Account";
    end;

    local procedure EnterInvoiceNumber(var Container_vRec: Record "trm Container") VendorInvoiceNo: code[35]
    var
        dialog_lPage: page "COR-DDN Container Inv. Dialog";
        missingVendorInvoiceNoError_lLbl: Label 'You did not enter the vendors invoice no. Without this number it will not be possible to determine a link between the G/L Invoices and the item Invoices.';
    begin
        dialog_lPage.SetContext(getVendorNo(Container_vRec, 0), 0);
        if dialog_lPage.Runmodal() <> Action::OK then
            error('');
        VendorInvoiceNo := dialog_lPage.getVendorInvoiceNo(true);
        if VendorInvoiceNo = '' then
            error(missingVendorInvoiceNoError_lLbl);
        exit(VendorInvoiceNo);
    end;
}
