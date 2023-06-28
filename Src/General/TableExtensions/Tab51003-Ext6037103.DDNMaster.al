tableextension 51003 "DDN Master" extends "trm Master"
{
    fields
    {
        /// <summary>
        /// prüft mit Hilfe des Flow Filter DDN Catalog Relation Filters ob ein Master in einem Katalog enthalten ist
        /// <see cref="#V7ZN"/>
        /// </summary>
        field(51000; "DDN Included in Catalog"; Boolean)
        {
            Caption = 'is included in Catalog';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = exist("trm Collection Master Relation" where("No." = field("No."), "Collection No." = field("DDN Catalog Relation Filter"), "DDN Collection Classification" = const(Catalog)));
        }

        /// <summary>
        /// prüft mittels Flow Filter "DDN Collection Relation Filter" ob ein Master in einer Kollektion enthalten ist.
        /// <see cref="#V7ZN"/>
        /// </summary>
        field(51001; "DDN Included in Collection"; Boolean)
        {
            Caption = 'is included in Collection';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = exist("trm Collection Master Relation" where("No." = field("No."), "Collection No." = field("DDN Collection Relation Filter"), "DDN Collection Classification" = const(Collection)));
        }

        /// <summary>
        /// FlowFilter zur Berechnung von <c>DDN Included in Catalog</c>
        /// <see cref="#V7ZN"/>
        /// </summary>
        field(51002; "DDN Catalog Relation Filter"; Code[255])
        {
            Caption = 'Catalog Relation Filter';
            FieldClass = FlowFilter;
            TableRelation = "trm Collection" where("DDN Classification" = const(Catalog));
        }

        /// <summary>
        /// FlowFilter zur Berechnung von <c>DDN Included in Collection</c>
        /// <see cref="#V7ZN"/>
        /// </summary>
        field(51003; "DDN Collection Relation Filter"; Code[255])
        {
            Caption = 'Collection Relation Filter';
            FieldClass = FlowFilter;
            TableRelation = "trm Collection" where("DDN Classification" = const(Collection));
        }

        /// <summary>
        /// Designer, der das Produkt konzipiert hat.
        /// <see cref="#W3MP"/>
        /// </summary>
        field(51004; "DDN Designer Code"; Code[20])
        {
            Caption = 'Designer Code';
            TableRelation = "Salesperson/Purchaser" where("DDN Vendor Classification" = const(Designer));
            trigger OnValidate()
            begin
                if Rec."DDN Designer Code" <> xRec."DDN Designer Code" then begin
                    CORDDNUpdateItem(FieldName("DDN Designer Code"));
                end
            end;
        }

        /// <summary>
        /// Speichert die Zolltarifnummer, die für die Zollabfertigung in den USA vorgehalten werden muss
        /// <see cref="#6M4D"/>
        /// </summary>
        field(51005; "DDN US Tariff No."; Code[20])
        {
            Caption = 'US Tariff No.';
            DataClassification = CustomerContent;
            TableRelation = "Tariff Number";

            trigger OnValidate()
            begin
                if ("DDN US Tariff No." <> xRec."DDN US Tariff No.") then
                    CORDDNUpdateItem(FieldName("DDN US Tariff No."));
            end;
        }

        /// <summary>
        /// Bestimmt, ob eine Stückliste im Verkauf automatisch entfaltet werden muss
        /// <see cref="#DM4X"/>
        /// </summary>
        field(51006; "DDN Auto Explode BOM"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'automatic BOM Explosion in Sales Line';
        }
        /// <summary>
        /// Bestimmt, ob beim Entfalten der Stückliste die Artikelnummer des Möbels in das dafür vorgesehen Feld der VK-Zeile geschrieben werden darf.
        /// <see cref="#DM4X"/>
        /// </summary>
        field(51007; "DDN enable Bom Creation for BI"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Calculate furniture item no. in Sales Line';
        }

        /// <summary>
        /// Speichert den Faserverbrauch eines Kissens. Rein informativ
        /// <see cref="#1QA2"/>
        /// </summary>
        field(51008; "DDN Fabric Consumption"; Decimal)
        {
            Caption = 'Fabric Consumtion';
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 2;

            trigger OnValidate()
            var
                onlyMasterItem_loc: Boolean;
                locationMandatoryWarning_loc: Boolean;
                maintenanceSetup_loc: Record "trm Maintenance Setup";
                ChangeItemDialog_lLbl: label 'Do you want to change all related Items?';
                Item_lRec: Record Item;
            begin
                if ("DDN Fabric Consumption" <> xRec."DDN Fabric Consumption") then
                    CORDDNUpdateItem(FieldName("DDN Fabric Consumption"));
            end;
        }
    }

    /// <summary>
    /// Löscht alle Artikel, die zu einem Master generiert wurden
    /// <see cref="#L9GA"/>
    /// </summary>
    procedure deleteRelatedItems()
    var
        item_lRec: Record Item;
        NoRelatedItemExists_Lbl: Label 'No related Item was created. There is nothing to delete.';
        ConfirmDeleteDialog_lbl: Label 'Do you want to delete %1 item(s)?';
    begin
        item_lRec.trmSet_SkipTestItemIsActive(true);
        item_lRec.SetRange("trm Master No.", Rec."No.");
        item_lRec.setfilter("trm Item Type", '<>%1', item_lRec."trm Item Type"::"Master Item");
        if not item_lRec.findset then
            Error(NoRelatedItemExists_Lbl);
        if not confirm(ConfirmDeleteDialog_lbl, true, item_lRec.Count) then
            Error('');
        item_lRec.DeleteAll(true);
    end;

    procedure repairMatrixCell()
    var
        MatrixCell: Record "trm Matrix Cell";
        countLines: Integer;
        AllLinesOk_lLbl: Label 'All Matrix Cells carry a item no. Nothing needs to be done.';
        ConfirmDlg_lLbl: Label 'Do your want to %1 to be checked and repaired if nescessary?';
        RepairedLines_lLbl: Label 'An item no. has been assigend to %1 Matrix Cells';
    begin
        MatrixCell.SetRange("Relation 1", MatrixCell."Relation 1"::Matrix);
        MatrixCell.setrange("Relation 1 Name", Rec."No.");
        MatrixCell.setfilter("Created Item No.", '''''');

        if not MatrixCell.findset then begin
            message(AllLinesOk_lLbl);
            exit;
        end;
        if not confirm(ConfirmDlg_lLbl, true, MatrixCell.count) then
            exit;

        repeat
            if (MatrixCell."VarDim Y-Axis" + MatrixCell."Variant No.") <> MatrixCell."Created Item No." then begin
                countLines += 1;
                MatrixCell."Created Item No." := MatrixCell."VarDim Y-Axis" + MatrixCell."Variant No.";
                MatrixCell.modify;
            end;
        until MatrixCell.next = 0;

        if countLines = 0 then begin
            message(AllLinesOk_lLbl);
        end
        else begin
            message(RepairedLines_lLbl, countLines);
        end;
    end;


    procedure CORDDNUpdateItem(fieldName_par: Text[80])
    var
        onlyMasterItem_loc: Boolean;
        locationMandatoryWarning_loc: Boolean;
        maintenanceSetup_loc: Record "trm Maintenance Setup";
        ChangeItemDialog_lLbl: label 'Do you want to change all related Items?';
        Item_lRec: Record Item;
    begin
        Item_lRec.setrange("trm Master No.", Rec."No.");
        onlyMasterItem_loc := false;
        maintenanceSetup_loc.Reset;
        maintenanceSetup_loc.SetRange("Table Relation 2", 6037103);
        maintenanceSetup_loc.SetRange("Field Relation 2", CurrFieldNo);

        if not maintenanceSetup_loc.FindFirst then begin
            if not Confirm(ChangeItemDialog_lLbl, true) then
                onlyMasterItem_loc := true;
        end else
            case maintenanceSetup_loc."Automatic Update" of
                maintenanceSetup_loc."automatic update"::"Ask (Default Yes)":
                    if not Confirm(ChangeItemDialog_lLbl, true) then
                        onlyMasterItem_loc := true;
                maintenanceSetup_loc."automatic update"::"Ask (Default No)":
                    if not Confirm(ChangeItemDialog_lLbl, false) then
                        onlyMasterItem_loc := true;
                maintenanceSetup_loc."automatic update"::No:
                    onlyMasterItem_loc := true;
                maintenanceSetup_loc."automatic update"::Yes:
                    begin
                    end;
            end;
        if onlyMasterItem_loc then begin
            Item_lRec.SetRange("trm Item Type", Item_lRec."trm item type"::"Master Item");
            if not Item_lRec.FindSet then
                exit;
        end;
        case fieldName_par of
            fieldname("DDN Fabric Consumption"):
                Item_lRec.ModifyAll("DDN Fabric Consumption", "DDN Fabric Consumption", false);
            fieldName("DDN Designer Code"):
                item_lRec.ModifyAll("DDN Designer Code", "DDN Designer Code", false);
            fieldName("DDN US Tariff No."):
                item_lRec.ModifyAll("DDN US Tariff No.", "DDN US Tariff No.", false);

        end;
    end;
}