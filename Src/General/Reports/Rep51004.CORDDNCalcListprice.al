report 51004 "COR-DDN Calc Listprice"
{
    ApplicationArea = All;
    Caption = 'Calculate Listprice for BI';
    UsageCategory = Tasks;
    ProcessingOnly = true;
    dataset
    {
        dataitem(Item; Item)
        {
            RequestFilterFields = "No.";

            trigger OnPreDataItem()
            var
                i, j : Integer;
            begin
                setfilter("trm Item Type", '<>%1', item."trm Item Type"::"Master Item");
                for i := 1 to ArrayLen(ProgressArray) do begin
                    for j := 1 to i do begin
                        if j in [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100] then
                            ProgressArray[i] += '❚';
                    end;
                    ProgressArray[i] += ' ' + format(i) + '%';
                end;

                if GuiAllowed then begin
                    TotalEntryCount := item.count();
                    Status_gDlg.Open(Status_lLbl);
                    Status_gDlg.Update(1, strsubstno('Listenpreis wird für %1 Artikel berechnet.', TotalEntryCount));
                end;
            end;

            trigger OnAfterGetRecord()
            var
                listprice_lDec: Decimal;
                IntercompanyPrice_lDec: Decimal;
            begin
                if GuiAllowed then begin
                    ProgressInt += 1;
                    Status_gDlg.Update(2, item."No.");
                    ProgressArrayPos := round((ProgressInt / TotalEntryCount) * ArrayLen(ProgressArray), 1, '>');
                    Status_gDlg.Update(3, ProgressArray[ProgressArrayPos]);
                end;
                listprice_lDec := Item.getDefaultUnitPrice();
                IntercompanyPrice_lDec := Item.getIntercompanyPrice();
                if listprice_lDec < 0 then
                    listprice_lDec := 0;
                if IntercompanyPrice_lDec < 0 then
                    IntercompanyPrice_lDec := 0;

                if (listprice_lDec <> Item."COR-DDN Listprice") or (IntercompanyPrice_lDec <> Item."COR-DDN Intercompany price") then begin
                    item."COR-DDN Listprice" := listprice_lDec;
                    item."COR-DDN Intercompany price" := IntercompanyPrice_lDec;
                    item.modify(false);
                    countItems_gInt += 1;
                    Commit();
                end;
            end;
        }
    }
    requestpage
    {
        layout
        {

        }
    }

    var
        countItems_gInt: Integer;
        Status_gDlg: Dialog;
        Status_lLbl: Label '#1#################################\\⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯\\Artikel Nr.: #2######\\#3#########', Locked = true;
        ProgressArray: array[100] of Text;
        ProgressInt: Integer;
        TotalEntryCount: Integer;
        ProgressArrayPos: Integer;

    trigger OnPostReport()
    var
        ItemsProcessed_lLbl: Label '%1 items have been modified.';
    begin
        if GuiAllowed then begin
            message(ItemsProcessed_lLbl, countItems_gInt);
        end;
    end;
}
