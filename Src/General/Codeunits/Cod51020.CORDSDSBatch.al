/// <summary>
/// <see cref="#DSDS"/>
/// </summary>
codeunit 51020 "COR DSDS Batch"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        CalcAvailibility();
    end;

    /// <summary>
    /// Es ist hinreichend, die Artikel zu betrachten, die sich in VK-Zeilen befinden
    /// weil EK-Zeilen ohne VK-Zeilen nicht zu eine rNeuterminierung eines frühst möglichen
    /// WA-Datums vorhgandener VK-Zeilen führen können
    /// </summary>
    procedure CalcAvailibility()
    var
        availibilityTools: Codeunit "DDN Availibility Tools";
        SalesLine: Record "Sales Line";
        CountModifiedLines: Integer;
        itemBuffer: Record Item;
        Status_gDlg: Dialog;
        Status_lLbl: Label '#1#################################\\⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯\\Artikel prüfen: #2######\\#3#########\\⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯\\Spezialaufträge prüfen: #4######\\#5#########', Locked = true;
        ProgressArray: array[100] of Text;
        ProgressInt: Integer;
        TotalEntryCount: Integer;
        ProgressArrayPos: Integer;
        i, j : Integer;
        ddnSetup: record "DDN Setup";
    begin
        SalesLine.SetRange(Type, SalesLine.Type::item);
        SalesLine.setrange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.setfilter("Outstanding Qty. (Base)", '>0');
        SalesLine.setfilter("No.", '<>UNKNOWN&<>''''');
        SalesLine.setrange("Special Order", false);
        //SalesLine.SetRange("No.", 'AXH064800DE0');

        ddnSetup.get;
        for i := 1 to ArrayLen(ProgressArray) do begin
            for j := 1 to i do begin
                if j in [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100] then
                    ProgressArray[i] += '❚';
            end;
            ProgressArray[i] += ' ' + format(i) + '%';
        end;

        if SalesLine.findset then
            repeat
                if itemBuffer.get(SalesLine."No.") then begin
                    itemBuffer.Mark(true);
                end;
                // Gerade zu Beginn kann es sein, dass es keine initialen Prioritäten gibt
                QueueUnpriorisedSalesLine(SalesLine);
            until SalesLine.Next() = 0;

        itemBuffer.Markedonly(true);
        if GuiAllowed then begin
            TotalEntryCount := ItemBuffer.count();
            Status_gDlg.Open(Status_lLbl);
            Status_gDlg.Update(1, strsubstno('DSDS wird für %1 Artikel berechnet.', TotalEntryCount));
            Status_gDlg.Update(4, 'ausstehend');
            Status_gDlg.Update(5, '0%');
        end;
        if itemBuffer.findset then
            repeat
                CountModifiedLines += CalcPerItem(itemBuffer);
                if GuiAllowed then begin
                    ProgressInt += 1;
                    Status_gDlg.Update(2, itemBuffer."No.");
                    ProgressArrayPos := round((ProgressInt / TotalEntryCount) * ArrayLen(ProgressArray), 1, '>');
                    Status_gDlg.Update(3, ProgressArray[ProgressArrayPos]);
                end;
                if ddnSetup."DSDS Batch commit per Item" then
                    Commit();
            //Status_gDlg.Update(3, ProgressArray[3]);
            until itemBuffer.Next() = 0;

        // Die Errechnung des frühst möglichen WA-Datums für Special-Order
        // setzt den Fokus auf die VK-Zeile sodass DSDS den Konzekt ermittelt
        // und nur diejenigne Bestellungen listet, die einen bezug zum Auftrag
        // haben
        SalesLine.setrange("Special Order", true);
        SalesLine.SetCurrentKey("No.", "Document Type", "Document No.");
        if GuiAllowed then begin
            TotalEntryCount := SalesLine.count();
            clear(ProgressInt);
            Status_gDlg.Update(1, strsubstno('DSDS wird für %1 VK-Zeilen mit Spezialauftrag berechnet.', TotalEntryCount));
        end;
        if SalesLine.findset then
            repeat
                CountModifiedLines += CalcPerSpecialOrderSalesLine(SalesLine);
                if GuiAllowed then begin
                    ProgressInt += 1;
                    Status_gDlg.Update(4, SalesLine."No.");
                    ProgressArrayPos := round((ProgressInt / TotalEntryCount) * ArrayLen(ProgressArray), 1, '>');
                    Status_gDlg.Update(5, ProgressArray[ProgressArrayPos]);
                end;
                if ddnSetup."DSDS Batch commit per Item" then
                    Commit();
            until SalesLine.Next() = 0;

        if GuiAllowed then
            Status_gDlg.Close();

        if GuiAllowed then
            message('Für %1 Verkaufszeilen wurde das frühst mögliche WA-Datum aktualisiert.', CountModifiedLines);
    end;

    local procedure CalcPerItem(var Item_iRec: Record Item) countModifiedLines: Integer
    var
        dsdsAvailitbilityMgmt_lCodeUnit: Codeunit "COR DSDS Availibility Mgmt.";
        scheduleLine: Record "COR DSDS Schedule Line" temporary;
        SalesLine: Record "Sales Line";
        ddnSetup: Record "DDN Setup";
    begin
        ddnSetup.get();
        dsdsAvailitbilityMgmt_lCodeUnit.InitObject(Item_iRec."No.", '');
        dsdsAvailitbilityMgmt_lCodeUnit.createSchedule(ddnSetup."DSDS Batch Priority Model");
        dsdsAvailitbilityMgmt_lCodeUnit.TransferPriorityFromScheduleToSalesLine_lFunction(false);
        // DSDS ignoriert mit Aufruf aus Artikelsicht EK- und VK-Zeilen zu Spezialaufträgen
        countModifiedLines := dsdsAvailitbilityMgmt_lCodeUnit.UpdateSalesLinesWithKnowledeAboutShipment();
    end;

    local procedure CalcPerSpecialOrderSalesLine(var SalesLine_vRec: Record "Sales Line") countModifiedLines: Integer
    var
        dsdsAvailitbilityMgmt_lCodeUnit: Codeunit "COR DSDS Availibility Mgmt.";
        scheduleLine: Record "COR DSDS Schedule Line" temporary;
        ddnSetup: Record "DDN Setup";
    begin
        ddnSetup.get();
        dsdsAvailitbilityMgmt_lCodeUnit.InitObject(SalesLine_vRec."No.", '');
        dsdsAvailitbilityMgmt_lCodeUnit.SetFocusOnSalesLine(SalesLine_vRec);
        dsdsAvailitbilityMgmt_lCodeUnit.createSchedule(ddnSetup."DSDS Batch Priority Model");
        dsdsAvailitbilityMgmt_lCodeUnit.TransferPriorityFromScheduleToSalesLine_lFunction(false);
        // DSDS ignoriert mit Aufruf aus Artikelsicht EK- und VK-Zeilen zu Spezialaufträgen
        countModifiedLines := dsdsAvailitbilityMgmt_lCodeUnit.UpdateSalesLinesWithKnowledeAboutShipment();
    end;

    local procedure QueueUnpriorisedSalesLine(var SalesLine_iRec: Record "Sales Line")
    var
        dsdsAvailitbilityMgmt_lCodeUnit: Codeunit "COR DSDS Availibility Mgmt.";
    begin
        dsdsAvailitbilityMgmt_lCodeUnit.QueueUnpriorisedSalesLine(SalesLine_iRec, true);
    end;
}
