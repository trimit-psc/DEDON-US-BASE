codeunit 51008 "DDN Item and Master Details"
{
    procedure getItemDetails(var salesLine_vRec: Record "Sales Line"; var FabricConsumption_vTxt: Text; var FabricConsumptionTotal_vTxt: Text; var fabricsEnabled_vBln: boolean; var Desginer_vTxt: Text; var Color_vTxt: Text; verbose_iBool: Boolean)
    var
        myInt: Integer;
    begin
        clear(FabricConsumption_vTxt);
        clear(FabricConsumptionTotal_vTxt);
        clear(Desginer_vTxt);
        clear(Desginer_vTxt);
        clear(Color_vTxt);

        if salesLine_vRec.type <> salesLine_vRec.Type::Item then
            exit;
        fabricsEnabled_vBln := GetFabricConsumotionTexts(salesLine_vRec."No.", FabricConsumption_vTxt, FabricConsumptionTotal_vTxt, salesLine_vRec.quantity, verbose_iBool);
        Desginer_vTxt := getDesignerText(salesLine_vRec."trm Salesperson 3", salesLine_vRec."No.");
        Color_vTxt := getSalesColorText_gFnc(salesLine_vRec."No.");
    end;

    procedure GetFabricConsumotionTexts(ItemNo_iCode: Code[20]; var FabricConsumption_iText: Text; var FabricConsumptionTotal_iText: Text; quantity: Decimal; verbose_iBool: Boolean) fabricsEnabled_retBool: Boolean
    var
        Item_lRec: Record Item;
        FabricConsumptionNotApplicable_lLabel: Label 'irrelevant';
        FabricConsumptionUndefined_lLabel: Label 'undefined';
    begin
        clear("FabricConsumption_iText");
        clear(FabricConsumptionTotal_iText);
        if not Item_lRec.get(ItemNo_iCode) then
            exit;

        fabricsEnabled_retBool := Item_lRec.fabricsEnabled();
        if fabricsEnabled_retBool then begin
            if Item_lRec."DDN Fabric Consumption" <> 0 then begin
                FabricConsumption_iText := format(Item_lRec."DDN Fabric Consumption", 0, '<Precision,0:2><Standard Format,0>');
                FabricConsumptionTotal_iText := format(Item_lRec."DDN Fabric Consumption" * Quantity, 0, '<Precision,0:2><Standard Format,0>');
            end else begin
                FabricConsumption_iText := FabricConsumptionUndefined_lLabel;
                FabricConsumptionTotal_iText := FabricConsumptionUndefined_lLabel;
            end;
        end else begin
            if verbose_iBool then begin
                FabricConsumption_iText := FabricConsumptionNotApplicable_lLabel;
                FabricConsumptionTotal_iText := FabricConsumptionNotApplicable_lLabel;
            end else begin
                clear(FabricConsumption_iText);
                Clear(FabricConsumptionTotal_iText);
            end;
        end;
    end;

    local procedure getDesignerText(PossibleDesignerCode_iCode: Code[20]; ItemNo_iCode: code[20]) Desginer_retText: Text
    var
        Item_lRec: Record "Item";
        SalesPerson_lRec: Record "Salesperson/Purchaser";
    begin
        if PossibleDesignerCode_iCode = '' then begin
            if Item_lRec.get(ItemNo_iCode) then begin
                PossibleDesignerCode_iCode := Item_lRec."DDN Designer Code";
            end;
        end;
        if PossibleDesignerCode_iCode <> '' then begin
            if SalesPerson_lRec.get(PossibleDesignerCode_iCode) then begin
                Desginer_retText := SalesPerson_lRec.Name;
            end
        end;
    end;

    /// <summary>
    /// Errechnet die Beschreibung einer Farbe basierend auf den Filter, die in der Dedon-Einrichtung für Farben hinterlegt wurden
    /// </summary>
    /// <param name="itemNo_iCode">Code[20].</param>
    /// <param name="VarDimItem_vRec">VAR Record "trm VarDim Item".</param>
    procedure getSalesColorText_gFnc(itemNo_iCode: Code[20]) Color_retText: Text
    var
        VarDimItem_lRec: Record "trm VarDim Item";
    begin
        if FilterSalesColorVarDim(itemNo_iCode, VarDimItem_lRec) then
            Color_retText := VarDimItem_lRec.Name;

    end;

    /// <summary>
    /// Errechnet den Fabrcode basierend auf den Filter, die in der Dedon-Einrichtung für Farben hinterlegt wurden
    /// </summary>
    /// <param name="itemNo_iCode">Code[20].</param>
    /// <param name="VarDimItem_vRec">VAR Record "trm VarDim Item".</param>
    /// <returns>Return variable ret of type Boolean.</returns>
    procedure getSalesColorCode_gFnc(itemNo_iCode: Code[20]) ColorCode_retText: Code[20]
    var
        VarDimItem_lRec: Record "trm VarDim Item";
    begin
        if FilterSalesColorVarDim(itemNo_iCode, VarDimItem_lRec) then
            ColorCode_retText := VarDimItem_lRec.Value
    end;

    /// <summary>
    /// Baut einen Filter auf den VarDims auf und führt einen FindFirst aus damit Farben ermittelt werden können.
    /// </summary>
    /// <param name="itemNo_iCode"></param>
    /// <param name="VarDimItem_vRec"></param>
    /// <returns></returns>
    local procedure FilterSalesColorVarDim(itemNo_iCode: Code[20]; var VarDimItem_vRec: Record "trm VarDim Item") ret: Boolean
    var
        ddnSetup: Record "DDN Setup";
    begin
        ddnSetup.get();
        ddnSetup.TestField("DDN VarDim COLOR Filter");
        // SalesColor
        VarDimItem_vRec.SetRange("Relation 1", VarDimItem_vRec."Relation 1"::Item);
        VarDimItem_vRec.setrange("Relation 1 Name", itemNo_iCode);
        VarDimItem_vRec.setrange(Type, VarDimItem_vRec.Type::Variant);
        VarDimItem_vRec.setfilter("VarDim Type", ddnSetup."DDN VarDim COLOR Filter");
        if VarDimItem_vRec.FindFirst() then
            ret := true;

    end;
}
