/// <summary>
/// <see cref="#FV2D"/>
/// </summary>
codeunit 51011 "DDN Forecast Import"
{
    TableNo = "Production Forecast Name";

    trigger OnRun()
    var
        ExcelBuffer_lRec: Record "Excel Buffer" temporary;
    begin
        clearProductionForecast_lFnc(Rec);

        ImportExcelFile_lFnc(ExcelBuffer_lRec);
        LoopThroughBuffer_lFnc(Rec, ExcelBuffer_lRec);
    end;

    local procedure ImportExcelFile_lFnc(var ExcelBuffer_vRec: Record "Excel Buffer" temporary)
    var
        FileMgt_lCdu: Codeunit "File Management";
        Sheetname_lTxt: Text;
        FromFileDummy_lTxt: Text;
        lIsr: InStream;
    begin
        Clear(ExcelBuffer_vRec);
        if File.UploadIntoStream(ImportFile_gLbl, '', FileMgt_lCdu.GetToFilterText('', '*.XLSX'), FromFileDummy_lTxt, lIsr) then begin
            Sheetname_lTxt := ExcelBuffer_vRec.SelectSheetsNameStream(lIsr);
            ExcelBuffer_vRec.OpenBookStream(lIsr, Sheetname_lTxt);
            ExcelBuffer_vRec.ReadSheet();
        end;
    end;

    local procedure LoopThroughBuffer_lFnc(ProdForecastName_iRec: Record "Production Forecast Name"; var ExcelBuffer_vRec: Record "Excel Buffer" temporary)
    var
        ItemNoImported_lTxt: Text;
        QuantityImported_lTxt: Text;
        LocationCodeImported_lTxt: Text;
        ForecastDateImported_lTxt: Text;
        QuantityImported_lDec: Decimal;
        ForecastDateImported_lDat: Date;
        LastRowNo_lInt: Integer;
    begin
        ExcelBuffer_vRec.Reset();
        if ExcelBuffer_vRec.FindSet(false, false) then
            repeat
                if ExcelBuffer_vRec."Row No." > 1 then begin // skip headlines
                    case ExcelBuffer_vRec."Column No." of
                        1:
                            ItemNoImported_lTxt := ExcelBuffer_vRec."Cell Value as Text";
                        2:
                            begin
                                QuantityImported_lTxt := ExcelBuffer_vRec."Cell Value as Text";
                                if Evaluate(QuantityImported_lDec, QuantityImported_lTxt) then;
                            end;
                        3:
                            LocationCodeImported_lTxt := ExcelBuffer_vRec."Cell Value as Text";
                        4:
                            begin
                                ForecastDateImported_lTxt := ExcelBuffer_vRec."Cell Value as Text";
                                if Evaluate(ForecastDateImported_lDat, ForecastDateImported_lTxt) then;

                                ProcessLine(ProdForecastName_iRec, ItemNoImported_lTxt, LocationCodeImported_lTxt, ForecastDateImported_lDat, QuantityImported_lDec);

                                Clear(ItemNoImported_lTxt);
                                Clear(QuantityImported_lTxt);
                                Clear(QuantityImported_lDec);
                                Clear(LocationCodeImported_lTxt);
                                Clear(ForecastDateImported_lTxt);
                                Clear(ForecastDateImported_lDat);
                            end;
                        else
                            Error(TooManyColumns_gLbl);
                    end;
                end;
            until ExcelBuffer_vRec.Next() = 0;
    end;

    /// <summary>
    /// Verarbeitet eine Zeile der Bedarfsplanung. Im Zuge der Abarbeitung wird geprüft, ob der Artikel oder der
    /// Master eine Stückliste führen. In dem Fall wird die Stückliste temporär aufgebaut und die Komponenten
    /// anstelle des Artikels gelangen in die Bedarfsplanung
    /// </summary>
    /// <param name="ItemNo_iCod">Die Artikelnummer kann sowohl ein Set als auch eine einzelne Komponente sein.</param>
    /// <param name="LocationCode_iCod"></param>
    /// <param name="ForecastDate_iDat"></param>
    local procedure ProcessLine(ProdForecastName_iRec: Record "Production Forecast Name"; ItemNo_iCod: Code[20]; LocationCode_iCod: Code[20]; ForecastDate_iDat: Date; qty_iDec: Decimal)
    var
        item_lRec: Record Item;
        TempProdLineBuffer_lRec: Record "trm Production Line Buffer" temporary;
    begin

        // Während der Umstellungsphase von NAv18 auf BC kann es vorkommen, dass der Forecast über alte Artikelnummern erfolgt
        if not item_lRec.get(ItemNo_iCod) then begin
            item_lRec.setrange("DDM Legacy System Item No.", ItemNo_iCod);
            if not item_lRec.FindFirst() then
                exit;
            ItemNo_iCod := item_lRec."No.";
        end;
        item_lRec.CalcFields("trm Item BOM", "trm Master BOM");
        if item_lRec."trm Item BOM" or item_lRec."trm Master BOM" then begin
            explodeBom(ItemNo_iCod, qty_iDec, TempProdLineBuffer_lRec);
            TempProdLineBuffer_lRec.setrange("Is Leaf", true);
            TempProdLineBuffer_lRec.SetRange(Type, TempProdLineBuffer_lRec.type::Item);
            if TempProdLineBuffer_lRec.FindSet() then
                repeat
                    IncreaseQuantity(ProdForecastName_iRec, TempProdLineBuffer_lRec."No.", LocationCode_iCod, ForecastDate_iDat, TempProdLineBuffer_lRec."Calculated Consumption Qty.");
                until TempProdLineBuffer_lRec.Next() = 0;
        end
        else begin
            IncreaseQuantity(ProdForecastName_iRec, ItemNo_iCod, LocationCode_iCod, ForecastDate_iDat, qty_iDec);
        end;
    end;

    /// <summary>
    /// Leert Planzeilen hinter dem Forecast um mehrfaches Einlesen einer Übergabedatei zu verhindern.
    /// </summary>
    local procedure clearProductionForecast_lFnc(ProdForecastName_iRec: Record "Production Forecast Name")
    var
        ProductionForecastEntry_lRec: Record "Production Forecast Entry";
        ForecastNotEmpty_Lbl: Label 'The forecast is not empty. Existing entries will be deletet. Do you really want to continue?';
    begin
        ProdForecastName_iRec.testfield(Name);
        ProductionForecastEntry_lRec.setrange("Production Forecast Name", ProdForecastName_iRec.Name);
        if not Confirm(ForecastNotEmpty_Lbl) then
            error('');
        ProductionForecastEntry_lRec.DeleteAll();
        Commit();
    end;

    /// <summary>
    /// Legt eine neue Planzeile an oder erhöht die Menge einer vorhandenen Planzeile
    /// </summary>
    /// <param name="itemNo_iCod"></param>
    /// <param name="LocationCode_iCod"></param>
    /// <param name="ForecastDate_iDat"></param>
    /// <param name="qty_iDec"></param>

    local procedure IncreaseQuantity(ProdForecastName_iRec: Record "Production Forecast Name"; itemNo_iCod: Code[20]; LocationCode_iCod: Code[20]; ForecastDate_iDat: Date; qty_iDec: Decimal)
    var
        ProductionForecastEntry_lRec: Record "Production Forecast Entry";
        item_lRec: Record Item;
    begin
        ProductionForecastEntry_lRec.SetRange("Production Forecast Name", ProdForecastName_iRec.Name);
        ProductionForecastEntry_lRec.SetRange("Item No.", itemNo_iCod);
        ProductionForecastEntry_lRec.SetRange("Location Code", LocationCode_iCod);
        ProductionForecastEntry_lRec.SetRange("Forecast Date", ForecastDate_iDat);

        if not ProductionForecastEntry_lRec.FindFirst() then begin
            ProductionForecastEntry_lRec."Production Forecast Name" := ProdForecastName_iRec.Name;
            ProductionForecastEntry_lRec.validate("Item No.", itemNo_iCod);
            ProductionForecastEntry_lRec."Location Code" := LocationCode_iCod;
            ProductionForecastEntry_lRec."Forecast Date" := ForecastDate_iDat;
            ProductionForecastEntry_lRec.validate("Forecast Quantity", qty_iDec);
            ProductionForecastEntry_lRec.insert(true);
        end
        else begin
            ProductionForecastEntry_lRec."Forecast Quantity" += qty_iDec;
            ProductionForecastEntry_lRec.validate("Forecast Quantity");
            ProductionForecastEntry_lRec.Modify(true);
        end;
    end;

    /// <summary>
    /// Entfaltet die Stückliste eines Artikels analog dem Aufruf, der sich hinter der Artikelkarte befindet nachdem
    /// man "erstelle temporäre Stückliste" ausgewählt hat.
    /// </summary>
    /// <param name="ItemNo_iCod">Artikelnr. des Artikels, dessen Stückliste entfaltet werden soll</param>
    /// <param name="qty_iDec">Menge</param>
    /// <param name="TempProdLineBuffer_lRec">Komponenten der Art Artikel, die nicht weiter aufgelöst werden</param>
    local procedure explodeBom(ItemNo_iCod: Code[20]; qty_iDec: Decimal; var TempProdLineBuffer_lRec: Record "trm Production Line Buffer" temporary)
    var
        varDimProdPurchLine_lRec: Record "trm VarDim Prod./Purchase Line";
        prodLineBufferPage_lPag: Page "trm Production Line Buffer";

        callGenerateBOMStructure_lRec: Record "trm Call Gen BOM Structure";
        genBOMStructure_lCodeUnit: Codeunit "trm Generate BOM Structure";
        invHandling_loc: Codeunit "trm Inventory Handling";
    begin
        //invHandling_loc.CallBOM();

        callGenerateBOMStructure_lRec.init;
        callGenerateBOMStructure_lRec."Use Temporary Buffer" := true;
        callGenerateBOMStructure_lRec."Assign Type" := 1155;

        varDimProdPurchLine_lRec.LockTable;
        TempProdLineBuffer_lRec.DeleteAll;

        varDimProdPurchLine_lRec.Reset;
        varDimProdPurchLine_lRec.SetRange("Order Type", varDimProdPurchLine_lRec."order type"::"MRP Buffer");
        varDimProdPurchLine_lRec.SetRange("User ID", UserId);
        varDimProdPurchLine_lRec.SetRange("Document Type", callGenerateBOMStructure_lRec."Assign Type");
        if varDimProdPurchLine_lRec.FindFirst then
            varDimProdPurchLine_lRec.DeleteAll;

        callGenerateBOMStructure_lRec.BreakDownItemNo := ItemNo_iCod;
        callGenerateBOMStructure_lRec.CalledConcerning := callGenerateBOMStructure_lRec.Calledconcerning::"Generate Temp. Buffer";
        callGenerateBOMStructure_lRec.LineNumbering := true;
        callGenerateBOMStructure_lRec."Break Down From LLC Level" := 1;
        callGenerateBOMStructure_lRec."Order Volume" := qty_iDec;
        if (callGenerateBOMStructure_lRec."Break Down to Management Level" = 0) then
            callGenerateBOMStructure_lRec."Break Down to Management Level" := 999999999;

        genBOMStructure_lCodeUnit.Set_SkipMessages(true);
        genBOMStructure_lCodeUnit.TransferCalcBufferTemp(TempProdLineBuffer_lRec);
        genBOMStructure_lCodeUnit.OnRunCode(callGenerateBOMStructure_lRec);

        TempProdLineBuffer_lRec.SetRange("Is Leaf", true);
        TempProdLineBuffer_lRec.setrange(Type, TempProdLineBuffer_lRec.Type::Item);
    end;

    var
        ImportFile_gLbl: Label 'Please select the file you want to import.';
        TooManyColumns_gLbl: Label 'The Excel file has more than 4 columns.';
}
