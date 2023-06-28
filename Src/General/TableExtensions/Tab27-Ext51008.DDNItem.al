/// <summary>
/// TableExtension DDN Item (ID 51008) extends Record Item.
/// <see cref="#HR3T"/>
/// <see cref="#6M4D"/>
/// </summary>
tableextension 51008 "DDN Item" extends Item //27
{

    fields
    {
        /// <summary>
        /// Speichert die Zolltarifnummer, die für die Zollabfertigung in den USA vorgehalten werden muss.
        /// Anforderung [146]
        /// <see cref="#6M4D"/>
        /// </summary>
        field(51000; "DDN US Tariff No."; Code[20])
        {
            Caption = 'US Tariff No.';
            DataClassification = CustomerContent;
            TableRelation = "Tariff Number";
        }

        field(51001; "DDN Indentation"; Integer)
        {
            //CalcFormula = count(Item where("no." = FIELD("No."), "trm Item Type" = filter(<> "Master Item")));
            //FieldClass = FlowField;
            Caption = 'Indentation';
            Editable = false;
        }
        /// <summary>
        /// <see cref="#7YAB"/>
        /// </summary>
        field(51002; "DDN Item Planning Status Code"; Code[20])
        {
            Caption = 'Planning Status';
            DataClassification = CustomerContent;
            TableRelation = "DDN Universal Classification".Code where(Type = const(ItemPlanningStatus));
        }
        /// <summary>
        /// <see cref="#HR3T"/>
        /// </summary>
        field(51003; "DDM Legacy System Item No."; Code[20])
        {
            Caption = 'Legacy System Item No.';
            DataClassification = ToBeClassified;
        }

        /// <summary>
        /// Speichert den Faserverbrauch eines Kissens. Rein informativ
        /// <see cref="#1QA2"/>
        /// </summary>
        field(51004; "DDN Fabric Consumption"; Decimal)
        {
            Caption = 'Fabric Consumption';
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 2;
        }

        /// <summary>
        /// <see cref="#8HRF"/>
        /// </summary>
        field(51005; "DDN Item Status Code"; Code[20])
        {
            Editable = false;
            Caption = 'Item Status Code';
            FieldClass = FlowField;
            CalcFormula = lookup("trm Matrix Cell"."Status Code" where("Created Item No." = field("No.")));
        }
        /// <summary>
        /// <see cref="#8HRF"/>
        /// </summary>
        field(51006; "DDN Master Collection No."; Code[20])
        {
            Editable = false;
            Caption = 'Master Collection No.';
            FieldClass = FlowField;
            CalcFormula = lookup("trm Master"."Collection No." where("No." = field("trm Master No.")));
        }

        /// <summary>
        /// <see cref="#H42U"/>
        /// </summary>
        field(51007; "is active Version"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Active Version';
            ObsoleteReason = 'Deprecated because of usage of field Status as a flowField to MatrixCell';
            ObsoleteState = Pending;
            ObsoleteTag = '22.0.1.10';

            trigger OnValidate()
            var
                myInt: Integer;
                x: Codeunit "user setup management";
            begin
                // SetThisItemAsActiveVersion(true);
            end;
        }

        /// <summary>
        /// Wird genutzt um auf der Artikelkarte Mengen vorzubestimmen, die für die Version-Optimierun
        /// im Verkauf relevant sind.
        /// <see cref="#H42U"/>
        /// </summary>
        field(51008; "COR-DDN Sales Qty. Filter 1"; Decimal)
        {
            FieldClass = FlowFilter;
            Caption = 'Quantity Filter 1 for Sales Version';
        }

        /// <summary>
        /// Wird genutzt um auf der Artikelkarte Mengen vorzubestimmen, die für die Version-Optimierun
        /// im Verkauf relevant sind.
        /// <see cref="#H42U"/>
        /// </summary>        
        field(51009; "COR-DDN Sales Qty. Filter 2"; Decimal)
        {
            FieldClass = FlowFilter;
            Caption = 'Quantity Filter 2 for Sales Version';
        }
        field(51010; "DDN Item Status Code 2"; Code[20])
        {
            Caption = 'Item Status Code 2';
            TableRelation = "trm Status Code"."Status Code";

            trigger OnValidate()
            var
            begin
                TestField("trm Master No.", '');
            end;
        }
        /// <summary>
        /// Designer, der das Produkt konzipiert hat.
        /// <see cref="#W3MP"/>
        /// </summary>
        /// <see cref="https://dedongroup.atlassian.net/browse/DEDT-556"/>
        field(51011; "DDN Designer Code"; Code[20])
        {
            Caption = 'Designer Code';
            TableRelation = "Salesperson/Purchaser" where("DDN Vendor Classification" = const(Designer));
        }

        field(51012; "COR-DDN Listprice"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
            Caption = 'Listprice';
        }
        field(51013; "COR-DDN Intercompany price"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
            Caption = 'Intercompany price';
        }
    }

    fieldgroups
    {
        /// <see cref="#HR3T"/>
        /// "No. 2." enstspricht bei DEDON der "alten Artikelnummer" aus voriger BC-Version. Sie muss auswählbar sein.
        addlast(DropDown; "No. 2", "DDM Legacy System Item No.", "DDN Item Status Code")
        { }
    }

    /// <summary>
    /// Ermittelt einen Verkaufspreis, der als "Listenpreis" erfragt werden kann
    /// <see cref="#K2RD"/>
    /// </summary>
    /// <returns>Return variable ret_Dec of type Decimal.</returns>
    procedure getDefaultUnitPrice() ret_Dec: Decimal
    var
        "DDN Price/Cost Determination": Codeunit "DDN Price/Cost Determination";
        ddnSetup: Record "DDN Setup";
    begin
        //"DDN Price/Cost Determination".initUnitPriceRequest("No.");
        ddnSetup.get();
        if ddnSetup."Listprice Customer" <> '' then begin
            "DDN Price/Cost Determination".initUnitPriceRequest("No.", workdate(), 1, ddnSetup."Listprice Customer");
            if not "DDN Price/Cost Determination".run() then
                exit(-0.00001);

            exit("DDN Price/Cost Determination".getUnitPrice());
        end;
    end;

    procedure getIntercompanyPrice() ret_Dec: Decimal
    var
        "DDN Price/Cost Determination": Codeunit "DDN Price/Cost Determination";
        ddnSetup: Record "DDN Setup";
    begin
        ddnSetup.get();
        if ddnSetup."Intercompany Customer" <> '' then begin
            "DDN Price/Cost Determination".initUnitPriceRequest("No.", workdate(), 1, ddnSetup."Intercompany Customer");
            if not "DDN Price/Cost Determination".run() then
                exit(-0.00001);

            exit("DDN Price/Cost Determination".getUnitPrice());
        end;
    end;

    trigger OnModify()
    var
        myInt: Integer;
    begin
        // #8HRF
        CalcIndentation();
    end;


    /// <summary>
    /// <see cref="#8HRF"/>
    /// </summary>
    procedure CalcIndentation()
    var
        myInt: Integer;
    begin
        if "trm Item Type" = "trm Item Type"::"Master Item" then
            "DDN Indentation" := 0
        else
            "DDN Indentation" := 1;
    end;

    /// <summary>
    /// Ermittelt, ob es sich gem. DEDON-Einrichtung um einen Artikel handelt, der Fabrics als Angabe beinhaltetn darf.
    /// Nutze diese Funktion um zu ermitteln, ob Informationen zu Fabrics ein oder ausgebelndet werden.
    /// <see cref="#1QA2"/>
    /// </summary>
    /// <returns>Return value of type Boolean.</returns>
    procedure fabricsEnabled(): Boolean
    var
        item_lRec: Record item;
        ddnSetup_lRec: Record "DDN Setup";
    begin
        ddnSetup_lRec.get;
        if ddnSetup_lRec."Fabric Item Categories" = '' then
            exit(false);
        item_lRec.SetRange("No.", Rec."No.");
        item_lRec.SetFilter("Item Category Code", ddnSetup_lRec."Fabric Item Categories");
        exit(not item_lRec.IsEmpty);
    end;

    procedure isActiveVersion() ret: Boolean
    var
        VarDimItem_lRec: Record "trm VarDim Item";
        color_lCod, Version_lCod : Code[10];
        SearchTableLine_lRec: Record "trm Search Table Line";
    begin
        if Rec."trm Master No." = '' then
            exit;
        // hole den Farbcode des Artikels
        VarDimItem_lRec.SetRange("Relation 1", VarDimItem_lRec."Relation 1"::Item);
        VarDimItem_lRec.SetRange("Relation 1 Name", Rec."No.");
        VarDimItem_lRec.SetFilter("VarDim Type", 'COL_*');
        if VarDimItem_lRec.FindFirst() then begin
            color_lCod := VarDimItem_lRec.Value;
        end;
        // hole die Version des Artikels
        VarDimItem_lRec.SetRange("VarDim Type", 'VERSION');
        if VarDimItem_lRec.FindFirst() then begin
            Version_lCod := VarDimItem_lRec.Value;
        end;

        // Suche in Suchtabelle nach Kombination mit Farbcode
        SearchTableLine_lRec.SetRange("Table ID", 'ACTIVEVERSION');
        SearchTableLine_lRec.setrange("Column 1 (Code)", Rec."trm Master No.");
        SearchTableLine_lRec.setrange("Column 2 (Code)", color_lCod);
        SearchTableLine_lRec.SetRange("Result 1 (Code)", Version_lCod);

        if not SearchTableLine_lRec.IsEmpty then begin
            exit(true);
        end;
        // Suche in Suchtabelle ohne Farbcode
        SearchTableLine_lRec.setrange("Column 2 (Code)");

        if not SearchTableLine_lRec.IsEmpty then
            exit(true);
    end;


    procedure CalcBestVersionAndCountrySalesOnItemCard(var BestVersion_vCod: array[2] of Code[10]; var BestCountry_vCod: array[2] of Code[10]; var thisItemIsBestVersionAndCountry_iBool: array[2] of Boolean; doInitQuantityFilters: Boolean)
    var
        ActiveVerionMgmt: Codeunit "COR-DDN ActiveVersion Mgmt.";
        VersionOfThisItem: Code[10];
        CountryOfThisItem: Code[10];
        i: Integer;
    begin
        clear(thisItemIsBestVersionAndCountry_iBool);
        clear(BestCountry_vCod);
        clear(BestVersion_vCod);
        clear(VersionOfThisItem);
        clear(CountryOfThisItem);
        if not ActiveVerionMgmt.BestVersionAndCountryApplicable(Rec) then
            exit;
        if ActiveVerionMgmt.CalcBestVersionSalesOnItemCard(Rec, BestVersion_vCod, doInitQuantityFilters) then begin
            VersionOfThisItem := ActiveVerionMgmt.getItemVersion(Rec);
            ActiveVerionMgmt.CalcBestCountrySalesOnItemCard(Rec, BestCountry_vCod, doInitQuantityFilters);
            if ActiveVerionMgmt.CalcBestCountrySalesOnItemCard(Rec, BestCountry_vCod, doInitQuantityFilters) then begin
                // Prüfung, ob die Versionsnummer des ermittelten Artikels gleich der Versionsnummer des best passendsten Version ist
                CountryOfThisItem := ActiveVerionMgmt.getItemCountry(Rec);
                for i := 1 to ArrayLen(BestVersion_vCod) do begin
                    thisItemIsBestVersionAndCountry_iBool[i] := (VersionOfThisItem = BestVersion_vCod[i]) and (CountryOfThisItem = BestCountry_vCod[i]);
                end;
            end;
        end;
    end;

    procedure CalcBestVersionAndCountryPurchaseOnItemCard(var BestVersion_iCod: Code[10]; var BestCountry_iCod: Code[10]; var thisItemIsBestVersionAndCountry_iBool: Boolean; var ItemUsesCountry: Boolean)
    var
        ActiveVerionMgmt: Codeunit "COR-DDN ActiveVersion Mgmt.";
        VersionOfThisItem: Code[10];
        CountryOfThisItem: Code[10];
    begin
        clear(thisItemIsBestVersionAndCountry_iBool);
        clear(VersionOfThisItem);
        clear(CountryOfThisItem);
        clear(BestCountry_iCod);
        clear(BestVersion_iCod);
        clear(ItemUsesCountry);
        if not ActiveVerionMgmt.BestVersionAndCountryApplicable(Rec) then
            exit;
        if ActiveVerionMgmt.CalcBestVerisonPurchaseOnItemCard(Rec, BestVersion_iCod) then begin
            VersionOfThisItem := ActiveVerionMgmt.getItemVersion(Rec);
            ItemUsesCountry := ActiveVerionMgmt.ItemUsesCountry(Rec);
            if ItemUsesCountry then begin
                if ActiveVerionMgmt.CalcBestCountryPurchaseOnItemCard(Rec, BestCountry_iCod) then begin
                    // Prüfung, ob die Versionsnummer des ermittelten Artikels gleich der Versionsnummer des best passendsten Version ist                
                    CountryOfThisItem := ActiveVerionMgmt.getItemCountry(Rec);
                    thisItemIsBestVersionAndCountry_iBool := (VersionOfThisItem = BestVersion_iCod) and (CountryOfThisItem = BestCountry_iCod);
                end;
            end
            else begin
                thisItemIsBestVersionAndCountry_iBool := (VersionOfThisItem = BestVersion_iCod);
            end;
        end;
    end;

    procedure printLabel(labelFormat: Option A4,A6)
    var
        ddnSetup: Record "DDN Setup";
        item_lRec: Record item;
    begin
        item_lRec.SetRange("No.", Rec."No.");
        printLabel(item_lRec, labelFormat);
    end;

    procedure printLabel(var Item_vRec: Record Item; labelFormat: Option A4,A6)
    var
        ddnSetup: Record "DDN Setup";
        item_lRec: Record item;
        itemNoFilter: Text;
    begin
        ddnSetup.get();
        if Item_vRec.findset then
            repeat
                if itemNoFilter <> '' then
                    itemNoFilter += '|';
                itemNoFilter += Item_vRec."No.";
            until Item_vRec.next = 0;
        item_lRec.setfilter("No.", itemNoFilter);
        case labelFormat of
            labelFormat::A4:
                begin
                    ddnSetup.TestField("Report ID Item Label A4");
                    Report.run(ddnSetup."Report ID Item Label A4", true, false, item_lRec);
                end;
            labelFormat::A6:
                begin
                    ddnSetup.TestField("Report ID Item Label A6");
                    Report.run(ddnSetup."Report ID Item Label A6", true, false, item_lRec);
                end;
        end;
    end;

    /// <summary>
    /// Ersatzteile haben keinen Master. Es ist aber Stand, 22.02.2023 zwingend erforderlich, trotzdem einen Satuscode
    /// am Artikel zu haben. Er kann in dem Fall nicht über MatrixCell und FlowFeld berechnet werden
    /// Diese Funktion wird genutzt um einen einzigen satuscode in Listen anzuzeigen.
    /// </summary>
    procedure getStatusCode(): Code[20]
    var

    begin
        if Rec."trm Master No." <> '' then begin
            Rec.calcfields("DDN Item Status Code");
            exit(rec."DDN Item Status Code")
        end
        else begin
            exit(Rec."DDN Item Status Code 2");
        end;
    end;
}