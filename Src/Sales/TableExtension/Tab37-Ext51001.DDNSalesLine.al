tableextension 51001 "DDN Sales Line" extends "Sales Line" //37
{
    fields
    {
        /// <summary>
        /// verhindert, dass das Warenausgangsdatum durch automatische Aktualisierungen verändert wird
        /// Anforderung [B-060]
        /// <see cref="#3N8B"/>
        /// </summary>
        field(51000; "DDN lock Shiment Date"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Lock Shipment Date';
        }

        /// <summary>
        /// Dient zur Filterung von Auftragszeilen um dem Sachbearbeiter eine Filterung
        /// der Positionen zu ermöglichen, die er in den Warenausgang geben kann oder
        /// die ggf. händiger Nacharbeit bedürfen.
        /// <see cref="#D5C7"/>
        /// </summary>
        field(51001; "DDN Processing Hint"; Option)
        {
            Caption = 'Processing Hint';
            DataClassification = ToBeClassified;
            OptionMembers = " ",OnStock,StockCritical,OutOfStock,sameDayConflict,noPurchaseInSight,DirectShipmentPoCreated,OnStockProjected,OutOfStockProjected;
            OptionCaption = ' ,On Stock,Stock Critical,Out Of Stock,Same Day Conflict,No Purchase Order in sight,Direct Shipment Purchase Order created,will be on stock,will be out of stock';
            Editable = false;

            trigger OnValidate()
            begin
                calcProcessingHintIcon_lFnc();
            end;
        }

        /// <summary>
        /// Icon zur Darstellung in den Auftragszeilen um visuell direkt erkennen zu können, welche
        /// Positionen bedenkenlos oder unter Vorbehalt lieferfähig sind.
        /// </summary>
        field(51002; "DDN Processing Hint Icon"; Text[1])
        {
            Caption = 'Processing Hint Icon';
            DataClassification = ToBeClassified;
            Editable = false;
        }

        /// <summary>
        /// Die Verfügbarkeitsberechnung markiert Datensätze, die verspätet sind
        /// Anforderung [B-080]
        /// <see cref="#D5C7"/>
        /// </summary>
        field(51003; "DDN Shipment Delayed"; Boolean)
        {
            Caption = 'Shipment Delyed';
            DataClassification = ToBeClassified;
            editable = false;
        }

        /// <summary>
        /// Wird in der Page zur Artikelverfügbarkeitsprüfung bzw Bestandszuweisung zur Filterung genutzt
        /// <see cref="#D5C7"/>
        /// </summary>
        field(51004; "DDN Order Released"; Boolean)
        {
            Caption = 'Order Released';
            FieldClass = FlowField;
            CalcFormula = exist("Sales Header" where("Document Type" = field("Document Type"), "No." = field("Document No."), Status = const(Released)));
        }

        /// <summary>
        /// <see cref="#NFSX"/>
        /// </summary>
        field(51005; "DDN Order Intake Date"; Date)
        {
            Caption = 'Order Intake Date';
            Editable = false;
        }
        /// <summary>
        /// Feld gem. Anforderung [B067] erstellt um auf den Status des Headers zu verweisen.
        /// <see cref="#M92Y"/>
        /// </summary>
        field(51006; "DDN Sales Header Status"; Enum "Sales Document Status")
        {
            Caption = 'Sales Header Status';
            FieldClass = FlowField;
            CalcFormula = lookup("Sales Header".Status where("Document Type" = field("Document Type"), "No." = field("Document No.")));
            Editable = false;
        }

        /// <summary>
        /// Artikelnummers des Artikels, der die Auflösung einer stücklsite ausgelöst hat
        /// <see cref="#DM4X"/>
        /// </summary>
        field(51007; "DDN Set Item No. Deprecated"; Code[20])
        {
            TableRelation = "Item";
            Caption = 'Set Item No. Deprecated';
            DataClassification = ToBeClassified;
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to field 51009';
            ObsoleteTag = '22.1.0.7';
        }

        /// <summary>
        /// Masternummer des Artikels, der die Auflösung der Stücklsite ausgelöst hat
        /// <see cref="#DM4X"/>
        /// </summary>
        field(51008; "DDN Set Master No."; Code[20])
        {
            TableRelation = "trm Master";
            Caption = 'Set Master No.';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        /// <summary>
        /// Artikelnummers des Artikels, der die Auflösung einer stücklsite ausgelöst hat
        /// <see cref="#DM4X"/>
        /// </summary>
        field(51009; "DDN Set Item No."; Code[20])
        {
            TableRelation = "Item";
            Caption = 'Set Item No.';
            DataClassification = ToBeClassified;
            Editable = false;
        }

        /// <summary>
        /// <see cref="M92Y"/>
        /// </summary>
        field(51010; "DDN Item Planning Status Code"; Code[20])
        {
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup(Item."DDN Item Planning Status Code" where("No." = field("No.")));
            Caption = 'Itme Planning Status Code';
        }

        /// <summary>
        /// <see cref="#9LUF Menge Set in Belegzeile und Posten"/>
        /// </summary>
        field(51011; "COR-DDN Set Quantity"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Set Quantity';
            Editable = false;
        }

        /// <summary>
        /// <see cref="#U29F"/>
        /// </summary>
        field(51012; "COR-DDN Respons. Person Code"; Code[20])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Sales Header"."COR-DDN Respons. Person Code" where("Document Type" = field("Document Type"), "No." = field("Document No.")));
            TableRelation = "Salesperson/Purchaser";
            Editable = false;
            Caption = 'Responsible Person Code';
        }
        /// <summary>
        /// <see cref="#D5C7"/>
        /// </summary>        
        field(51013; "Sell-to Customer Name"; Text[100])
        {
            Caption = 'Sell-to Customer Name';
            FieldClass = FlowField;
            CalcFormula = lookup("Sales Header"."Sell-to Customer Name" where("Document Type" = field("Document Type"), "No." = field("Document No.")));
            Editable = false;
        }

        /// <summary>
        /// <see cref="#D5C7"/>
        /// </summary>
        field(51014; "COR-DDN Availib. Modified Date"; Date)
        {
            Caption = 'Earliest shipment date modified at';
            DataClassification = ToBeClassified;
            Editable = false;
        }


        /// <summary>
        /// <see cref="#D5C7"/>
        /// </summary>
        field(51017; "COR-DDN earliest Shipment Date"; Date)
        {
            Caption = 'Earliest shipment date (DEDON)';
            DataClassification = ToBeClassified;
        }
        field(51015; "Country/Region of Origin"; Code[20])
        {
            Caption = 'Country/Region of Origin';
            FieldClass = FlowField;
            CalcFormula = lookup(Item."Country/Region of Origin Code" where("No." = field("No.")));
            Editable = false;
        }
        field(51016; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            FieldClass = FlowField;
            CalcFormula = lookup(Item."Vendor No." where("No." = field("No.")));
            Editable = false;
        }
        /// <summary>
        /// zeigt auf, dass ein Konflikt vorliegt, der zu behben ist
        /// <see cref="#D5C7"/>
        /// </summary>        
        field(51018; "DDN-COR Date Conflict Action"; Option)
        {
            Caption = 'Date Conflict Action';
            DataClassification = ToBeClassified;
            OptionMembers = " ",DateConflictExists,DateConflictSolved,DateConflictPostponed;
            OptionCaption = ' ,Date Conflict exists,Date conflict solved,Date Conflict postponed';
            Editable = true;

            trigger OnValidate()
            var
                myInt: Integer;
            begin
                // Der Anwender soll den Status nicht zurückstellen dürfen.
                // Diese Hoheit obliegt dem System
                if "DDN-COR Date Conflict Action" in ["DDN-COR Date Conflict Action"::" ", "DDN-COR Date Conflict Action"::DateConflictExists] then
                    "DDN-COR Date Conflict Action" := xRec."DDN-COR Date Conflict Action";

            end;
        }
        /// <summary>
        /// <see cref="#DSDS"/>
        /// </summary>
        field(51019; "COR DSDS Priority"; BigInteger)
        {
            DataClassification = ToBeClassified;
            Caption = 'DSDS Priority';
            Editable = false;
            //InitValue = 999999999;
        }
        /// <summary>
        /// Dieses Datum wird genutzt falls es bei Bestellverzögerungen dazu kommt, dass Belege umzuterminieren sind
        /// weil Felix sie bewusst vorzieht
        /// <see cref="#DSDS"/>
        /// </summary>
        field(51020; "COR DSDS Shift-to Date"; Date)
        {
            DataClassification = ToBeClassified;
            Caption = 'DSDS Shift-to Date';
            Editable = false;
        }
        field(51021; "COR-DDN Warehouse Shipment No."; Code[20])
        {
            Caption = 'Warehouse Shipment No.';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup("Warehouse Shipment Line"."No." where("Source Type" = const(37), "Source Subtype" = field("Document Type"), "Source No." = field("Document No."), "Source Line No." = field("Line No.")));
        }
        field(51022; "COR-DDN Your Referenc No."; code[35])
        {
            Caption = 'Your reference';
            FieldClass = FlowField;
            CalcFormula = lookup("Sales Header"."Your Reference" where("Document Type" = field("Document Type"), "No." = field("Document No.")));
            Editable = false;
        }
        field(51023; "COR-DDN Item No."; Code[20])
        {
            Caption = 'Item No. 2';
            FieldClass = FlowField;
            CalcFormula = lookup(Item."No. 2" where("No." = field("No.")));
            Editable = false;
        }
        field(51024; "COR-DDN Legacy System Item No."; Code[20])
        {
            Caption = 'Legacy System Item No.';
            FieldClass = FlowField;
            CalcFormula = lookup(Item."DDM Legacy System Item No." where("No." = field("No.")));
            Editable = false;
        }
    }
    /// <summary>
    /// <see cref="#DSDS"/>
    /// </summary>
    keys
    {
        key("COR DSDS Priority"; "COR DSDS Priority")
        {
            //IncludedFields=
        }
    }

    /// <summary>
    /// Berechnet in der Sales Line das angezeigte Icon basierend auf dem ProcessingHint.
    /// Auf der SalesLine wird kein modify() ausgeführt.
    /// </summary>
    local procedure calcProcessingHintIcon_lFnc()
    var
        DEDONSetup: Record "DDN Setup";
    begin
        case Rec."DDN Processing Hint" of
            rec."DDN Processing Hint"::OnStock, rec."DDN Processing Hint"::OnStockProjected:
                begin
                    Rec."DDN Processing Hint Icon" := DEDONSetup.GetOkIcon();
                end;
            rec."DDN Processing Hint"::StockCritical, rec."DDN Processing Hint"::sameDayConflict, Rec."DDN Processing Hint"::DirectShipmentPoCreated:
                begin
                    Rec."DDN Processing Hint Icon" := DEDONSetup.GetWarningIcon();
                end;
            rec."DDN Processing Hint"::OutOfStock, rec."DDN Processing Hint"::noPurchaseInSight, rec."DDN Processing Hint"::OutOfStockProjected:
                begin
                    Rec."DDN Processing Hint Icon" := DEDONSetup.GetErrorIcon();
                end
            else begin
                clear(Rec."DDN Processing Hint Icon");
            end;
        end;
    end;

    /// <summary>
    /// <see cref="#NFSX"/>
    /// </summary>
    trigger OnInsert()
    var
        dsdsMgmt: Codeunit "COR DSDS Availibility Mgmt.";
    begin
        // #NFSX
        Rec."DDN Order Intake Date" := GetSalesHeader()."DDN Order Intake Date";
        // if Rec.Type = Rec.Type::Item then
        //     dsdsMgmt.QueueUnpriorisedSalesLine(Rec, false);
    end;


    /// <summary>
    /// <see cref="#3N8B"/>
    /// </summary>
    procedure TransferEaliestShipmentDateToShipmentDate_gFnc()
    var
        origErliestShipmentDate_lDate: Date;
        ddnSetup: Record "DDN Setup";
    begin
        // das früheste WA-Datum würde normalerweise erst
        // nach validierung der Menge errechnet wird in folgender CU:
        // "trm Sales Line Event" TF_37_SalesLine_OnAfterValidate_Quantity

        if "DDN lock Shiment Date" then
            exit;
        if "Shipment Date" = "COR-DDN Earliest Shipment Date" then
            exit;
        // Bei Kissen, die per Spezialauftrag beschafft werden, soll sich das WA-Datum nicht ändern
        // https://dedongroup.atlassian.net/browse/DEDT-105
        ddnSetup.get();
        if not ddnSetup."transfer date spec. order" then begin
            if "Special Order" then
                exit;
        end;

        if Rec."COR-DDN earliest Shipment Date" = 0D then begin
            Validate("Shipment Date", 20991231D);
        end
        else begin
            Validate("Shipment Date", "COR-DDN Earliest Shipment Date");
        end;
    end;

    /// <summary>
    /// Ein alternativer Ansatz um das Datum bei Dedon zu kalkulieren weilt Trimit nicht erwartungskonform arbeitet
    /// Dank DSDS fällt dieser Ansatz weg
    /// <see cref="3N8B"/>
    /// </summary>
    ///     ObsoleteState = Pending;
    /// ObsoleteReason = 'Replaced by DEDON DSDS';
    procedure CalculateDedonEarliestShipmentDateObsolete(doUpdateLastCalcDate_pBool: Boolean) earliestShipmentDate: Date;

    var
        myInt: Integer;
        ItemAvailabilityBuffer: Record "Item Availability Buffer" temporary;
        Item_lRec: Record ITem;
        periodEnd: Date;
        ItemAvailFormsMgt: Codeunit "Item Availability Forms Mgt";
        QtyAvailable: Decimal;
        relevantDateList: List of [Date];
        SalesLineForItem_lRec: Record "Sales Line";
        PurchaseLineForItem_lRec: Record "Purchase Line";
        previousDate_lDate: Date;
        ddnSetup: record "DDN Setup";
        BaseDate_LDate: Date;
        Location_lRec: Record Location;
        PurchaseLine_lRec: Record "Purchase Line";
        skipLeadTime_lBool: Boolean;
        jhSalesLine_lRec: Record "Sales Line";
    begin
        if Rec.type <> Rec.Type::Item then
            exit;
        if not Item_lRec.get(Rec."No.") then
            exit;

        previousDate_lDate := Rec."COR-DDN earliest Shipment Date";
        ddnSetup.get();

        // rühstes Lieferdatum leeren bei Spezialauftrag
        // https://dedongroup.atlassian.net/browse/DEDT-105
        if Rec."Special Order" then begin
            // Falls bereits eine EK-Bestellung vorliegt gilt der vorgang als "in Bearbeitung" und
            // es kommt nicht zur Neuberechnung
            if Rec."Special Order Purchase No." = '' then begin
                earliestShipmentDate := WorkDate();
                Rec."DDN Processing Hint" := Rec."DDN Processing Hint"::noPurchaseInSight;
            end
            else begin
                // Falls eine Bestellung ermittelt werden kann dann hole das WE-Datum von dort
                if PurchaseLine_lRec.get(PurchaseLine_lRec."Document Type", "Special Order Purchase No.", "Special Order Purch. Line No.") then begin
                    earliestShipmentDate := PurchaseLine_lRec."Expected Receipt Date";
                    if PurchaseLine_lRec."Qty. Received (Base)" >= Rec."Outstanding Qty. (Base)" then begin
                        Rec."DDN Processing Hint" := Rec."DDN Processing Hint"::DirectShipmentPoCreated;
                    end
                    else begin
                        Rec."DDN Processing Hint" := Rec."DDN Processing Hint"::StockCritical;
                    end;
                    skipLeadTime_lBool := true;
                end
                // Falls keine Bestellung vorliegt nutze das Arbeitsdatum
                else begin
                    //earliestShipmentDate := Rec."trm Order Date";
                    Rec."DDN Processing Hint" := Rec."DDN Processing Hint"::noPurchaseInSight;
                    earliestShipmentDate := WorkDate();
                END

            end;
            Rec."COR-DDN earliest Shipment Date" := earliestShipmentDate;
        end else begin
            // relevante Datumswerte emittlen zu denen sich Änderungen anbahnen
            // heutiges Datum auf jeden fall ergänzen
            ItemAvailabilityBuffer."Item No." := Item_lRec."No.";
            ItemAvailabilityBuffer."Period Type" := ItemAvailabilityBuffer."Period Type"::Day;
            ItemAvailabilityBuffer."Period Start" := WorkDate();
            ItemAvailabilityBuffer.insert;

            if WorkDate() <> Rec."Shipment Date" then begin
                ItemAvailabilityBuffer."Item No." := Item_lRec."No.";
                ItemAvailabilityBuffer."Period Type" := ItemAvailabilityBuffer."Period Type"::Day;
                ItemAvailabilityBuffer."Period Start" := Rec."Shipment Date";
                ItemAvailabilityBuffer.insert;
            end;

            // Blick auf Auftragszeilen
            SalesLineForItem_lRec.SetLoadFields("Shipment Date");
            SalesLineForItem_lRec.SetRange("Document Type", SalesLineForItem_lRec."Document Type"::Order);
            SalesLineForItem_lRec.SetRange(Type, Rec.Type);
            SalesLineForItem_lRec.SetRange("No.", Rec."No.");
            SalesLineForItem_lRec.SetRange("Location Code", Rec."Location Code");
            if not ddnSetup."Availibility Check with past" then
                SalesLineForItem_lRec.setfilter("Shipment Date", '%1..', WorkDate());
            Rec.setfilter("Outstanding Qty. (Base)", '>0');
            if SalesLineForItem_lRec.findset then
                repeat
                    ItemAvailabilityBuffer."Item No." := Item_lRec."No.";
                    ItemAvailabilityBuffer."Period Type" := ItemAvailabilityBuffer."Period Type"::Day;
                    ItemAvailabilityBuffer."Period Start" := SalesLineForItem_lRec."Shipment Date";
                    if ItemAvailabilityBuffer.Insert() then;
                until SalesLineForItem_lRec.next = 0;

            // Blick auf Bestellzeilen
            PurchaseLineForItem_lRec.SetLoadFields("Expected Receipt Date");
            PurchaseLineForItem_lRec.SetRange("Document Type", PurchaseLineForItem_lRec."Document Type"::Order);
            PurchaseLineForItem_lRec.SetRange(Type, PurchaseLineForItem_lRec.Type::Item);
            PurchaseLineForItem_lRec.SetRange("No.", Rec."No.");
            PurchaseLineForItem_lRec.SetRange("Location Code", Rec."Location Code");
            PurchaseLineForItem_lRec.setfilter("Outstanding Qty. (Base)", '>0');
            if not ddnSetup."Availibility Check with past" then
                PurchaseLineForItem_lRec.setfilter(PurchaseLineForItem_lRec."Expected Receipt Date", '%1..', WorkDate());

            if PurchaseLineForItem_lRec.findset then
                repeat
                    ItemAvailabilityBuffer."Item No." := Item_lRec."No.";
                    ItemAvailabilityBuffer."Period Type" := ItemAvailabilityBuffer."Period Type"::Day;
                    ItemAvailabilityBuffer."Period Start" := PurchaseLineForItem_lRec."Expected Receipt Date";
                    if ItemAvailabilityBuffer.Insert() then;
                until PurchaseLineForItem_lRec.next = 0;


            Item_lRec.setrange("Location Filter", Rec."Location Code");

            // hier wird verhindert, dass die Verfügbarkeit vorverlegt werden kann
            ItemAvailabilityBuffer.setfilter("Period Start", '%1..', Rec."Shipment Date");


            if ItemAvailabilityBuffer.findset then
                repeat
                    Item_lRec.SetRange("Date Filter", 0D, ItemAvailabilityBuffer."Period Start");
                    ItemAvailFormsMgt.CalcAvailQuantities(
                      //Item_lRec, true,
                      Item_lRec, false,
                      ItemAvailabilityBuffer."Gross Requirement", ItemAvailabilityBuffer."Planned Order Receipt", ItemAvailabilityBuffer."Scheduled Receipt",
                      ItemAvailabilityBuffer."Planned Order Releases", ItemAvailabilityBuffer."Projected Available Balance", ItemAvailabilityBuffer."Expected Inventory", QtyAvailable, ItemAvailabilityBuffer."Available Inventory");

                    // ggf soll die verfügabre Menge reduziert werden um das, was von Jungheinrich  "reserviert" wurde.
                    if ddnSetup."Reduce by JH assigned Invnet" then begin
                        jhSalesLine_lRec.SetRange(Type, jhSalesLine_lRec.Type::Item);
                        jhSalesLine_lRec.setrange("No.", Rec."No.");
                        jhSalesLine_lRec.setfilter(Quantity, '<>0');
                        jhSalesLine_lRec.SetRange("Location Code", Rec."Location Code");
                        // TODO ReactivateJungheinrichCode reactivate 2 Line below
                        jhSalesLine_lRec.calcsums("Assigned Inventory (Base) JH");
                        QtyAvailable -= jhSalesLine_lRec."Assigned Inventory (Base) JH";
                        QtyAvailable += Rec."Quantity (Base)";
                    end;


                    // Unschärfe: Merhere Verkaufsaufträge zum identischen WA-Datum
                    // Beispiel:
                    // 100 Stück auf LAger
                    // 70 in Auftrag A
                    // 60 in Auftrag B
                    // Einer der Aufträge wäre erfüllbar.
                    // Beide zusammen reduzieren jedoch die verfübare Menge auf 100-70-60 = -30
                    // Folglich wird keiner der beiden Aufträge geliefert


                    clear("DDN Processing Hint");
                    if ItemAvailabilityBuffer."Available Inventory" <= 0 then begin
                        Rec."DDN Processing Hint" := Rec."DDN Processing Hint"::OutOfStock
                    end;
                    // Sonderfall wenn das WA-Datum dem Tagesdatum entspricht
                    if "Shipment Date" = ItemAvailabilityBuffer."Period Start" then begin
                        if QtyAvailable >= 0 then begin
                            earliestShipmentDate := ItemAvailabilityBuffer."Period Start";
                            Rec."DDN Processing Hint" := Rec."DDN Processing Hint"::OnStock;
                        end
                        else begin
                            // hier Teilmenge
                            Rec."DDN Processing Hint" := Rec."DDN Processing Hint"::StockCritical;

                            if QtyAvailable + ItemAvailabilityBuffer."Gross Requirement" - Rec."Outstanding Qty. (Base)" > 0 then begin
                                "DDN Processing Hint" := "DDN Processing Hint"::sameDayConflict;
                                earliestShipmentDate := ItemAvailabilityBuffer."Period Start";
                            end;
                        end
                    end
                    else begin
                        if QtyAvailable >= Rec."Outstanding Qty. (Base)" then begin
                            earliestShipmentDate := ItemAvailabilityBuffer."Period Start";
                            Rec."DDN Processing Hint" := Rec."DDN Processing Hint"::OnStockProjected;
                        end
                        else begin
                            Rec."DDN Processing Hint" := Rec."DDN Processing Hint"::StockCritical;

                            if QtyAvailable + ItemAvailabilityBuffer."Gross Requirement" - Rec."Outstanding Qty. (Base)" > 0 then begin
                                "DDN Processing Hint" := "DDN Processing Hint"::sameDayConflict;
                                earliestShipmentDate := ItemAvailabilityBuffer."Period Start";
                            end;
                        end;
                    end;
                until (ItemAvailabilityBuffer.Next() = 0) or (earliestShipmentDate <> 0D);
        end;

        if (earliestShipmentDate = 0D) and (skipLeadTime_lBool = false) then begin
            // an dieser Stelle sind wir wenn Bedarfsdecker fehlen
            Rec."DDN Processing Hint" := Rec."DDN Processing Hint"::noPurchaseInSight;

            // falls keine Bestellung vorliegt wird stattdessen mit der Wiederbschaffung gearbeitet
            // und ggf. mit einem Fallback-Wert
            if ddnSetup."Leadtime on neg. availiblity" then begin
                // ggf. Artikel-Wiederbeschaffungszeiten nutzen falls eingestellt
                // um tägliches Flattern zu verhindern wird der folgende montag zum Arbeitsdatum herangezogen

                if FORMAT(item_lRec."Lead Time Calculation") <> '' then begin
                    earliestShipmentDate := calcdate(item_lRec."Lead Time Calculation", WorkDate())
                end
                else begin
                    ddnSetup.TestField("Worst case replen. DateForm.");
                    earliestShipmentDate := calcdate(ddnSetup."Worst case replen. DateForm.", WorkDate())
                end;

                Location_lRec.get(Rec."Location Code");
                if FORMAT(Location_lRec."Inbound Whse. Handling Time") <> '' then
                    earliestShipmentDate := calcdate(Location_lRec."Inbound Whse. Handling Time", earliestShipmentDate);

                if format(ddnSetup."Worst case replen. rounding") <> '' then
                    earliestShipmentDate := calcdate(ddnSetup."Worst case replen. rounding", earliestShipmentDate);
            end;
        end;


        if previousDate_lDate <> earliestShipmentDate then begin
            Rec."COR-DDN earliest Shipment Date" := earliestShipmentDate;
            Rec."COR-DDN Availib. Modified Date" := WorkDate();
            case Rec."DDN Processing Hint" of
                rec."DDN Processing Hint"::OnStock, rec."DDN Processing Hint"::OnStockProjected:
                    begin
                        Rec."DDN-COR Date Conflict Action" := Rec."DDN-COR Date Conflict Action"::" ";
                    end;
                rec."DDN Processing Hint"::StockCritical, rec."DDN Processing Hint"::sameDayConflict:
                    begin
                        Rec."DDN-COR Date Conflict Action" := Rec."DDN-COR Date Conflict Action"::DateConflictExists;
                    end;
                rec."DDN Processing Hint"::OutOfStock, rec."DDN Processing Hint"::noPurchaseInSight:
                    begin
                        Rec."DDN-COR Date Conflict Action" := Rec."DDN-COR Date Conflict Action"::DateConflictExists;
                    end
                else begin
                    clear(Rec."DDN Processing Hint Icon");
                end;
            end;
        end;
        Validate(Rec."DDN Processing Hint");
    end;

    procedure VanishLineDiscounts()
    var
        salesLineDiscCombin_loc: record "trm Sales Line Disc Comb Order";
    begin
        salesLineDiscCombin_loc.SetRange("Sales Document Type", Rec."Document Type");
        salesLineDiscCombin_loc.SetRange("Sales Document No.", Rec."Document No.");
        salesLineDiscCombin_loc.SetRange("Sales Document Entry No.", Rec."Line No.");
        if not salesLineDiscCombin_loc.IsEmpty then begin
            salesLineDiscCombin_loc.DeleteAll;
            if rec."Line Discount %" <> 0 then begin
                Rec.validate("Line Discount %", 0);
                Rec.modify(false);
            end;
        end;

    end;
}