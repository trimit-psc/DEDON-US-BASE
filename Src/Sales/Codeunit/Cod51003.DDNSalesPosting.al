/// <summary>
/// Codeunit DDN Sales Posting (ID 51003).
/// </summary>
codeunit 51003 "DDN Sales Posting"
{
    Permissions = tabledata "Item Ledger Entry" = rm, tabledata "Value Entry" = rm;

    /// <summary>
    /// Schreibt die Masternummer des Masters, über den die Konfuiguration erfolgte in Artikelposten und Wertposten.
    /// </summary>
    /// <see cref="#DM4X"/>
    /// <see cref="#9LUF Menge Set in Belegzeile und Posten"/>
    /// <param name="ValueEntry_viRec">VAR Record "Value Entry".</param>
    /// <param name="MasterNo_iCod">code[20].</param>
    local procedure assingSetMasterNoToValueEntryAndLedgerEntry(var ValueEntry_viRec: Record "Value Entry"; MasterNo_iCod: code[20]; ItemNo_iCod: code[20]; setQuantity_pDec: Decimal)
    var
        ItemLedgerEntry_lRec: Record "Item Ledger Entry";
    begin
        ValueEntry_viRec."DDN Set Master No." := MasterNo_iCod;
        ValueEntry_viRec."DDN Set Item No." := ItemNo_iCod;
        ValueEntry_viRec."COR-DDN Set Quantity" := setQuantity_pDec;
        ValueEntry_viRec.Modify(false);
        if ValueEntry_viRec."Item Ledger Entry No." <> 0 then begin
            if ItemLedgerEntry_lRec.get(ValueEntry_viRec."Item Ledger Entry No.") then begin
                ItemLedgerEntry_lRec."DDN Set Master No." := MasterNo_iCod;
                ItemLedgerEntry_lRec."DDN Set Item No." := ItemNo_iCod;
                // #9LUF Menge Set in Belegzeile und Posten
                ItemLedgerEntry_lRec."COR-DDN Set Quantity" := setQuantity_pDec;
                ItemLedgerEntry_lRec.Modify(false);
            end;
        end;
    end;

    /// <summary>
    /// <see cref="#7JRN"/>
    /// </summary>
    /// <param name="ValueEntry_viRec"></param>
    /// <param name="ContainerNo_iCod"></param>
    local procedure assingContainerToValueEntryAndLedgerEntry(var ValueEntry_viRec: Record "Value Entry"; ContainerNo_iCod: code[20])
    var
        DDNPurchPost_lCodeUnit: Codeunit "DDN Purch Post";
    begin
        DDNPurchPost_lCodeUnit.assingContainerToValueEntryAndLedgerEntry(ValueEntry_viRec, ContainerNo_iCod);
    end;

    /// <summary>
    /// Aus dem URsprungsbeleg wird kurz vor Abschluss der Buchung eine Übertragung der Config-Artikelnummer auf 
    /// die Komponenten ausgelöst.
    /// </summary>
    /// <param name="VAR SalesHeader">Record "Sales Header".</param>
    /// <param name="VAR SalesShipmentHeader">Record "Sales Shipment Header".</param>
    /// <param name="VAR SalesInvoiceHeader">Record "Sales Invoice Header".</param>
    /// <param name="VAR SalesCrMemoHeader">Record "Sales Cr.Memo Header".</param>
    /// <param name="VAR ReturnReceiptHeader">Record "Return Receipt Header".</param>
    /// <param name="GenJnlPostLine">Codeunit "Gen. Jnl.-Post Line".</param>
    /// <param name="CommitIsSuppressed">Boolean.</param>
    /// <param name="PreviewMode">Boolean.</param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterFinalizePostingOnBeforeCommit', '', false, false)]
    local procedure SalesPostOnAfterFinalizePostingOnBeforeCommitSubScr(VAR SalesHeader: Record "Sales Header"; VAR SalesShipmentHeader: Record "Sales Shipment Header"; VAR SalesInvoiceHeader: Record "Sales Invoice Header"; VAR SalesCrMemoHeader: Record "Sales Cr.Memo Header"; VAR ReturnReceiptHeader: Record "Return Receipt Header"; GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; CommitIsSuppressed: Boolean; PreviewMode: Boolean)
    var
        ValueEntry_lRec: Record "Value Entry";
        salesInvoiceLine_lRec: Record "Sales Invoice Line";
        salesCrMemoLine_lRec: Record "Sales Cr.Memo Line";
        salesShipmentLine_lRec: Record "Sales Shipment Line";
    begin
        ValueEntry_lRec.SetLoadFields("Document Type", "Document No.", "Document Line No.");

        if SalesShipmentHeader."No." <> '' then begin
            ValueEntry_lRec.SetRange("Document Type", ValueEntry_lRec."Document Type"::"Sales Shipment");
            ValueEntry_lRec.SetRange("Document No.", SalesShipmentHeader."No.");
            if ValueEntry_lRec.findset then begin
                salesShipmentLine_lRec.SetLoadFields("DDN Set Master No.");
                repeat
                    if salesShipmentLine_lRec.get(SalesShipmentHeader."No.", ValueEntry_lRec."Document Line No.") then begin
                        assingSetMasterNoToValueEntryAndLedgerEntry(ValueEntry_lRec, salesShipmentLine_lRec."DDN Set Master No.", salesShipmentLine_lRec."DDN Set Item No.", salesShipmentLine_lRec."COR-DDN Set Quantity");
                        assingContainerToValueEntryAndLedgerEntry(ValueEntry_lRec, salesShipmentLine_lRec."trm Container No.");
                    end;
                until ValueEntry_lRec.next = 0;
            end;
        end;

        if (SalesInvoiceHeader."No." <> '') then begin
            ValueEntry_lRec.SetRange("Document Type", ValueEntry_lRec."Document Type"::"Sales Invoice");
            ValueEntry_lRec.SetRange("Document No.", SalesInvoiceHeader."No.");
            if ValueEntry_lRec.findset then begin
                salesInvoiceLine_lRec.SetLoadFields("DDN Set Master No.");
                repeat
                    if salesInvoiceLine_lRec.get(SalesInvoiceHeader."No.", ValueEntry_lRec."Document Line No.") then begin
                        assingSetMasterNoToValueEntryAndLedgerEntry(ValueEntry_lRec, salesInvoiceLine_lRec."DDN Set Master No.", salesInvoiceLine_lRec."DDN Set Item No.", salesInvoiceLine_lRec."COR-DDN Set Quantity");
                        assingContainerToValueEntryAndLedgerEntry(ValueEntry_lRec, salesInvoiceLine_lRec."trm Container No.");
                    end;
                until ValueEntry_lRec.next = 0;
            end;
        end;

        if (SalesCrMemoHeader."No." <> '') then begin
            ValueEntry_lRec.SetRange("Document Type", ValueEntry_lRec."Document Type"::"Sales Credit Memo");
            ValueEntry_lRec.SetRange("Document No.", SalesCrMemoHeader."No.");
            if ValueEntry_lRec.findset then begin
                salesCrMemoLine_lRec.SetLoadFields("DDN Set Master No.");
                repeat
                    if salesCrMemoLine_lRec.get(SalesInvoiceHeader."No.", ValueEntry_lRec."Document Line No.") then begin
                        assingSetMasterNoToValueEntryAndLedgerEntry(ValueEntry_lRec, salesCrMemoLine_lRec."DDN Set Master No.", salesCrMemoLine_lRec."DDN Set Item No.", salesCrMemoLine_lRec."COR-DDN Set Quantity");
                    end;
                until ValueEntry_lRec.next = 0;
            end;
        end;
    end;

    /// <summary>
    /// Buchungsgruppen aus der Lieferanschrift in den Auftrag übernehmen. Der Trigger greift bei Umstellung der Lieferanschrift
    /// <see cref="#CTDG"/>
    /// </summary>
    /// <param name="SalesHeader">VAR Record "Sales Header".</param>
    /// <param name="ShipToAddress">Record "Ship-to Address".</param>
    /// <param name="xSalesHeader">Record "Sales Header".</param>
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterCopyShipToCustomerAddressFieldsFromShipToAddr', '', false, false)]
    local procedure SalesHeaderOnAfterCopyShipToCustomerAddressFieldsFromShipToAddr(var SalesHeader: Record "Sales Header"; ShipToAddress: Record "Ship-to Address"; xSalesHeader: Record "Sales Header")
    var
    begin
        applyPostingGroups(SalesHeader, ShipToAddress."Gen. Bus. Posting Group", ShipToAddress."VAT Bus. Posting Group");
    end;
    /// <summary>
    /// Der Trigger grefit nachdem beim erstmaligen Anlegen des Auftrags der Debitor eingetragen und durhc Trimit ggf. die Standard-Lieferanschrift gesetzt wurde
    /// </summary>
    /// <param name="SalesHeader">VAR Record "Sales Header".</param>
    /// <param name="xSalesHeader">Record "Sales Header".</param>
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnValidateSellToCustomerNoOnBeforeRecallModifyAddressNotification', '', false, false)]
    local procedure SalesHeaderOnValidateSellToCustomerNoOnBeforeRecallModifyAddressNotificationSubScr(var SalesHeader: Record "Sales Header"; xSalesHeader: Record "Sales Header")
    var
        ShipToAddress: Record "Ship-to Address";
    begin
        if SalesHeader."Ship-to Code" = xSalesHeader."Ship-to Code" then
            exit;
        applyPostingGroupsViaShipToAddress(SalesHeader);
    end;

    /// <summary>
    /// Buchungsgruppen aus dem Kunden in den Auftrag übernehmen.
    /// Der Subscriber ist notwendig weil durch Änderung einer Lieferadresse die Buchungsgruppen überschrioeben werden können.
    /// Der Subscriber revidiert die Zuordnung aus der Lieferanschrift somit.
    /// <see cref="#CTDG"/>
    /// </summary>
    /// <param name="SalesHeader">VAR Record "Sales Header".</param>
    /// <param name="SellToCustomer">Record Customer.</param>
    /// <param name="xSalesHeader">Record "Sales Header".</param>
    [EventSubscriber(ObjectType::Table, 36, 'OnAfterCopyShipToCustomerAddressFieldsFromCustomer', '', false, false)]
    local procedure SalesHeaderOnAfterCopyShipToCustomerAddressFieldsFromCustomer(var SalesHeader: Record "Sales Header"; SellToCustomer: Record Customer; xSalesHeader: Record "Sales Header")
    var
    begin
        applyPostingGroups(SalesHeader, SellToCustomer."Gen. Bus. Posting Group", SellToCustomer."VAT Bus. Posting Group");
    end;

    /// <summary>
    /// Buchungsgruppen aus der Debitorenvorlage in den Auftrag übernehmen.
    /// Der Subscriber ist notwendig weil durch Änderung einer Lieferadresse die Buchungsgruppen überschrioeben werden können.
    /// Der Subscriber revidiert die Zuordnung aus der Lieferanschrift somit.
    /// <see cref="#CTDG"/>
    /// </summary>
    /// <param name="SalesHeader">VAR Record "Sales Header".</param>
    /// <param name="SellToCustTemplate">Record "Customer Templ.".</param>
    [EventSubscriber(ObjectType::Table, 36, 'OnAfterCopyFromNewSellToCustTemplate', '', false, false)]
    local procedure SalesHeaderOnAfterCopyFromNewSellToCustTemplate(var SalesHeader: Record "Sales Header"; SellToCustTemplate: Record "Customer Templ.")
    var
    begin
        applyPostingGroups(SalesHeader, SellToCustTemplate."Gen. Bus. Posting Group", SellToCustTemplate."VAT Bus. Posting Group");
    end;

    /// <summary>
    /// Andert die Geschäftsbuchungsgruppe und die MwSt Geschäftsbuchungsgruppe in einem VK-Dokument.
    /// Hilfsfunktion für Subscriber
    /// <see cref="#CTDG"/>
    /// </summary>
    /// <param name="salesHeader_iRec">VAR record "Sales Header".</param>
    /// <param name="GenBusPostingGroup_iCod">Code[20].</param>
    /// <param name="VatBusPostingGroup_iCod">Code[20].</param>
    local procedure applyPostingGroups(var salesHeader_iRec: record "Sales Header"; GenBusPostingGroup_iCod: Code[20]; VatBusPostingGroup_iCod: Code[20])
    var
        GenBusPostingGrp: Record "Gen. Business Posting Group";
    begin
        begin
            if GenBusPostingGroup_iCod <> '' then begin
                if GenBusPostingGroup_iCod <> salesHeader_iRec."Gen. Bus. Posting Group" then begin
                    //GenBusPostingGrp.ValidateVatBusPostingGroup(GenBusPostingGrp, salesHeader_iRec."Gen. Bus. Posting Group")
                    salesHeader_iRec.Validate("Gen. Bus. Posting Group", GenBusPostingGroup_iCod);
                end;
            end;
            if VatBusPostingGroup_iCod <> '' then begin
                if VatBusPostingGroup_iCod <> salesHeader_iRec."VAT Bus. Posting Group" then begin
                    salesHeader_iRec.Validate("VAT Bus. Posting Group", VatBusPostingGroup_iCod);
                end;
            end;
        end;
    end;

    /// <summary>
    /// <see cref="#DTDG"/>
    /// </summary>
    /// <param name="salesHeader_iRec"></param>
    local procedure applyPostingGroupsViaShipToAddress(var salesHeader_iRec: record "Sales Header")
    var
        ShipToAddress_lRec: Record "Ship-to Address";
    begin
        if salesHeader_iRec."Ship-to Code" = '' then
            exit;
        if not ShipToAddress_lRec.Get(salesHeader_iRec."Sell-to Customer No.", salesHeader_iRec."Ship-to Code") then
            exit;
        applyPostingGroups(salesHeader_iRec, ShipToAddress_lRec."Gen. Bus. Posting Group", ShipToAddress_lRec."VAT Bus. Posting Group");
    end;
}