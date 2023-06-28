/// <summary>
/// kapeselt Funktionen um im Einkauf und Verkauf die best passendste Verison zu ermittlen
/// </summary>
codeunit 51015 "COR-DDN ActiveVersion Mgmt."
{
    /// <summary>
    /// Wird im Trimit-Formelwerk aufgerufen
    /// </summary>
    /// <param name="MasterNo"></param>
    /// <param name="LocationCode_iCode"></param>
    /// <param name="requestedQty_iDec"></param>
    /// <param name="requestDate_iDate"></param>
    /// <param name="VarDim"></param>
    /// <returns></returns>
    procedure CalcBestVersionSalesViaTrimitFormula(MasterNo: Code[20]; LocationCode_iCode: Code[20]; requestedQty_iDec: Decimal; requestDate_iDate: Date; VarDim: array[5] of Code[10]) optimalVersionCode: Code[10]
    var
        itemNoFilter_lCode: Code[20];
    begin
        itemNoFilter_lCode := prepareItemFilterForVersionViaMasterNo(MasterNo, VarDim);
        optimalVersionCode := CalcBestVersionSales(itemNoFilter_lCode, LocationCode_iCode, requestedQty_iDec, requestDate_iDate);
    end;

    procedure CalcBestCountrySalesViaTrimitFormula(MasterNo: Code[20]; LocationCode_iCode: Code[20]; requestedQty_iDec: Decimal; requestDate_iDate: Date; VarDim: array[5] of Code[10]) optimalCountryCode: Code[10]
    var
        itemNoFilter_lCode: Code[20];
        colorCode_lCod: Code[10];
        colorPos_lInt: Integer;
    begin
        itemNoFilter_lCode := prepareItemFilterForVersionViaMasterNo(MasterNo, VarDim);
        // VarDim für die Farbe ermitteln
        colorPos_lInt := FindColorPosInItemNo(MasterNo);
        if colorPos_lInt = 0 then
            colorCode_lCod := ''
        else
            colorCode_lCod := VarDim[colorPos_lInt];
        optimalCountryCode := CalcBestCountrySales(itemNoFilter_lCode, LocationCode_iCode, requestedQty_iDec, requestDate_iDate, colorCode_lCod);
    end;

    // procedure CalcBestCountrySalesOnItemCard(MasterNo: Code[20]; LocationCode_iCode: Code[20]; requestedQty_iDec: Decimal; requestDate_iDate: Date; VarDim: array[5] of Code[10]) optimalCountryCode: Code[10]
    // var
    //     itemNoFilter_lCode: Code[20];
    // begin
    //     itemNoFilter_lCode := prepareItemFilterForVersionViaMasterNo(MasterNo, VarDim);
    //     optimalCountryCode := CalcBestCountrySales(itemNoFilter_lCode, LocationCode_iCode, requestedQty_iDec, requestDate_iDate);
    //     if optimalCountryCode = '' then begin
    //         optimalCountryCode := CalcBestCountryPurchase(MasterNo);
    //     end
    // end;


    /// <summary>
    /// Ermittelt anhand der Vardim eines Artikels seine Version
    /// </summary>
    /// <param name="Item_vRec"></param>
    /// <returns></returns>
    procedure getItemVersion(var Item_vRec: Record Item) VersionNo: Code[10]
    var
        ddnSetup: Record "DDN Setup";
        VarDimItem_lRec: Record "trm varDim Item";
    begin
        ddnSetup.get();
        VarDimItem_lRec.SetLoadFields(Value);
        VarDimItem_lRec.setrange("Relation 1", VarDimItem_lRec."Relation 1"::Item);
        VarDimItem_lRec.setrange("Relation 1 Name", Item_vRec."No.");
        VarDimItem_lRec.setrange("VarDim Type", ddnSetup."DDN VarDim VERSION");
        if VarDimItem_lRec.findfirst then
            VersionNo := VarDimItem_lRec.Value;
    end;

    procedure getItemCountry(var Item_vRec: Record Item) Country: Code[10]
    var
        ddnSetup: Record "DDN Setup";
        VarDimItem_lRec: Record "trm varDim Item";
    begin
        ddnSetup.get();
        VarDimItem_lRec.SetLoadFields(Value);
        VarDimItem_lRec.setrange("Relation 1", VarDimItem_lRec."Relation 1"::Item);
        VarDimItem_lRec.setrange("Relation 1 Name", Item_vRec."No.");
        VarDimItem_lRec.setrange("VarDim Type", ddnSetup."DDN VarDim COUNTRY");
        if VarDimItem_lRec.findfirst then
            Country := VarDimItem_lRec.Value;
    end;

    /// <summary>
    /// gibt an, ob ein MAster mit Ländern arbeitet
    /// </summary>
    /// <param name="Master_vRec"></param>
    /// <returns></returns>
    procedure MasterUsesCountry(var Master_vRec: Record "trm Master") ret: boolean
    var
        ddnSetup: Record "DDN Setup";
        VarDimMaster_lRec: Record "trm varDim Master";
    begin
        ddnSetup.get();
        VarDimMaster_lRec.setrange(type, VarDimMaster_lRec.type::Variant);
        VarDimMaster_lRec.setrange(Relation, VarDimMaster_lRec.Relation::Master);
        if Master_vRec."VarDim Relation No." = '' then
            VarDimMaster_lRec.setrange("No.", Master_vRec."No.")
        else
            VarDimMaster_lRec.setrange("No.", Master_vRec."VarDim Relation No.");
        VarDimMaster_lRec.setfilter("VarDim Type", ddnSetup."DDN VarDim COUNTRY");
        if VarDimMaster_lRec.FindFirst() then
            exit(true);
    end;

    procedure ItemUsesCountry(var Item_vRec: Record Item) ret: boolean
    var
        Master_vRec: Record "trm Master";
    begin
        if Item_vRec."trm Master No." = '' then
            exit(false);
        if not Master_vRec.get(Item_vRec."trm Master No.") then
            exit(false);
        ret := MasterUsesCountry(Master_vRec);
    end;

    /// <summary>
    /// Baut basierend auf einer Master-Nummer und den VarDims einen Filter auf, der alle Eigenschaften
    /// berücksichtigt und nur die Version variabel hält
    /// </summary>
    /// <param name="MasterNo"></param>
    /// <param name="VarDim"></param>
    /// <returns></returns>
    procedure prepareItemFilterForVersionViaMasterNo(MasterNo: Code[20]; VarDim: array[5] of Code[10]) itemNoFilter_lCode: Code[20]
    var
        InventoryProfileSetup: Record "trm Inventory Profile Setup";
        Item_lRec: Record Item;
        Master_lRec: Record "trm master";
        NoSystem_lRec: Record "trm No. System";
        i, j : Integer;
        Pos_lInt: Integer;
        VarDimItemNoBuffer_lCode: array[5] of Code[10];
        MatrixMaster_lRec: Record "trm Matrix Master";
        ddnSetup_lRec: Record "DDN Setup";
        VersionPos_lInt: Integer;
        CountryPos_lInt: Integer;
        VersionStrLen_Int: Integer;
        CountryStrLen_Int: Integer;
        NoFilterCreated_lLbl: Label 'BC could not calcuate a filter for Master %1 with the Vardims %2 %3 %4 %5 %6';
    begin
        // Guards
        Master_lRec.Get(MasterNo);
        NoSystem_lRec.get(Master_lRec."No. System");
        ddnSetup_lRec.get();
        ddnSetup_lRec.testfield("DDN VarDim VERSION");
        ddnSetup_lRec.testfield("DDN VarDim COUNTRY");

        // Reihenfolge der VarDims in der Artikelnummer ermitteln
        for i := 1 to ArrayLen(VarDim) do begin
            clear(Pos_lInt);
            Pos_lInt := getPosVarDim(1, MasterNo);
            if Pos_lInt > 0 then begin
                VarDimItemNoBuffer_lCode[i] := VarDim[i];
            end
        end;

        // Position der VarDim für die Version in der Artikelnummer ermitteln
        VersionPos_lInt := FindVersionPosInItemNo(MasterNo);
        CountryPos_lInt := FindCountryPosInItemNo(MasterNo);

        if VersionPos_lInt > 0 then begin
            itemNoFilter_lCode := MasterNo;
            for i := 1 to ArrayLen(VarDimItemNoBuffer_lCode) do begin
                // Anstelle der Version werden Fragezeigen zur Filterung gesetzt
                // Die Anzahl der fragezeichen richtet sich nach der Länge der Variablen in der Nummerierung
                VersionStrLen_Int := getLengthVarDim(i, MasterNo);
                if CountryPos_lInt > 0 then
                    CountryStrLen_Int := getLengthVarDim(i, MasterNo);

                // VarDim bezieht sich auf Artikel
                if i = VersionPos_lInt then begin
                    for j := 1 to VersionStrLen_Int do begin
                        itemNoFilter_lCode += '?';
                    end;
                end
                // Ländercode variabel halten
                else begin
                    // VarDim bezieht sich auf Ländercode
                    // Wurde kein Ländercode mitgegeben dann baue einen Platzhalter
                    if (i = CountryPos_lInt) and (VarDimItemNoBuffer_lCode[i] IN ['', '0']) then begin
                        for j := 1 to CountryStrLen_Int do begin
                            itemNoFilter_lCode += '?';
                        end;
                    end
                    // jede andere VarDim
                    else begin
                        itemNoFilter_lCode += VarDimItemNoBuffer_lCode[i];
                    end;
                end;
            end;
        end
        else begin
            error(NoFilterCreated_lLbl, MasterNo, VarDim[1], VarDim[2], VarDim[3], VarDim[4], VarDim[5]);
        end;
        //error('CU 51015 meldet itemNoFilter %1', itemNoFilter_lCode);
    end;

    local procedure getPosVarDim(vardim_lInt: Integer; MasterNo_iCode: Code[20]): Integer
    var
        NoSystem_lRec: Record "trm No. System";
        Master_lRec: Record "trm Master";
    begin
        if not Master_lRec.get(MasterNo_iCode) then
            exit;
        if not NoSystem_lRec.get(Master_lRec."No. System") then
            exit;
        case vardim_lInt of
            1:
                exit(NoSystem_lRec."Variant 1 Position");
            2:
                exit(NoSystem_lRec."Variant 2 Position");
            3:
                exit(NoSystem_lRec."Variant 3 Position");
            4:
                exit(NoSystem_lRec."Variant 4 Position");
            5:
                exit(NoSystem_lRec."Variant 5 Position");
        end;
    end;

    /// <summary>
    /// Ermittelt die Länge, die eine VarDim in der Nummerierung eines Artikels beansprucht
    /// Wird genutzt um einen Filter zu bauen;
    /// </summary>
    /// <param name="vardim_lInt"></param>
    /// <param name="MasterNo_iCode"></param>
    /// <returns></returns>
    local procedure getLengthVarDim(vardim_lInt: Integer; MasterNo_iCode: Code[20]): Integer
    var
        NoSystem_lRec: Record "trm No. System";
        Master_lRec: Record "trm Master";
    begin
        if not Master_lRec.get(MasterNo_iCode) then
            exit;
        if not NoSystem_lRec.get(Master_lRec."No. System") then
            exit;
        case vardim_lInt of
            1:
                exit(NoSystem_lRec."Variant 1 Length");
            2:
                exit(NoSystem_lRec."Variant 2 Length");
            3:
                exit(NoSystem_lRec."Variant 3 Length");
            4:
                exit(NoSystem_lRec."Variant 4 Length");
            5:
                exit(NoSystem_lRec."Variant 5 Length");
        end;
    end;

    local procedure getPosOfFirstChar(vardim_lInt: Integer; MasterNo_iCode: Code[20]): Integer
    var
        NoSystem_lRec: Record "trm No. System";
        Master_lRec: Record "trm Master";
    begin
        if not Master_lRec.get(MasterNo_iCode) then
            exit;
        if not NoSystem_lRec.get(Master_lRec."No. System") then
            exit;
        case vardim_lInt of
            1:
                exit(NoSystem_lRec."Variant 1 Position of 1. Char.");
            2:
                exit(NoSystem_lRec."Variant 2 Position of 1. Char.");
            3:
                exit(NoSystem_lRec."Variant 3 Position of 1. Char.");
            4:
                exit(NoSystem_lRec."Variant 4 Position of 1. Char.");
            5:
                exit(NoSystem_lRec."Variant 5 Position of 1. Char.");
        end;
    end;

    local procedure FindVersionPosInItemNo(MasterNo: Code[10]) VersionPos_lInt: Integer;
    var
        MatrixMaster_lRec: Record "trm Matrix Master";
        ddnSetup_lRec: Record "DDN Setup";
    begin
        // Position der VarDim für die Version in der Artikelnummer ermitteln
        if not MatrixMaster_lRec.get(MatrixMaster_lRec."Relation 1"::Matrix, MasterNo, MatrixMaster_lRec."Relation 2"::Master, MasterNo) then
            exit;
        ddnSetup_lRec.get();
        case true of
            ddnSetup_lRec."DDN VarDim VERSION" = MatrixMaster_lRec."VarDim Type Variant 1":
                VersionPos_lInt := 1;
            ddnSetup_lRec."DDN VarDim VERSION" = MatrixMaster_lRec."VarDim Type Variant 2":
                VersionPos_lInt := 2;
            ddnSetup_lRec."DDN VarDim VERSION" = MatrixMaster_lRec."VarDim Type Variant 3":
                VersionPos_lInt := 3;
            ddnSetup_lRec."DDN VarDim VERSION" = MatrixMaster_lRec."VarDim Type Variant 4":
                VersionPos_lInt := 4;
            ddnSetup_lRec."DDN VarDim VERSION" = MatrixMaster_lRec."VarDim Type Variant 5":
                VersionPos_lInt := 5;
            else
                exit;
        end;
    end;

    local procedure FindCountryPosInItemNo(MasterNo: Code[10]) VersionPos_lInt: Integer;
    var
        MatrixMaster_lRec: Record "trm Matrix Master";
        ddnSetup_lRec: Record "DDN Setup";
    begin
        // Position der VarDim für die Version in der Artikelnummer ermitteln
        if not MatrixMaster_lRec.get(MatrixMaster_lRec."Relation 1"::Matrix, MasterNo, MatrixMaster_lRec."Relation 2"::Master, MasterNo) then
            exit;
        ddnSetup_lRec.get();
        case true of
            ddnSetup_lRec."DDN VarDim COUNTRY" = MatrixMaster_lRec."VarDim Type Variant 1":
                VersionPos_lInt := 1;
            ddnSetup_lRec."DDN VarDim COUNTRY" = MatrixMaster_lRec."VarDim Type Variant 2":
                VersionPos_lInt := 2;
            ddnSetup_lRec."DDN VarDim COUNTRY" = MatrixMaster_lRec."VarDim Type Variant 3":
                VersionPos_lInt := 3;
            ddnSetup_lRec."DDN VarDim COUNTRY" = MatrixMaster_lRec."VarDim Type Variant 4":
                VersionPos_lInt := 4;
            ddnSetup_lRec."DDN VarDim COUNTRY" = MatrixMaster_lRec."VarDim Type Variant 5":
                VersionPos_lInt := 5;
            else
                exit;
        end;
    end;

    local procedure FindColorPosInItemNo(MasterNo: Code[10]) ColorPos_lInt: Integer;
    var
        MatrixMaster_lRec: Record "trm Matrix Master";
        ddnSetup_lRec: Record "DDN Setup";
    begin
        ddnSetup_lRec.get();
        // Farben sind nicht eindeutig. Daher müssen wir mit Filtern arbeiten
        MatrixMaster_lRec.setrange("Relation 1", MatrixMaster_lRec."Relation 1"::Matrix);
        MatrixMaster_lRec.setrange("Relation 1 Name", MasterNo);
        MatrixMaster_lRec.setrange("Relation 2", MatrixMaster_lRec."Relation 2"::Master);
        MatrixMaster_lRec.setrange("Relation 2 Name", MasterNo);

        MatrixMaster_lRec.setfilter("VarDim Type Variant 1", ddnSetup_lRec."DDN VarDim COLOR Filter");
        if not MatrixMaster_lRec.IsEmpty then
            exit(1);

        MatrixMaster_lRec.setrange("VarDim Type Variant 1");
        MatrixMaster_lRec.setfilter("VarDim Type Variant 2", ddnSetup_lRec."DDN VarDim COLOR Filter");
        if not MatrixMaster_lRec.IsEmpty then
            exit(2);

        MatrixMaster_lRec.setrange("VarDim Type Variant 2");
        MatrixMaster_lRec.setfilter("VarDim Type Variant 3", ddnSetup_lRec."DDN VarDim COLOR Filter");
        if not MatrixMaster_lRec.IsEmpty then
            exit(3);

        MatrixMaster_lRec.setrange("VarDim Type Variant 3");
        MatrixMaster_lRec.setfilter("VarDim Type Variant 4", ddnSetup_lRec."DDN VarDim COLOR Filter");
        if not MatrixMaster_lRec.IsEmpty then
            exit(4);

        MatrixMaster_lRec.setrange("VarDim Type Variant 4");
        MatrixMaster_lRec.setfilter("VarDim Type Variant 5", ddnSetup_lRec."DDN VarDim COLOR Filter");
        if not MatrixMaster_lRec.IsEmpty then
            exit(5);
    end;

    /// <summary>
    /// Ermittelt einen Filter mit dem sich alle Artikelnummern filtern lassen
    /// bei denen sich lediglich die Version in den VarDims unterscheidet.
    /// Als Eingabeparameter wird der Artikel genutzt
    /// </summary>
    procedure prepareItemFilterForVersionAndCountryViaItem(var item_vRec: Record Item) itemNoFilter_rCode: Code[20];
    var

        SalesLine_lRec: Record "Sales Line";
        Master_lRec: Record "trm master";
        NoSystem_lRec: Record "trm No. System";
        i, j : Integer;
        Pos_lInt: Integer;
        VarDimItemNoBuffer_lCode: array[5] of Code[10];

        MatrixMaster_lRec: Record "trm Matrix Master";
        ddnSetup_lRec: Record "DDN Setup";
        VersionPos_lInt: Integer;
        CountryPos_lInt: Integer;
        VersionStrLen_Int: Integer;
        PosOfFirstCharForVersion_lInt: Integer;
        LengthOfFirstCharForVersion_lInt: Integer;
        PosOfFirstCharForCountry_lInt: Integer;
        LengthOfFirstCharForCountry_lInt: Integer;
    begin
        // Guards
        if not Master_lRec.Get(item_vRec."trm Master No.") then
            exit;
        if not NoSystem_lRec.get(Master_lRec."No. System") then
            exit;

        // Die gesamte Artikelnummer erst einmal als Filter setzen
        itemNoFilter_rCode := item_vRec."No.";

        // Position der VarDim für die Version in der Artikelnummer ermitteln
        VersionPos_lInt := FindVersionPosInItemNo(item_vRec."trm Master No.");

        if VersionPos_lInt <= 0 then
            exit;

        PosOfFirstCharForVersion_lInt := getPosOfFirstChar(VersionPos_lInt, item_vRec."trm Master No.");
        LengthOfFirstCharForVersion_lInt := getLengthVarDim(VersionPos_lInt, item_vRec."trm Master No.");

        for i := 1 to LengthOfFirstCharForVersion_lInt do begin
            itemNoFilter_rCode[PosOfFirstCharForVersion_lInt + i - 1] := '?'
        end;

        // Es kann artikel geben ohne Ländercode!
        CountryPos_lInt := FindCountryPosInItemNo(item_vRec."trm Master No.");
        if CountryPos_lInt <= 0 then
            exit;

        PosOfFirstCharForCountry_lInt := getPosOfFirstChar(CountryPos_lInt, item_vRec."trm Master No.");
        LengthOfFirstCharForCountry_lInt := getLengthVarDim(CountryPos_lInt, item_vRec."trm Master No.");
        for i := 1 to LengthOfFirstCharForCountry_lInt do begin
            itemNoFilter_rCode[PosOfFirstCharForCountry_lInt + i - 1] := '?'
        end;
    end;

    /// <summary>
    /// Berechnet die besten Versionen für den Verkauf um die Daten auf
    /// der Artikelkarte darzustellen.
    /// </summary>
    [TryFunction]
    procedure CalcBestVersionSalesOnItemCard(var item_vRec: Record Item; var BestVersion_iCod: array[2] of Code[10]; doInitQuantityFilters: Boolean)
    var
        itemNoFilter_lCod: Code[20];
        CompanyInfo_lRec: Record "Company Information";
        DDNSetup: Record "DDN Setup";
        qty_lDec: array[2] of Decimal;
        i: Integer;
    begin
        DDNSetup.get();
        clear(BestVersion_iCod);
        if not DDNSetup."enable Version Calc Item Card" then
            exit;
        CompanyInfo_lRec.get();
        if doInitQuantityFilters then
            prepareQuantityFiltersBestVersionSalesOnItemCard(item_vRec);
        evaluate(qty_lDec[1], item_vRec.getFilter("COR-DDN Sales Qty. Filter 1"));
        evaluate(qty_lDec[2], item_vRec.getFilter("COR-DDN Sales Qty. Filter 2"));
        itemNoFilter_lCod := prepareItemFilterForVersionAndCountryViaItem(item_vRec);
        for i := 1 to ArrayLen(qty_lDec) do begin
            BestVersion_iCod[i] := CalcBestVersionSales(itemNoFilter_lCod, CompanyInfo_lRec."Location Code", qty_lDec[i], workdate());
        end;
    end;

    /// <summary>
    /// prüft ob die Voraussetung für BestVerison überahupt gegeben ist
    /// </summary>
    /// <param name="item_vRec"></param>
    /// <returns></returns>
    procedure BestVersionAndCountryApplicable(var item_vRec: Record Item) ret: Boolean
    var
    begin
        if item_vRec."trm Master No." = '' then
            exit(false);
        ret := getItemVersion(item_vRec) <> '';
    end;

    [TryFunction]
    procedure CalcBestCountrySalesOnItemCard(var item_vRec: Record Item; var BestCountry_iCod: array[2] of Code[10]; doInitQuantityFilters: Boolean)
    var
        itemNoFilter_lCod: Code[20];
        CompanyInfo_lRec: Record "Company Information";
        DDNSetup: Record "DDN Setup";
        qty_lDec: array[2] of Decimal;
        i: Integer;
        ItemMasterDetail: Codeunit "DDN Item and Master Details";
    begin
        DDNSetup.get();
        clear(BestCountry_iCod);
        if not DDNSetup."enable Version Calc Item Card" then
            exit;
        CompanyInfo_lRec.get();
        if doInitQuantityFilters then
            prepareQuantityFiltersBestVersionSalesOnItemCard(item_vRec);
        evaluate(qty_lDec[1], item_vRec.getFilter("COR-DDN Sales Qty. Filter 1"));
        evaluate(qty_lDec[2], item_vRec.getFilter("COR-DDN Sales Qty. Filter 2"));
        itemNoFilter_lCod := prepareItemFilterForVersionAndCountryViaItem(item_vRec);
        for i := 1 to ArrayLen(qty_lDec) do begin
            BestCountry_iCod[i] := CalcBestCountrySales(itemNoFilter_lCod, CompanyInfo_lRec."Location Code", qty_lDec[i], workdate(), ItemMasterDetail.getSalesColorCode_gFnc(item_vRec."No."));
        end;
    end;


    /// <summary>
    /// Sammle Informationen um die Filtermenge für den Verkauf zu errechnen
    /// Prio 1: Arbeiten mit Suchtabelle
    /// Prio 2: Standardwerte aus dedon-Einrichtung
    /// Prio 3: 1 Stück als Fallback
    /// </summary>
    /// <param name="item_vRec"></param>
    local procedure prepareQuantityFiltersBestVersionSalesOnItemCard(var item_vRec: Record Item)
    var
        ddnSetup: Record "DDN Setup";
        searchTableLine: Record "trm Search Table Line";
    begin
        ddnSetup.Get();
        item_vRec.setrange("COR-DDN Sales Qty. Filter 1");
        item_vRec.setrange("COR-DDN Sales Qty. Filter 2");
        if ddnSetup."Search table Sales Qty. Filter" <> '' then begin
            searchTableLine.setrange("Table ID", ddnSetup."Search table Sales Qty. Filter");
            searchTableLine.setrange("Column 1 (Decimal)", item_vRec."trm Item Statistics Group");
            searchTableLine.setrange("Column 2 (Decimal)", item_vRec."trm Item Statistics Group 2");
            if searchTableLine.FindFirst() then begin
                item_vRec.setrange("COR-DDN Sales Qty. Filter 1", searchTableLine."Result 1 (Decimal)");
                item_vRec.setrange("COR-DDN Sales Qty. Filter 2", searchTableLine."Result 2 (Decimal)");
            end
        end;
        if item_vRec.getFilter("COR-DDN Sales Qty. Filter 1") = '' then
            item_vRec.setrange("COR-DDN Sales Qty. Filter 1", ddnSetup."Default Sales Qty. Filter 1");
        if item_vRec.getFilter("COR-DDN Sales Qty. Filter 2") = '' then
            item_vRec.setrange("COR-DDN Sales Qty. Filter 2", ddnSetup."Default Sales Qty. Filter 2");

        if item_vRec.getFilter("COR-DDN Sales Qty. Filter 1") = '' then
            item_vRec.setrange("COR-DDN Sales Qty. Filter 1", 1);
        if item_vRec.getFilter("COR-DDN Sales Qty. Filter 2") = '' then
            item_vRec.setrange("COR-DDN Sales Qty. Filter 2", 10);
    end;

    local procedure CalcBestVersionSales(itemNoFilter_iCode: Code[20]; LocationCode_iCode: Code[20]; requestedQty_iDec: Decimal; requestDate_iDate: Date) ret: Code[10]
    begin
        ret := CalcBestVersionOrCountrySales(itemNoFilter_iCode, LocationCode_iCode, requestedQty_iDec, requestDate_iDate, 0, '')
    end;

    local procedure CalcBestCountrySales(itemNoFilter_iCode: Code[20]; LocationCode_iCode: Code[20]; requestedQty_iDec: Decimal; requestDate_iDate: Date; optionalColorCode_lCod: Code[20]) ret: Code[10]
    begin
        ret := CalcBestVersionOrCountrySales(itemNoFilter_iCode, LocationCode_iCode, requestedQty_iDec, requestDate_iDate, 1, optionalColorCode_lCod)
    end;
    /// <summary>
    /// hier ist die Intelligenz gekapselt um basierend auf der Trimit-Verfügbarkeitsberechnung eine Version für den verkauf zu ermittlent
    /// </summary>
    /// <param name="MasterNo"></param>
    /// <param name="LocationCode_iCode"></param>
    /// <param name="requestedQty_iDec"></param>
    /// <param name="requestDate_iDate"></param>
    /// <param name="VarDim"></param>
    /// <returns></returns>
    local procedure CalcBestVersionOrCountrySales(itemNoFilter_iCode: Code[20]; LocationCode_iCode: Code[20]; requestedQty_iDec: Decimal; requestDate_iDate: Date; whatToCalc: Option Version,Country; optionalColorCode_lCod: Code[20]) ret: Code[10]
    var
        InventoryProfileSetup: Record "trm Inventory Profile Setup";
        CallInventoryProfile: Codeunit "trm Call Inventory Profile";
        InventoryProfileHandling: Codeunit "trm Inventory Profile Handling";
        TempInventoryProfileTemp: Record "trm Temp Inventory Profile" temporary;
        Item_lRec: Record Item;
        ItemTempPuffer_lRec: Record Item temporary;
        SalesLine_lRec: Record "Sales Line";
        i, j : Integer;
        ddnSetup_lRec: Record "DDN Setup";
        AvailableQty_lDec: Decimal;
        actualCountryOrVersionCode: Code[10];
        VersionChanged_lLbl: Label 'For %1 the Version has switched from %2 to %3 due to availibility of an expired version with overhang on stock.';
    begin
        ddnSetup_lRec.get();
        Item_lRec.SetFilter("No.", itemNoFilter_iCode);
        Item_lRec.SetLoadFields("No.", Description, "DDN Item Status Code");
        // ggf. auf bestimmte Statuscodes beschränken
        if ddnSetup_lRec."ItemPlannungStatus best Vers." <> '' then
            Item_lRec.SetFilter("DDN Item Status Code", ddnSetup_lRec."ItemPlannungStatus best Vers.");

        if not item_lRec.findset then begin
            exit
        end;

        // temporäre Tabelle mit Artikeln aufbauen um aufsteigende Suche erst nach Version und dann nach Land zu ermöglichen
        repeat
            ItemTempPuffer_lRec.Init();
            ItemTempPuffer_lRec := Item_lRec;
            ItemTempPuffer_lRec."Search Description" := strsubstno('%1 %2', getItemVersion(item_lRec), getItemCountry(Item_lRec));
            ItemTempPuffer_lRec.insert();
        until Item_lRec.next() = 0;
        // Wichtig ist hier die Sortierung nach Version und danach nach Land
        // Daher wurde der Suchocde entsprechend aufgebaut
        ItemTempPuffer_lRec.SetCurrentKey("Search Description");

        if ddnSetup_lRec."Inventory Profile best Version" <> '' then
            InventoryProfileSetup.get(ddnSetup_lRec."Inventory Profile best Version");

        // Trimit Special :)
        if LocationCode_iCode = '0' then
            Clear(LocationCode_iCode);

        ItemTempPuffer_lRec.FindFirst();
        repeat
            item_lRec.get(ItemTempPuffer_lRec."No.");
            // Für jeden Artikel die Verfügbarkeiten durchgehen
            // Die Versionsnummer ist aufsteigend. Daher gilt: Sobald die verfügbare Menge größer oder gleich der geforderten Menge ist
            // kann die Suche beendet werden
            Clear(InventoryProfileHandling);
            InventoryProfileHandling.TransferAvailableOverviewTemp(TempInventoryProfileTemp);
            InventoryProfileHandling.Set_SalesLine(SalesLine_lRec);
            AvailableQty_lDec := InventoryProfileHandling.CalculateItemTransaction(
                InventoryProfileSetup,
                Item_lRec,
                requestDate_iDate,
                LocationCode_iCode,
                item_lRec."Global Dimension 1 Filter",
                item_lRec."Global Dimension 2 Filter");
            // hier erfolgt die Rückgabe der passenden Versionsnummer;
            if AvailableQty_lDec >= requestedQty_iDec then begin
                if whatToCalc = whatToCalc::Version then
                    actualCountryOrVersionCode := getItemVersion(item_lRec)
                else
                    actualCountryOrVersionCode := getItemCountry(item_lRec);
                // optimalVersionCode ist hier noch vorbelegt gem. übergebenem VarDim-Parameter
                // if actualCountryOrVersionCode <> ret then begin
                //     if ddnSetup_lRec."Show Version switched Message" and GuiAllowed then
                //         message(VersionChanged_lLbl, item_lRec.Description, ret, actualCountryOrVersionCode);
                // end;
                exit(actualCountryOrVersionCode);
            end;
        until ItemTempPuffer_lRec.next = 0;
        // Fallback: jüngste Version als Plan B falls es keine einzige Version mit Bestand geben sollte
        if whatToCalc = whatToCalc::Version then
            ret := getItemVersion(ItemTempPuffer_lRec)
        // Fallbackj ist das Land gem. Einkauf
        else
            ret := CalcBestCountryPurchase(item_lRec."trm Master No.", optionalColorCode_lCod);
    end;


    local procedure CalcBestVersionPurchase(itemNoFilter_iCode: Code[20]) optimalVersionCode: Code[10]
    var
        Item_lRec: Record Item;
        ddnSetup_lRec: Record "DDN Setup";
        actualVersionCode: Code[10];
        VarDimItem: Record "trm VarDim Item";
        actualVersion_lChar: Char;
    begin
        ddnSetup_lRec.get();

        Item_lRec.SetFilter("No.", itemNoFilter_iCode);
        Item_lRec.SetLoadFields("No.", Description, "DDN Item Status Code");
        // ggf. auf bestimmte Statuscodes beschränken
        if ddnSetup_lRec."Status best Vers. 2" <> '' then
            // prüfung gegen FlowFeld
            Item_lRec.SetFilter("DDN Item Status Code", ddnSetup_lRec."Status best Vers. 2");

        optimalVersionCode := '0';
        if not item_lRec.findset then
            exit;

        VarDimItem.setrange("VarDim Type", ddnSetup_lRec."DDN VarDim VERSION");
        VarDimItem.SetRange(Type, VarDimItem.type::Variant);
        repeat
            // pro Artikel die VarDim suchen
            VarDimItem.SetRange("Relation 1", VarDimItem."Relation 1"::Item);
            VarDimItem.setrange("Relation 1 Name", Item_lRec."No.");
            if VarDimItem.findlast then begin
                actualVersion_lChar := VarDimItem.Value[1];
            end;
            if actualVersion_lChar > optimalVersionCode[1] then
                optimalVersionCode := VarDimItem.Value;
        until item_lRec.Next() = 0;
    end;

    /// <summary>
    /// Folgende Ideen gäbe es für das beste Land
    /// - Ermittlung über Suchtabelle
    /// - Ermittlung über Kreditor hinter Master
    /// - Ermittlung über jüngsten Artikelposten
    /// Dabei sind jegliche Status-Filter irrelvant
    /// </summary>
    /// <param name="itemNoFilter_iCode"></param>
    /// <returns></returns>
    local procedure CalcBestCountryPurchase(MasterNo_iCod: Code[20]; optionalColorCode_iCod: Code[20]) optimalCountryCode: Code[10]
    var
        ddnSetup_lRec: Record "DDN Setup";
        actualVersionCode: Code[10];
        callFormulaSearch_loc: Record "trm Call Formula Search";
        callFormulaSearch2_loc: Record "trm Call Formula Search";
        FormulaLine: record "trm Formula Line";
        FormulaHandling: Codeunit "trm Formula Handling";
        Master_lRec: Record "trm Master";
        Vendor_lRec: Record Vendor;
    begin
        ddnSetup_lRec.get();
        if not Master_lRec.get(MasterNo_iCod) then
            exit;

        // Es gibt Artikel bei denen das Einkaufsland irrelvant ist
        if not MasterUsesCountry(Master_lRec) then
            exit;

        // Ein Aufruf via Suchtabelle falls definiert
        if ddnSetup_lRec."Searchtable Buy from Country" <> '' then begin
            if optionalColorCode_iCod <> '' then begin
                callFormulaSearch_loc.TableNo := ddnSetup_lRec."Searchtable Buy from Country";
                callFormulaSearch_loc.SearchBase1_Var := MasterNo_iCod;
                callFormulaSearch_loc.SearchBase2_Var := optionalColorCode_iCod;
                FormulaHandling.TableSearch_1(callFormulaSearch_loc);
                optimalCountryCode := callFormulaSearch_loc.Result1_Var;
            end;
            if optimalCountryCode = '' then begin
                callFormulaSearch2_loc.TableNo := ddnSetup_lRec."Searchtable Buy from Country";
                callFormulaSearch2_loc.SearchBase1_Var := MasterNo_iCod;

                // Wir nutzen die VarDim der Farbe als zweite Spalte
                // entspricht FormulaLine."Use Search Table Result"
                callFormulaSearch2_loc.UseSearchTableResult := ddnSetup_lRec."Result Column Buy from Country";
                FormulaHandling.TableSearch_1(callFormulaSearch2_loc);
                optimalCountryCode := callFormulaSearch2_loc.Result1_Var;
            end;
        end;
        // Plan B ist die Suche über den Standard-Kreditor des Master
        if optimalCountryCode = '' then begin
            if Master_lRec."Vendor No." <> '' then begin
                if Vendor_lRec.get(Master_lRec."Vendor No.") then
                    optimalCountryCode := Vendor_lRec."Country/Region Code";
            end;
        end
    end;

    /// <summary>
    /// Einstiegspuntk um mittels Trimit-Formelwerk die beste Version für den Einkauf zu errechnen
    /// </summary>
    /// <param name="MasterNo"></param>
    /// <param name="VarDim"></param>
    /// <returns></returns>
    procedure CalcBestVersionPurchaseViaTrimitFormula(MasterNo: Code[20]; VarDim: array[5] of Code[10]) optimalVersionCode: Code[10]
    var
        itemNoFilter_lCode: Code[10];
    begin
        itemNoFilter_lCode := prepareItemFilterForVersionViaMasterNo(MasterNo, VarDim);
        optimalVersionCode := CalcBestVersionPurchase(itemNoFilter_lCode);
    end;

    procedure CalcBestCountryPurchaseViaTrimitFormula(MasterNo: Code[20]) optimalCountryCode: Code[10]
    var
    begin
        optimalCountryCode := CalcBestVersionPurchase(MasterNo);
    end;



    /// <summary>
    /// Berechnet die besten Versionen für den Einkauf um die Daten auf
    /// der Artikelkarte darzustellen.
    /// </summary>
    [TryFunction]
    procedure CalcBestVerisonPurchaseOnItemCard(var item_vRec: Record Item; var BestVersion_iCod: Code[10])
    var
        itemNoFilter_lCod: Code[20];
        DDNSetup: Record "DDN Setup";
    begin
        DDNSetup.get();
        clear(BestVersion_iCod);
        if not DDNSetup."enable Version Calc Item Card" then
            exit;
        itemNoFilter_lCod := prepareItemFilterForVersionAndCountryViaItem(item_vRec);
        BestVersion_iCod := CalcBestVersionPurchase(itemNoFilter_lCod);
    end;

    procedure CalcBestCountryPurchaseOnItemCard(var item_vRec: Record Item; var BestCountry_iCod: Code[10]) ret: Boolean
    var
        itemNoFilter_lCod: Code[20];
        DDNSetup: Record "DDN Setup";
        p: Page "trm Master List";
        ItemMasterDetail: Codeunit "DDN Item and Master Details";
    begin
        DDNSetup.get();
        clear(BestCountry_iCod);
        if not DDNSetup."enable Version Calc Item Card" then
            exit;

        BestCountry_iCod := CalcBestCountryPurchase(item_vRec."trm Master No.", ItemMasterDetail.getSalesColorCode_gFnc(item_vRec."No."));
        exit(true)
    end;


}
