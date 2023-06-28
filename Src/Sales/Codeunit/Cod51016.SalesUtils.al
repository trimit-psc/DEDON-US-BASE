// codeunit partially copied from NAV2018 an changed slightly for BC
/// <summary>
/// <see cref="#TW84"/>
/// </summary>      
codeunit 51016 "COR-DDN Legacy Sales Utils"
{
    procedure ChoseTrackingAndCreateReservationEntriesForSalesLine(var salesLine_p: Record "Sales Line")
    var
        itemLedgerEntryTemp_l: Record "Item Ledger Entry" temporary;
        reservEntry_l: Record "Reservation Entry";
        item_l: Record Item;
        dedonUtils_l: Codeunit "Dedon Utils";
        ItemLocationInventoryPage_l: Page "Item Location Inventory";
        qtySUOM: Decimal;
        qty_l: Decimal;
        initialTrackedQty_l: Decimal;
        subtype_l: Integer;
        hasTracking_l: Boolean;
    begin
        salesLine_p.TESTFIELD(Type, salesLine_p.Type::Item);

        item_l.GET(salesLine_p."No.");
        item_l.TESTFIELD("Item Tracking Code");

        itemLedgerEntryTemp_l.RESET;
        if not itemLedgerEntryTemp_l.IsTemporary then
            error('CU51016 arbeitet nicht mit temporärgen Artikelposten.');
        itemLedgerEntryTemp_l.DELETEALL;


        GetItemInventoryGroupedByTrackingFromSalesLine(salesLine_p, itemLedgerEntryTemp_l);


        CLEAR(ItemLocationInventoryPage_l);
        ItemLocationInventoryPage_l.SetSelection(itemLedgerEntryTemp_l);
        ItemLocationInventoryPage_l.LOOKUPMODE(TRUE);
        IF ItemLocationInventoryPage_l.RUNMODAL() <> ACTION::LookupOK THEN
            EXIT;

        ItemLocationInventoryPage_l.GetSelection(itemLedgerEntryTemp_l);
        itemLedgerEntryTemp_l.CALCSUMS("Remaining Quantity");

        qty_l := itemLedgerEntryTemp_l."Remaining Quantity";
        subtype_l := salesLine_p."Document Type";
        hasTracking_l := dedonUtils_l.HasTracking(FORMAT(DATABASE::"Sales Line"),
                                                   FORMAT(subtype_l),
                                                   salesLine_p."Document No.",
                                                   FORMAT(salesLine_p."Line No."),
                                                   '',
                                                   '',
                                                   '');

        IF NOT itemLedgerEntryTemp_l.FINDSET THEN
            EXIT;

        IF hasTracking_l THEN
            salesLine_p.Quantity += qty_l
        ELSE
            salesLine_p.Quantity := qty_l;

        salesLine_p.VALIDATE(Quantity);
        salesLine_p.MODIFY();

        REPEAT

            dedonUtils_l.CreateUpdateReservationEntry(DATABASE::"Sales Line",
                                                      salesLine_p."Document Type",
                                                      salesLine_p."Document No.",
                                                      salesLine_p."Line No.",
                                                      FALSE,
                                                      reservEntry_l."Reservation Status"::Surplus,
                                                      salesLine_p."No.",
                                                      salesLine_p."Variant Code",
                                                      salesLine_p."Location Code",
                                                      itemLedgerEntryTemp_l."Lot No.",
                                                      itemLedgerEntryTemp_l."Serial No.",
                                                      //qtyBase
                                                      itemLedgerEntryTemp_l.Quantity,
                                                      //qty
                                                      itemLedgerEntryTemp_l."Remaining Quantity",
                                                      0D,
                                                      0);

        UNTIL itemLedgerEntryTemp_l.NEXT = 0;
    end;

    // function copied from NAV2018 an changed slightly for BC
    /// <summary>
    /// <see cref="#TW84"/>
    /// </summary>      

    procedure GetItemInventoryGroupedByTrackingFromSalesLine(salesLine_p: Record "Sales Line"; VAR itemLedgerEntryTemp_p: Record "Item Ledger Entry" temporary)
    var
        dedonUtils_l: Codeunit "Dedon Utils";
        resrvEntry_l: Record "Reservation Entry";
        item_l: Record Item;
        itemIventoryQ_l: Query "Item Inventory";
        entryNo_l: Integer;
        reservedQty_l: Decimal;
        qtyBase_l: Decimal;
        qty_l: Decimal;
    begin
        salesLine_p.TESTFIELD(Type, salesLine_p.Type::Item);
        itemIventoryQ_l.SETRANGE(Item_No, salesLine_p."No.");
        itemIventoryQ_l.SETRANGE(Variant_Code, salesLine_p."Variant Code");
        itemIventoryQ_l.SETRANGE(Location_Code, salesLine_p."Location Code");
        IF NOT itemIventoryQ_l.OPEN THEN
            EXIT;

        WHILE itemIventoryQ_l.READ DO BEGIN
            IF NOT item_l.GET(itemIventoryQ_l.Item_No) THEN
                CLEAR(item_l);
            reservedQty_l := dedonUtils_l.CalcResrvQtyToHandleBase('',
                                                                    '',
                                                                    '',
                                                                    '',
                                                                    itemIventoryQ_l.Lot_No,
                                                                    itemIventoryQ_l.Serial_No,
                                                                    STRSUBSTNO('<>%1', resrvEntry_l."Reservation Status"::Reservation),
                                                                    itemIventoryQ_l.Item_No,
                                                                    itemIventoryQ_l.Location_Code,
                                                                    FALSE);

            reservedQty_l += dedonUtils_l.CalcResrvQtyToHandleBase(FORMAT(DATABASE::"Sales Line"),
                                                                    '',
                                                                    '',
                                                                    '',
                                                                    itemIventoryQ_l.Lot_No,
                                                                    itemIventoryQ_l.Serial_No,
                                                                    FORMAT(resrvEntry_l."Reservation Status"::Reservation),
                                                                    itemIventoryQ_l.Item_No,
                                                                    itemIventoryQ_l.Location_Code,
                                                                    FALSE);


            qtyBase_l := itemIventoryQ_l.Sum_Remaining_Quantity - reservedQty_l;
            qty_l := dedonUtils_l.CalcQtyToUOM(item_l."No.",
                                               item_l."Base Unit of Measure",
                                               salesLine_p."Unit of Measure Code",
                                               qtyBase_l);

            entryNo_l += 1;
            itemLedgerEntryTemp_p.INIT;
            itemLedgerEntryTemp_p."Entry No." := entryNo_l;
            itemLedgerEntryTemp_p."Item No." := itemIventoryQ_l.Item_No;
            itemLedgerEntryTemp_p."Variant Code" := itemIventoryQ_l.Variant_Code;
            itemLedgerEntryTemp_p."Location Code" := itemIventoryQ_l.Location_Code;
            itemLedgerEntryTemp_p."Lot No." := itemIventoryQ_l.Lot_No;
            itemLedgerEntryTemp_p."Serial No." := itemIventoryQ_l.Serial_No;
            itemLedgerEntryTemp_p.Quantity := itemIventoryQ_l.Sum_Remaining_Quantity - reservedQty_l;
            itemLedgerEntryTemp_p."Remaining Quantity" := qty_l;
            IF itemLedgerEntryTemp_p.Quantity > 0 THEN
                itemLedgerEntryTemp_p.INSERT;
        END;

        itemLedgerEntryTemp_p.RESET;
    end;
}