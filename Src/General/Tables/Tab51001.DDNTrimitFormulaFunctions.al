table 51001 "DDN Trimit Functions"
{
    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Result (Text)"; Text[250])
        {
            Caption = 'Primary Key';
            DataClassification = ToBeClassified;
        }
        field(3; "Result (Decimal)"; Decimal)
        {
            Caption = 'Result (Decimal)';
            DataClassification = ToBeClassified;
        }
        field(4; "Result (Integer)"; Integer)
        {
            Caption = 'Result (Integer)';
            DataClassification = ToBeClassified;
        }
        field(5; "Result (Date)"; Date)
        {
            Caption = 'Result (Date)';
            DataClassification = ToBeClassified;
        }
        field(6; "Result (Time)"; Time)
        {
            Caption = 'Result (Time)';
            DataClassification = ToBeClassified;
        }
        field(7; "Result (DateTime)"; DateTime)
        {
            Caption = 'Result (DateTime)';
            DataClassification = ToBeClassified;
        }
        field(8; "Result (Code)"; Code[250])
        {
            Caption = 'Result (Code)';
            DataClassification = ToBeClassified;
        }
        field(9; "Result (Boolean)"; Boolean)
        {
            Caption = 'Result (Boolean)';
            DataClassification = ToBeClassified;
        }
        field(10; "Field Reference 1"; Code[20])
        {
            Caption = 'Field Reference 1';
            DataClassification = ToBeClassified;
        }
        field(11; "Field Reference 2"; Code[20])
        {
            Caption = 'Field Reference 2';
            DataClassification = ToBeClassified;
        }
        field(12; "Field Reference 3"; Code[20])
        {
            Caption = 'Field Reference 3';
            DataClassification = ToBeClassified;
        }
        field(13; "Field Reference 4"; Code[20])
        {
            Caption = 'Field Reference 4';
            DataClassification = ToBeClassified;
        }
        field(14; "Field Reference 5"; Code[20])
        {
            Caption = 'Field Reference 5';
            DataClassification = ToBeClassified;
        }
        field(15; "Field Reference 6"; Code[20])
        {
            Caption = 'Field Reference 6';
            DataClassification = ToBeClassified;
        }
        field(16; "Field Reference 7"; Code[20])
        {
            Caption = 'Field Reference 7';
            DataClassification = ToBeClassified;
        }
        field(17; "Field Reference 8"; Code[20])
        {
            Caption = 'Field Reference 8';
            DataClassification = ToBeClassified;
        }
        field(18; "Field Reference 9"; Code[20])
        {
            Caption = 'Field Reference 9';
            DataClassification = ToBeClassified;
        }
        field(19; "Field Reference 10"; Code[20])
        {
            Caption = 'Field Reference 10';
            DataClassification = ToBeClassified;
        }

        field(20; "Field Reference 11"; Text[100])
        {
            Caption = 'Field Reference 11';
            DataClassification = ToBeClassified;
        }
        field(30; "Temp Dec 1"; decimal)
        {
            Caption = 'Temporary Decimal 1 for global variables';
            DataClassification = ToBeClassified;
        }
        field(31; "Temp Dec 2"; decimal)
        {
            Caption = 'Temporary Decimal 2 for global variables';
            DataClassification = ToBeClassified;
        }
        field(32; "Temp Dec 3"; decimal)
        {
            Caption = 'Temporary Decimal 3 for global variables';
            DataClassification = ToBeClassified;
        }
        field(33; "Temp Dec 4"; decimal)
        {
            Caption = 'Temporary Decimal 4 for global variables';
            DataClassification = ToBeClassified;
        }

        field(100; HELLOWORLD; Boolean)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                "Result (Text)" := 'TBL51001';
                "Result (Decimal)" := 51001;
                Message('TBL50300 begrüßt Dich mit einem HELLO WORLD aus Table 51001');
            end;
        }
        field(101; "Function InitDependingVarDim"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Function InitDependingVarDim';

            trigger OnValidate()
            begin
                InitDependingVarDim();
            end;
        }

        field(102; "Function MakeDate"; Boolean)
        {
            trigger OnValidate()
            begin
                MakeDate();
            end;
        }

        field(103; "Function Compar To Workdate"; Boolean)
        {
            trigger OnValidate()
            begin
                CompareToWorkdate();
            end;
        }

        field(104; "Function Compare Dates"; Boolean)
        {
            trigger OnValidate()
            var

            begin
                CompareTwoDates();
            end;
        }
        field(105; "Echo Message"; Boolean)
        {
            trigger OnValidate()
            var

            begin
                EchoMessage();
            end;
        }
        field(106; "Remember Set Item No."; Boolean)
        {
            ObsoleteState = Pending;
            trigger OnValidate()
            var

            begin
                //RememberSetItemNo();
            end;
        }


        /// <summary>
        /// <see cref="#H42U"/>
        /// </summary>
        field(107; "Find best Version"; Boolean)
        {
            Caption = 'Find the best version for a componenten in sales process';

            trigger OnValidate()
            var
                MasterNo_lCode: code[20];
                LocationCode_lCode: Code[20];
                requestedQty_lDec: Decimal;
                requestedDate_lDate: Date;
                VarDim_lCode: array[5] of Code[10];
                NoOptimalVersionFound_lLbl: Label 'No optimal Sales-Version for Master %1 could be found.';
                ddnSetup: Record "DDN Setup";
            begin
                MasterNo_lCode := "Field Reference 1";
                LocationCode_lCode := "Field Reference 2";
                evaluate(requestedQty_lDec, "Field Reference 3");
                if not Evaluate(requestedDate_lDate, "Field Reference 4") then
                    requestedDate_lDate := WorkDate();
                VarDim_lCode[1] := "Field Reference 5";
                VarDim_lCode[2] := "Field Reference 6";
                VarDim_lCode[3] := "Field Reference 7";
                VarDim_lCode[4] := "Field Reference 8";
                VarDim_lCode[5] := "Field Reference 9";
                Rec."Result (Code)" := findOptimalSalesVersion(MasterNo_lCode, LocationCode_lCode, requestedQty_lDec, requestedDate_lDate, VarDim_lCode);
                if Rec."Result (Code)" = '' then begin
                    ddnSetup.get();
                    if ddnSetup."Action no sales version found" = ddnSetup."Action no sales version found"::"show error" then
                        error(NoOptimalVersionFound_lLbl, MasterNo_lCode);
                end
            end;
        }

        /// <summary>
        /// Formel zur Ermittlung der Einkaufsversion
        /// <see cref="#H42U"/>
        /// </summary>
        field(108; "Find best Version 2"; Boolean)
        {
            Caption = 'Find the best version for a componenten in purchase process';

            trigger OnValidate()
            var
                MasterNo_lCode: code[20];
                LocationCode_lCode: Code[20];
                requestedQty_lDec: Decimal;
                requestedDate_lDate: Date;
                VarDim_lCode: array[5] of Code[10];
                NoOptimalVersionFound_lLbl: Label 'No optimal Purchase-Version for Master %1 could be found.';
                ddnSetup: Record "DDN Setup";
            begin
                MasterNo_lCode := "Field Reference 1";
                VarDim_lCode[1] := "Field Reference 2";
                VarDim_lCode[2] := "Field Reference 3";
                VarDim_lCode[3] := "Field Reference 4";
                VarDim_lCode[4] := "Field Reference 5";
                VarDim_lCode[5] := "Field Reference 6";
                Rec."Result (Code)" := findOptimalPurchaseVersion(MasterNo_lCode, VarDim_lCode);

                if Rec."Result (Code)" = '' then begin
                    ddnSetup.get();
                    if ddnSetup."Action no purch version found" = ddnSetup."Action no purch version found"::"show error" then
                        error(NoOptimalVersionFound_lLbl, MasterNo_lCode);
                end
            end;
        }


        field(109; "Caclulate Purch Price"; Boolean)
        {
            Caption = 'Calculate Purchase Price';
            trigger OnValidate()
            var
                ItemNo_lCode: Code[20];
                requestedDate_lDate: date;
                requestedQty_lDec: Decimal;
            begin
                ItemNo_lCode := "Field Reference 1";
                evaluate(requestedQty_lDec, "Field Reference 2");
                Evaluate(requestedDate_lDate, "Field Reference 3");
                Rec."Result (Decimal)" := CalcPurchPrice(ItemNo_lCode, requestedQty_lDec, requestedDate_lDate);
            end;
        }

        field(110; "Get Purch Currency Code"; Boolean)
        {
            Caption = 'Get Purchase Currency Code';

            trigger OnValidate()
            var
                ItemNo_lCode: Code[20];
            begin
                ItemNo_lCode := "Field Reference 1";
                Rec."Result (Code)" := GetPurchCurrency(ItemNo_lCode)
            end;
        }

        field(111; "Get Currency Exchange Rate"; Boolean)
        {
            Caption = 'Get Currency Exchange Rate';

            trigger OnValidate()
            var
                CurrencyCode1, CurrencyCode2 : Code[10];
                requestedDate_lDate: Date;
            begin
                Evaluate(requestedDate_lDate, "Field Reference 1");
                CurrencyCode1 := Rec."Field Reference 2";
                if CurrencyCode1 = '0' then
                    clear(CurrencyCode1);
                CurrencyCode2 := Rec."Field Reference 3";
                if CurrencyCode2 = '0' then
                    clear(CurrencyCode2);
                Rec."Result (Decimal)" := GetIntercompanyExchangeRate(requestedDate_lDate, CurrencyCode1, CurrencyCode2);
            end;
        }

        field(112; "Find best Country"; Boolean)
        {
            Caption = 'Find the best country for a componenten in sales process';

            trigger OnValidate()
            var
                MasterNo_lCode: code[20];
                LocationCode_lCode: Code[20];
                requestedQty_lDec: Decimal;
                requestedDate_lDate: Date;
                VarDim_lCode: array[5] of Code[10];
                NoOptimalCountryFound_lLbl: Label 'No optimal Country for Master %1 could be found.';
                ddnSetup: Record "DDN Setup";
            begin
                MasterNo_lCode := "Field Reference 1";
                LocationCode_lCode := "Field Reference 2";
                evaluate(requestedQty_lDec, "Field Reference 3");
                if not Evaluate(requestedDate_lDate, "Field Reference 4") then
                    requestedDate_lDate := WorkDate();
                VarDim_lCode[1] := "Field Reference 5";
                VarDim_lCode[2] := "Field Reference 6";
                VarDim_lCode[3] := "Field Reference 7";
                VarDim_lCode[4] := "Field Reference 8";
                VarDim_lCode[5] := "Field Reference 9";
                Rec."Result (Code)" := findOptimalSalesCountry(MasterNo_lCode, LocationCode_lCode, requestedQty_lDec, requestedDate_lDate, VarDim_lCode);
                if Rec."Result (Code)" = '' then begin
                    ddnSetup.get();
                    if ddnSetup."Action no sales version found" = ddnSetup."Action no sales version found"::"show error" then
                        error(NoOptimalCountryFound_lLbl, MasterNo_lCode);
                end
            end;
        }
        field(113; "Find best Country 2"; Boolean)
        {
            Caption = 'Find the best country for a component in purchase process';

            trigger OnValidate()
            var
                MasterNo_lCode: code[20];
                LocationCode_lCode: Code[20];
                requestedQty_lDec: Decimal;
                requestedDate_lDate: Date;
                VarDim_lCode: array[5] of Code[10];
                NoOptimalCountryFound_lLbl: Label 'No optimal Country for Master %1 could be found.';
                ddnSetup: Record "DDN Setup";
            begin
                MasterNo_lCode := "Field Reference 1";
                Rec."Result (Code)" := findOptimalPurchaseCountry(MasterNo_lCode);
                if Rec."Result (Code)" = '' then begin
                    ddnSetup.get();
                    if ddnSetup."Action no purch version found" = ddnSetup."Action no purch version found"::"show error" then
                        error(NoOptimalCountryFound_lLbl, MasterNo_lCode);
                end
            end;
        }

        field(114; "Temp Dec 5"; decimal)
        {
            Caption = 'Temporary Decimal 5 for global variables';
            DataClassification = ToBeClassified;
        }

        field(115; "Cacl Component Demand"; Boolean)
        {
            Caption = 'Calculate the demand of acomponente in a bom; no matter if called via SalesLine or by expanding a bom within production';

            trigger OnValidate()
            var
                qtyInSalesLine: Decimal;
                qtyInProductionLine: Decimal;
                qtyPerItemInProductionLine: Decimal;
                qtyTotalDemand: Decimal;
            begin
                if not evaluate(qtyInSalesLine, "Field Reference 1") then;
                if not evaluate(qtyInProductionLine, "Field Reference 2") then;
                if not evaluate(qtyPerItemInProductionLine, "Field Reference 3") then;
                if qtyInSalesLine <> 0 then
                    qtyTotalDemand := qtyInSalesLine
                else
                    qtyTotalDemand := qtyInProductionLine;
                "Result (Decimal)" := qtyTotalDemand * qtyPerItemInProductionLine;
            end;
        }

    }
    /// <summary>
    /// Sucht in den VarDim Kombinationen nach dem Wert einer abhängigen Dimension
    /// Die Funktion gibt ausschließlich bei 1zu1 Verknüfungen Werte zurück.
    /// Gleichsam prüft sie auch rückwärts.
    /// </summary>
    local procedure InitDependingVarDim()
    var
        MasterNo: Code[20];
        //Nummer und Wert der Vardim, über die gesucht wird
        VarDim1Name, VarDim1Value, VarDim2Name, VarDim2Value : Code[20];
        VarDimCombination: record "trm VarDim Combination";
    begin
        // Parameter 1: Master Nr.
        MasterNo := "Field Reference 1";
        // Name der Vardim, die geändert wurde
        VarDim1Name := "Field Reference 2";
        // Wert der Vardim, auf den geändert wurde
        VarDim1Value := "Field Reference 3";
        // Name der zu ermittlenden VarDim
        VarDim2Name := "Field Reference 4";

        VarDimCombination.SetRange("Relation 1", VarDimCombination."Relation 1"::Master);
        VarDimCombination.SetRange("Relation 1 No.", MasterNo);
        VarDimCombination.setrange("Overall VarDim Type", VarDim1Name);
        VarDimCombination.setrange("Overall Value", VarDim1Value);
        VarDimCombination.SetRange("Subordinate VarDim Type", VarDim2Name);
        VarDimCombination.SetRange("Relation 2", VarDimCombination."Relation 2"::None);
        VarDimCombination.SetRange(Inactive, false);

        if VarDimCombination.count() = 1 then begin
            VarDimCombination.FindFirst();
            VarDim2Value := VarDimCombination."Subordinate Value";
        end
        else begin

            // Rückwärtssuche
            VarDimCombination.setrange("Overall VarDim Type", VarDim2Name);
            VarDimCombination.setrange("Overall Value");
            VarDimCombination.SetRange("Subordinate VarDim Type", VarDim1Name);
            VarDimCombination.setrange("Subordinate Value", VarDim1Value);

            if VarDimCombination.count() = 1 then begin
                VarDimCombination.FindFirst();
                VarDim2Value := VarDimCombination."Overall Value";
            end
        end;
        //Rec."Result (Code)" := 'COLOR ' + VarDim2Value;
        Rec."Result (Code)" := VarDim2Value;
        Rec."Result (Text)" := VarDim2Value;
        if evaluate("Result (Integer)", VarDim2Value) then;
        //if not confirm('Tab51001 Zu %1=%2 wurde %3=%4 gefunden. Weiter machen?', true, VarDim1Name, VarDim1Value, VarDim2Name, VarDim2Value) then
        //    error('');
    end;

    local procedure MakeDate()
    var
        day, month, year : integer;
        day_lTxt, month_lTxt : Text[2];
    begin
        evaluate(day, "Field Reference 1");
        evaluate(month, "Field Reference 2");
        evaluate(year, "Field Reference 3");
        "Result (Date)" := DMY2DATE(day, month, year);
        if day <= 9 then
            day_lTxt := StrSubstNo('0%1', day)
        else
            day_lTxt := Format(day);

        if month <= 9 then
            month_lTxt := StrSubstNo('0%1', month)
        else
            month_lTxt := Format(month);
        "Result (Code)" := strsubstno('%1-%2-%3', year, month_lTxt, day_lTxt);
    end;

    /// <summary>
    /// CompareToWorkdate gibt in Result (Integer) die Differenz beider Datumsangaben
    /// zurück.
    /// = 0: Datumswerte sind gleich
    /// &lt; 0: Das Datum liegt zeitlich vor dem Arbeitsdatum
    /// &gt; 0: Das Datum liegt zeitlich nach dem Arbeitsdatum
    /// </summary>
    local procedure CompareToWorkdate()
    var
        day, month, year : integer;
    begin
        MakeDate();
        //7if WorkDate()="Result (Date)" then
        //    "Result (Integer)" := 0;
        //else begint
        "Result (Integer)" := "Result (Date)" - WorkDate();
        //end;  
    end;

    local procedure CompareTwoDates()
    var
        date1_lDat, date2_lDat : Date;
    begin
        Evaluate(date1_lDat, "Field Reference 1");
        Evaluate(date2_lDat, "Field Reference 2");
        "Result (Integer)" := date1_lDat - date2_lDat;
    end;

    local procedure EchoMessage()
    var
        myInt: Integer;
    begin
        message(Rec."Field Reference 1" + Rec."Field Reference 2");
    end;

    local procedure calcItemAvailibility()
    var
        myInt: Integer;
    begin

    end;

    /// <summary>
    /// Ermittlung der Versionsnummer eines Artikels basierend auf seiner Verfügbarkeit und seiner Menge im aktuellen Vorgang
    /// <see cref="#H42U"/>
    /// </summary>
    /// <param name="MasterNo"></param>
    /// <param name="LocationCode_iCode"></param>
    /// <param name="VarDim"></param>
    /// <returns></returns>
    procedure findOptimalSalesVersion(MasterNo: Code[20]; LocationCode_iCode: Code[20]; requestedQty_iDec: Decimal; requestDate_iDate: Date; VarDim: array[5] of Code[10]) optimalVersionCode: Code[10]
    var
        ActiveVersionMgmt: Codeunit "COR-DDN ActiveVersion Mgmt.";
    begin
        optimalVersionCode := ActiveVersionMgmt.CalcBestVersionSalesViaTrimitFormula(MasterNo, LocationCode_iCode, requestedQty_iDec, requestDate_iDate, VarDim);
    end;

    procedure findOptimalSalesCountry(MasterNo: Code[20]; LocationCode_iCode: Code[20]; requestedQty_iDec: Decimal; requestDate_iDate: Date; VarDim: array[5] of Code[10]) optimalCountryCode: Code[10]
    var
        ActiveVersionMgmt: Codeunit "COR-DDN ActiveVersion Mgmt.";
    begin
        optimalCountryCode := ActiveVersionMgmt.CalcBestCountrySalesViaTrimitFormula(MasterNo, LocationCode_iCode, requestedQty_iDec, requestDate_iDate, VarDim);
    end;


    procedure findOptimalPurchaseVersion(MasterNo: Code[20]; VarDim: array[5] of Code[10]) optimalVersionCode: Code[10]
    var
        ActiveVersionMgmt: Codeunit "COR-DDN ActiveVersion Mgmt.";
    begin
        optimalVersionCode := ActiveVersionMgmt.CalcBestVersionPurchaseViaTrimitFormula(MasterNo, VarDim);
    end;

    procedure findOptimalPurchaseCountry(MasterNo: Code[20]) optimalCountryCode: Code[10]
    var
        ActiveVersionMgmt: Codeunit "COR-DDN ActiveVersion Mgmt.";
    begin
        optimalCountryCode := ActiveVersionMgmt.CalcBestCountryPurchaseViaTrimitFormula(MasterNo);
    end;

    local procedure CalcPurchPrice(ItemNo: code[20]; requestedQty_iDec: Decimal; requestDate_iDate: Date) purchPrice_lDec: Decimal
    var
        priceCostDetermination: Codeunit "DDN Price/Cost Determination";
        purchPrice_lRec: Record "purchase price";
        item_lRec: Record Item;
        minQty_lDec: Decimal;
    begin
        priceCostDetermination.initUnitCostRequest(ItemNo, requestDate_iDate, requestedQty_iDec);
        priceCostDetermination.Run();
        purchPrice_lDec := priceCostDetermination.getUnitCost();
        // falls kein EK-Preis gefunden wurde kann die Ursache sein, dass EK-Preise Mindestmengen haben und es keinen Datensatz gibt
        // bei dem die Mindestmenge zur angefragten Menge passt
        if purchPrice_lDec <= 0 then begin
            item_lRec.get(ItemNo);
            purchPrice_lRec.SetRange("Item No.", ItemNo);
            purchPrice_lRec.setfilter("Starting Date", '..%1', requestDate_iDate);
            purchPrice_lRec.SetFilter("Minimum Quantity", '>0');
            if item_lRec."Vendor No." <> '' then
                purchPrice_lRec.SetRange("Vendor No.", item_lRec."Vendor No.");

            // pragmatisch die Zeile mit der geringsten Menge ermittelln
            // ja, die Logik ist verbesserungswürdig; passt aber so für Dedon
            minQty_lDec := -1;
            if purchPrice_lRec.FindSet() then begin
                minQty_lDec := purchPrice_lRec."Minimum Quantity";
                repeat
                    if purchPrice_lRec."Minimum Quantity" < minQty_lDec then
                        minQty_lDec := purchPrice_lRec."Minimum Quantity";
                until Rec.Next() = 0;
            end;

            if minQty_lDec > 0 then begin
                priceCostDetermination.initUnitCostRequest(ItemNo, requestDate_iDate, minQty_lDec);
                priceCostDetermination.Run();
                purchPrice_lDec := priceCostDetermination.getUnitCost();
            end;
        end
    end;

    /// <summary>
    /// Ermtitelt an Hand des KReditors hinter dem Artikel den Währungscode für dne Einkauf
    /// </summary>
    /// <param name="ItemNo"></param>
    /// <returns></returns>
    local procedure GetPurchCurrency(ItemNo: code[20]) currencyCode: Code[10]
    var
        master: Record "trm Master";
        item: Record Item;
        Vendor: Record Vendor;
    begin
        item.get(ItemNo);
        if item."Vendor No." <> '' then begin
            Vendor.get(item."Vendor No.");
            currencyCode := Vendor."Currency Code";
        end
        else begin
            if item."trm Master No." <> '' then begin
                master.get(item."trm Master No.");
                if master."Vendor No." <> '' then begin
                    Vendor.get(Master."Vendor No.");
                    currencyCode := Vendor."Currency Code";
                end;
            end;
        end;
    end;

    local procedure GetIntercompanyExchangeRate(requestedDate_iDate: Date; CurrencyCode1_iCode: code[10]; CurrencyCode2_iCode: code[10]) ExchangeRate: Decimal
    var
        ddnSetup: Record "DDN Setup";
        searchTableLine: Record "trm Search Table Line";
        searchTableHeader: Record "trm Search Table Header";
        glSetup: Record "General Ledger Setup";
    begin
        ddnSetup.get;
        glSetup.get;
        ddnSetup.TestField("IC Currency Exch. Search Table");
        searchTableLine.setrange("Table ID", ddnSetup."IC Currency Exch. Search Table");
        searchTableLine.setrange(Inactive, false);
        // Mandantenwährung berückischtigen
        if CurrencyCode1_iCode <> '' then begin
            searchTableLine.SetRange("Column 1 (Code)", CurrencyCode1_iCode);
        end
        else begin
            glSetup.get();
            searchTableLine.setfilter("Column 1 (Code)", '%1|%2', CurrencyCode1_iCode, glSetup."LCY Code");
        end;

        if CurrencyCode2_iCode <> '' then begin
            searchTableLine.SetRange("Column 2 (Code)", CurrencyCode2_iCode);
        end
        else begin
            glSetup.get();
            searchTableLine.setfilter("Column 2 (Code)", '%1|%2', CurrencyCode2_iCode, glSetup."LCY Code");
        end;

        searchTableLine.setfilter(Date, '..%1', requestedDate_iDate);
        if searchTableLine.FindFirst() then
            exit(searchTableLine."Result 1 (Decimal)");
        // Falls nichts hinterlegt nehme den Defuatl-wert der Suchtabelle
        searchTableHeader.get(ddnSetup."IC Currency Exch. Search Table");
        exit(searchTableHeader."Value (Dec.) No Value Returned");
    end;
}