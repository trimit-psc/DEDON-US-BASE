codeunit 51007 "DDN Purchase Trigger Pool"
{
    var
        ConfirmUpdateOrigQtyDlg: Label 'Original quantity has already been set. Do you want to overwrite it for %1 lines?', Comment = 'für die Abfrage bei Freigabe eines EK-Belegs';
    /// <summary>
    /// ReleasePurchasedocumentOnBeforeReleasePurchaseDocSubScr.
    /// <see href="#6SWK"/>
    /// </summary>
    /// <param name="PurchaseHeader">VAR Record "Purchase Header".</param>
    /// <param name="PreviewMode">Boolean.</param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Purchase Document", 'OnBeforeReleasePurchaseDoc', '', false, false)]
    local procedure ReleasePurchasedocumentOnBeforeReleasePurchaseDocSubScr(var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean)
    begin
        if PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Order then
            transferQtyToOriginalQty(PurchaseHeader);
    end;

    /// <summary>
    /// transferQtyTooriginalQty.
    /// <see cref="#6SWK"/>
    /// </summary>
    /// <param name="PurchaseHeader_iRec">VAR Record "Purchase Header".</param>
    local procedure transferQtyToOriginalQty(var PurchaseHeader_iRec: Record "Purchase Header")
    var
        purchaseLine_lRec: Record "Purchase Line";
        po: page "purchase Order";
        showDialog_lBool: Boolean;
        confirmed_lBool: Boolean;
        origQtyAlreadySetBefore_lBool: Boolean;
        countLineWithChangedQty_lInt: Integer;
    // Die Ursprungsmenge wurde bereits in der Vergangenheit festgelegt. Soll sie für %1 Zeilen überschrieben werden?

    begin
        purchaseLine_lRec.SetRange("Document Type", PurchaseHeader_iRec."Document Type");
        purchaseLine_lRec.setrange("Document No.", PurchaseHeader_iRec."No.");
        purchaseLine_lRec.setrange(type, purchaseLine_lRec.Type::Item);
        purchaseLine_lRec.SetLoadFields(Quantity, "DDN Original Qty.");

        // Zeilen filtern mit Menge ungleich 0 --> Indiz, dass bereits einmal die Orignalmenge berechnet wurde
        purchaseLine_lRec.setfilter("DDN Original Qty.", '<>0');
        origQtyAlreadySetBefore_lBool := not purchaseLine_lRec.IsEmpty();
        // Prüfung auf Mengenunterscheidungen bei allen Zeilen
        purchaseLine_lRec.setrange("DDN Original Qty.");
        if purchaseLine_lRec.findset then
            repeat
                if purchaseLine_lRec."DDN Original Qty." <> purchaseLine_lRec.Quantity then begin
                    purchaseLine_lRec.Mark(true);
                end
            until purchaseLine_lRec.next = 0;

        purchaseLine_lRec.MarkedOnly(true);
        if purchaseLine_lRec.IsEmpty then
            exit;

        if origQtyAlreadySetBefore_lBool then begin
            confirmed_lBool := Confirm(ConfirmUpdateOrigQtyDlg, false, purchaseLine_lRec.Count);
        end
        else begin
            confirmed_lBool := true;
        end;

        if not confirmed_lBool then
            exit;
        // Zeilen mit unterschiedlichen Werten überarbeiten
        if purchaseLine_lRec.FindSet() then
            repeat
                purchaseLine_lRec."DDN Original Qty." := purchaseLine_lRec.Quantity;
                purchaseLine_lRec.modify;
            until purchaseLine_lRec.Next() = 0;
    end;

    /// <summary>
    /// Bei Freigabe der EK-Bestellung soll direkt ein WE erzeugt und
    /// dieser ggf. an Jungheinrich übermitelt werden;
    /// <see cref="#M9LS"/>
    /// </summary>
    /// <param name="PurchaseHeader"></param>
    /// <param name="PreviewMode"></param>
    /// <param name="LinesWereModified"></param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Purchase Document", 'OnAfterReleasePurchaseDoc', '', false, false)]
    local procedure PurchaseTriggerPoolOnAfterReleasePurchaseDoc(var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean; var LinesWereModified: Boolean)
    var
        Vendor_lRec: Record Vendor;
        GetSourceDocInbound: Codeunit "Get Source Doc. Inbound";
        WhseRqst: Record "Warehouse Request";
        WarehouseReceiptHeader: Record "Warehouse Receipt Header";
        WarehouseReceiptLine: Record "Warehouse Receipt Line";
        ddnSetup: Record "DDN Setup";
        wrec: page "Warehouse Receipt";
    begin
        if PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::Order then
            exit;
        ddnSetup.get();
        // nur für Lager Winsen
        if PurchaseHeader."Location Code" <> ddnSetup."Location Code 1_WMS" then
            exit;
        if not Vendor_lRec.get(PurchaseHeader."Buy-from Vendor No.") then
            exit;
        if Vendor_lRec."COR-DDN auto create Whse. Receipt" = Vendor_lRec."COR-DDN auto create Whse. Receipt"::"do nothing" then
            exit;

        if GetSourceDocInbound.CreateFromPurchOrderHideDialog(PurchaseHeader) then begin
            if Vendor_lRec."COR-DDN auto create Whse. Receipt" = Vendor_lRec."COR-DDN auto create Whse. Receipt"::"create Receipt + release JH" then begin
                WarehouseReceiptLine.SetLoadFields("No.");
                WarehouseReceiptLine.SetRange("Source Document", WarehouseReceiptLine."Source Document"::"Purchase Order");
                WarehouseReceiptLine.setrange("Source No.", PurchaseHeader."No.");
                if WarehouseReceiptLine.findlast then begin
                    WarehouseReceiptHeader.get(WarehouseReceiptLine."No.");
                    // TODO ReactivateJungheinrichCode following 4 Lines
                    if WarehouseReceiptHeader."Status JH" = WarehouseReceiptHeader."Status JH"::New then begin
                        WarehouseReceiptHeader.Validate("Status JH", WarehouseReceiptHeader."Status JH"::"Released to WMS");
                        WarehouseReceiptHeader.modify();
                    end;
                end;
            end;
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"purch. rcpt. Line", 'OnAfterDescriptionPurchaseLineInsert', '', false, false)]
    local procedure PurchRcptLineOnAfterDescriptionSalesLineInsertOnAfterDescriptionPurchaseLineInsert(var PurchLine: Record "Purchase Line"; PurchRcptLine: Record "Purch. Rcpt. Line"; var NextLineNo: Integer; var TempPurchaseLine: Record "Purchase Line" temporary)
    var
        PurchaseLineForExtraText_lRec: Record "Purchase Line";
        OrderNo_lLbl: Label 'Order No. %1:';
        OrderNoText_lTxt: Text;
        PurchRcptHeader_lRec: Record "Purch. Rcpt. Header";
        TranslationHelper: Codeunit "Translation Helper";
    begin
        PurchRcptHeader_lRec.get(PurchRcptLine."Document No.");
        if PurchRcptLine."Order No." <> '' then begin
            NextLineNo += 10000;
            PurchaseLineForExtraText_lRec."Document Type" := PurchLine."Document Type";
            PurchaseLineForExtraText_lRec."Document No." := PurchLine."Document No.";
            PurchaseLineForExtraText_lRec."Line No." := NextLineNo;
            TranslationHelper.SetGlobalLanguageByCode(PurchRcptHeader_lRec."Language Code");
            // Fallback falls keine Übersetzung ermittlet wurde;
            OrderNoText_lTxt := OrderNo_lLbl;
            if OrderNoText_lTxt = '' then
                OrderNoText_lTxt := 'Bestellung Nr. %1:';
            PurchaseLineForExtraText_lRec.Description := StrSubstNo(OrderNoText_lTxt, PurchRcptLine."Order No.");
            TranslationHelper.RestoreGlobalLanguage;
            PurchaseLineForExtraText_lRec.insert;
        end;
    end;

    /// <summary>
    /// Bei den Artikelrechnungen aus Containern, denen eine Sachkontorechnung vorangegangen ist
    /// darf keine Änderung des Währungswechselkurses stattfinden
    /// <see cref="#AT4L"/>
    /// </summary>

    [EventSubscriber(ObjectType::Table, DATABASE::"Purchase Header", 'OnBeforeUpdateCurrencyFactor', '', false, false)]
    local procedure PurchaseHeaderOnBeforeUpdateCurrencyFactor(var PurchaseHeader: Record "Purchase Header"; var Updated: Boolean; var CurrencyExchangeRate: Record "Currency Exchange Rate"; CurrentFieldNo: Integer)
    var
        ddnSetup: Record "DDN Setup";
        CurrencyExchangeRateNotChanged_lLbl: Label 'The currency exchange rate was not changed because the incoive has a relation to a g/l invoice wich was posted previously.';
    begin
        if PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::Invoice then
            exit;
        ddnSetup.get();
        if ddnSetup."Reason Code Cont. Final Inv." = '' then
            exit;
        if PurchaseHeader."Reason Code" = ddnSetup."Reason Code Cont. Final Inv." then begin
            message(CurrencyExchangeRateNotChanged_lLbl);
            updated := true;
        end;
    end;

    /// <summary>
    /// Fehlenbde Artikelübersetzung im Einkauf
    /// <see cref="https://dedongroup.atlassian.net/browse/DEDT-473"/>
    /// </summary>
    /// <param name="PurchaseLine">VAR Record "Purchase Line".</param>
    /// <param name="IsHandled">VAR Boolean.</param>
    [EventSubscriber(ObjectType::Table, DATABASE::"Purchase Line", 'OnBeforeGetItemTranslation', '', false, false)]
    local procedure OnBeforeGetItemTranslation(var PurchaseLine: Record "Purchase Line"; var IsHandled: Boolean)
    var
    begin
        PurchaseLine.trmGetTranslation(PurchaseLine."No.", PurchaseLine.Description, PurchaseLine."Description 2");
        IsHandled := true;
    end;
}
