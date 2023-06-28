/// <summary>
/// Idee:
/// relevante VK-Zeilen werden in die temporäre Tabelle PriorityQueueSalesLine_lRec kopiert
/// Auf dieser Tabelle erfolgt die Berechnung von Prioritäten
/// Diese Codeunit arbeitet ähnlich dem Prinzip eines Obejkts im Sinne der OOP. Mittels Settern wird die Umgebunbg definiert
/// Das Objekt muss solange existieren wie darauf gearbeitet wird.
/// </summary>
codeunit 51019 "COR DSDS Availibility Mgmt."
{
    procedure createSchedule()
    begin
        createSchedule(ddnSetup."DSDS Initial Priority Model");
    end;

    /// <summary>
    /// Diese Funktion ist die zentrale Anlaufstelle um den Schedule aufzubauen
    /// DoRecalcPriority ist zetral:
    /// - bei skip werden die Werte unverändert aus der Auftragszeile gezogen
    /// - byOrderDate und byShipmentDate führt zu einer Neuberechnung. Manuelle Priorisierungen bleiben unberücksichtig da
    ///   diese auf der SalesLine stehen und der temporäre PrioritätenStapel neu errechnet wird.
    /// </summary>
    /// <param name="ItemNo_iCod"></param>
    /// <param name="LocationCode_iCod"></param>
    procedure createSchedule(DoRecalcPriorityOnModel: enum "COR DSDS Priority Model")
    var
        LastEntryNo_lInt, stockEntryNo_lInt : Integer;
        aggregatedBalance_lDec: Decimal;
        Priority_lBigInt: BigInteger;
    begin
        testContext();
        activePriorityModel := DoRecalcPriorityOnModel;
        CleanSchedule();
        // schreibt relevante Auftragszeilen in den Prioritätestapel
        CreatePriorityQueue();

        // berechnet die Prioritäten oder übernimmt vorhandene Prioritäten aus den Verkaufszeilen
        case DoRecalcPriorityOnModel of
            DoRecalcPriorityOnModel::CalculatedByOrderDate:
                Priority_lBigInt := CalculateInitialPriorityByOrderDateOrDocumentNo(0);
            DoRecalcPriorityOnModel::CalculatedByOrderNo:
                Priority_lBigInt := CalculateInitialPriorityByOrderDateOrDocumentNo(1);
            DoRecalcPriorityOnModel::CalculatedByShipmentDate:
                Priority_lBigInt := CalculateInitialPriorityByShipmentDate();
            DoRecalcPriorityOnModel::CalculatedByShipmentDateRegardingShifts:
                Priority_lBigInt := CalculateInitialPriorityByShipmentDateRegardingShifts();
            else begin
                // Prio gem. Auftragszeile. Im Zuge der Datenübernahme sind
                // Werte hier im dümmsten Fall leer;
                PriorityQueueSalesLine_gRec.Reset();
                PriorityQueueSalesLine_gRec.SetRange("Document Type", PriorityQueueSalesLine_gRec."Document Type"::Order);
                if PriorityQueueSalesLine_gRec.findlast then begin
                    if PriorityQueueSalesLine_gRec."COR DSDS Priority" > 0 then begin
                        Priority_lBigInt := PriorityQueueSalesLine_gRec."COR DSDS Priority";
                    end else begin
                        Priority_lBigInt := 99999999 - PriorityIncrement();
                    end;
                end;
                PriorityQueueSalesLine_gRec.reset;
            end;
        end;

        // Angebote werden immer ganz hinten angehängt
        shiftSalesQuotesPriorityToEnd();

        stockEntryNo_lInt := 2000000;

        if ddnSetup."Reduce by JH assigned Invnet" then begin
            addJungheinrichDemandToSchedule(1000000, aggregatedBalance_lDec);
            // Die Aggregierte Menge muss auf 0 gesetzt werden weil sonst Zuordnungen die Jungheinricht-Mengen berücksichtigen
            clear(aggregatedBalance_lDec);
        end;
        addStockToSchedule(stockEntryNo_lInt, aggregatedBalance_lDec);

        // Bestellungen in Millionenschritten um genug Platz zwischen Zeilen zu haben damit sich VK-Aufträge einordnen lassen
        LastEntryNo_lInt := addPuchaseOrdersToSchedule(3000000, aggregatedBalance_lDec);
        addBacklogToSchedule(LastEntryNo_lInt);
        addSalesOrderToSchedule();
        deleteBacklogFromSchedule();
        updateBalance();
        updateFocus();
        detectDateConflicts();
        scheduleLine_gRec.Reset();
    end;

    /// <summary>
    /// Erzeugt für jede eingehende Bestellzeile eine Zeile
    /// </summary>
    local procedure addPuchaseOrdersToSchedule(EntryNo_lInt: Integer; var aggregatedBalance_vDec: Decimal) LastEntryNo_lInt: Integer;
    var
        purchaseLine_lRec: Record "Purchase Line";
        purchaseHeader_lRec: Record "Purchase Header";
    begin
        purchaseLine_lRec.SetRange("Document Type", purchaseLine_lRec."Document Type"::Order);
        purchaseLine_lRec.setrange("No.", ItemNo_gCod);
        purchaseLine_lRec.setrange("Location Code", LocationCode_gCod);
        purchaseLine_lRec.setfilter("Outstanding Qty. (Base)", '>0');

        if WorkWithFocusOnSalesLine() then begin
            if focusSalesLine_gRec."Special Order" then begin
                purchaseLine_lRec.SetRange("Special Order Sales No.", focusSalesLine_gRec."Document No.");
                purchaseLine_lRec.SetRange("Special Order Sales Line No.", focusSalesLine_gRec."Line No.");
            end
            else begin
                purchaseLine_lRec.SetRange("Special Order", false);
            end;
        end
        else begin
            // im Stapellauf oder beim Aufruf über den artikel wird nicht mit Fokus auf der Auftragszeile gearbeitet
            purchaseLine_lRec.SetRange("Special Order", false);
        end;
        // wird benötigt falls es keine Bestellung gibt
        LastEntryNo_lInt := EntryNo_lInt;

        purchaseLine_lRec.SetCurrentKey("Expected Receipt Date");
        if purchaseLine_lRec.FindSet() then begin
            purchaseHeader_lRec.SetLoadFields("Buy-from Vendor Name");
            repeat
                aggregatedBalance_vDec += purchaseLine_lRec."Outstanding Qty. (Base)";

                EntryNo_lInt += 1000000;
                scheduleLine_gRec.Init();
                scheduleLine_gRec."Entry No." := EntryNo_lInt;
                scheduleLine_gRec."Source Type" := scheduleLine_gRec."Source Type"::"Purchase Order";
                scheduleLine_gRec."Source No." := purchaseLine_lRec."Document No.";
                scheduleLine_gRec."Source Line No." := purchaseLine_lRec."Line No.";
                scheduleLine_gRec."Item No." := ItemNo_gCod;
                scheduleLine_gRec."Location Code" := LocationCode_gCod;
                scheduleLine_gRec."Outstanding Quantity (Base)" := purchaseLine_lRec."Outstanding Qty. (Base)";
                scheduleLine_gRec."Receipt/Shipment Date" := purchaseLine_lRec."Expected Receipt Date";
                scheduleLine_gRec."aggregated balance" := aggregatedBalance_vDec;
                scheduleLine_gRec."Unassigned Qty. (Base) Entry" := scheduleLine_gRec."Outstanding Quantity (Base)";
                //scheduleLine_gRec."unassigned Quantity (Base)" := scheduleLine_gRec."aggregated balance";
                scheduleLine_gRec."unassigned Quantity (Base)" := purchaseLine_lRec."Outstanding Qty. (Base)";
                scheduleLine_gRec.direction := scheduleLine_gRec.direction::positive;
                scheduleLine_gRec.Indentation := 0;
                purchaseHeader_lRec.get(purchaseLine_lRec."Document Type", purchaseLine_lRec."Document No.");
                scheduleLine_gRec."Customer / Vendor Name" := purchaseHeader_lRec."Buy-from Vendor Name";
                scheduleLine_gRec.insert(true);
            until purchaseLine_lRec.Next() = 0;
            LastEntryNo_lInt := EntryNo_lInt;
        end;
    end;

    local procedure addStockToSchedule(EntryNo_lInt: Integer; var aggregatedBalance_vDec: Decimal)
    var
        item_lRec: Record Item;
        JungheinrichtQty_iDec: Decimal;
        ItemLedgerEntry_lRec: Record "Item Ledger Entry";
    begin
        if WorkWithFocusOnSalesLine() then begin
            // Beim Spezialauftrag wird der Lagerbestand über die zugeordnete EK-Bestellung ermittelt
            if focusSalesLine_gRec."Special Order" then begin
                scheduleLine_gRec.Reset();
                scheduleLine_gRec.Init();
                scheduleLine_gRec."Entry No." := EntryNo_lInt;
                scheduleLine_gRec."Source Type" := scheduleLine_gRec."Source Type"::Stock;
                scheduleLine_gRec."Source No." := '';
                scheduleLine_gRec."Source Line No." := 0;
                scheduleLine_gRec."Item No." := ItemNo_gCod;
                scheduleLine_gRec."Location Code" := LocationCode_gCod;
                scheduleLine_gRec."Receipt/Shipment Date" := WorkDate();
                scheduleLine_gRec.direction := scheduleLine_gRec.direction::positive;
                scheduleLine_gRec.Indentation := 0;


                if focusSalesLine_gRec."Special Order Purchase No." <> '' then begin
                    ItemLedgerEntry_lRec.SetRange("Item No.", focusSalesLine_gRec."No.");
                    // Der Posten kennt die Zeile der BEstellung nicht
                    // Wir akzeptierne die Lücke
                    ItemLedgerEntry_lRec.SetRange("Order No.", focusSalesLine_gRec."Special Order Purchase No.");
                    ItemLedgerEntry_lRec.setrange(Open, true);
                    ItemLedgerEntry_lRec.CalcSums("Remaining Quantity");

                    scheduleLine_gRec."Outstanding Quantity (Base)" := ItemLedgerEntry_lRec."Remaining Quantity";
                end else begin
                    scheduleLine_gRec."Outstanding Quantity (Base)" := 0;
                end;

                scheduleLine_gRec."aggregated balance" := scheduleLine_gRec."Outstanding Quantity (Base)";
                scheduleLine_gRec."Unassigned Qty. (Base) Entry" := scheduleLine_gRec."Outstanding Quantity (Base)";
                scheduleLine_gRec."unassigned Quantity (Base)" := scheduleLine_gRec."aggregated balance";
                scheduleLine_gRec.insert(true);
                exit;
            end;
        end;
        item_lRec.get(ItemNo_gCod);
        item_lRec.setrange("Location Filter", LocationCode_gCod);
        item_lRec.CalcFields(Inventory);

        // prüfe, ob ggf. Jungheinrich-Mengen abzuziehen sind
        if ddnSetup."Reduce by JH assigned Invnet" then begin
            scheduleLine_gRec.Reset();
            scheduleLine_gRec.SetRange("Source Type", scheduleLine_gRec."Source Type"::Jungheinrich);
            if scheduleLine_gRec.FindFirst() then
                JungheinrichtQty_iDec := scheduleLine_gRec."Outstanding Quantity (Base)";
        end;

        aggregatedBalance_vDec += item_lRec.Inventory - JungheinrichtQty_iDec;


        scheduleLine_gRec.Reset();
        scheduleLine_gRec.Init();
        scheduleLine_gRec."Entry No." := EntryNo_lInt;
        scheduleLine_gRec."Source Type" := scheduleLine_gRec."Source Type"::Stock;
        scheduleLine_gRec."Source No." := '';
        scheduleLine_gRec."Source Line No." := 0;
        scheduleLine_gRec."Item No." := ItemNo_gCod;
        scheduleLine_gRec."Location Code" := LocationCode_gCod;
        scheduleLine_gRec."Outstanding Quantity (Base)" := item_lRec.Inventory - JungheinrichtQty_iDec;
        scheduleLine_gRec."Receipt/Shipment Date" := WorkDate();
        scheduleLine_gRec."aggregated balance" := aggregatedBalance_vDec;
        scheduleLine_gRec."Unassigned Qty. (Base) Entry" := scheduleLine_gRec."Outstanding Quantity (Base)";
        scheduleLine_gRec."unassigned Quantity (Base)" := aggregatedBalance_vDec;
        scheduleLine_gRec.direction := scheduleLine_gRec.direction::positive;
        scheduleLine_gRec.Indentation := 0;
        scheduleLine_gRec.insert(true);
    end;

    local procedure addJungheinrichDemandToSchedule(EntryNo_lInt: Integer; var aggregatedBalance_vDec: Decimal)
    var
        JungheinrichtQuantity_lDec: Decimal;
    begin
        if WorkWithFocusOnSalesLine() then begin
            // Beim Spezialauftrag ignorieren wir Jungheinrich :)
            if focusSalesLine_gRec."Special Order" then begin
                // auf Jungheinrich filtern anstelle zu ignorieren
                // exit;
                PriorityQueueSalesLine_gRec.SetRange("Document Type", focusSalesLine_gRec."Document Type");
                PriorityQueueSalesLine_gRec.SetRange("Document No.", focusSalesLine_gRec."Document No.");
                PriorityQueueSalesLine_gRec.SetRange("Line No.", focusSalesLine_gRec."Line No.");

            end;
        end;
        PriorityQueueSalesLine_gRec.Reset();
        // TODO ReactivateJungheinrichCode 1 Line
        PriorityQueueSalesLine_gRec.SetFilter("Assigned Inventory (Base) JH", '>0');

        if not PriorityQueueSalesLine_gRec.IsEmpty then begin
            // TODO ReactivateJungheinrichCode 2 Lines
            PriorityQueueSalesLine_gRec.CalcSums("Assigned Inventory (Base) JH");
            JungheinrichtQuantity_lDec := PriorityQueueSalesLine_gRec."Assigned Inventory (Base) JH";
            aggregatedBalance_vDec += JungheinrichtQuantity_lDec;

            scheduleLine_gRec.Init();
            scheduleLine_gRec."Entry No." := EntryNo_lInt;
            scheduleLine_gRec."Source Type" := scheduleLine_gRec."Source Type"::Jungheinrich;
            scheduleLine_gRec."Source No." := '';
            scheduleLine_gRec."Source Line No." := 0;
            scheduleLine_gRec."Item No." := ItemNo_gCod;
            scheduleLine_gRec."Location Code" := LocationCode_gCod;
            scheduleLine_gRec."Outstanding Quantity (Base)" := JungheinrichtQuantity_lDec;
            scheduleLine_gRec."Receipt/Shipment Date" := WorkDate();
            // per Definiton ist die Menge immer vollständig zugewiesen
            scheduleLine_gRec."unassigned Quantity (Base)" := 0;
            scheduleLine_gRec."Unassigned Qty. (Base) Entry" := 0;
            scheduleLine_gRec.direction := scheduleLine_gRec.direction::neutral;
            scheduleLine_gRec.Indentation := 0;
            scheduleLine_gRec."aggregated balance" := aggregatedBalance_vDec;
            scheduleLine_gRec.insert(true);
        end;
        PriorityQueueSalesLine_gRec.Reset();
    end;

    local procedure addBacklogToSchedule(EntryNo_iInt: Integer) LastEntryNo_lInt: Integer
    var
        item_lRec: Record Item;
    begin
        item_lRec.get(ItemNo_gCod);
        item_lRec.setrange("Location Filter", LocationCode_gCod);
        item_lRec.CalcFields(Inventory);

        scheduleLine_gRec.Init();
        scheduleLine_gRec."Entry No." := EntryNo_iInt + 1000000;
        scheduleLine_gRec."Source Type" := scheduleLine_gRec."Source Type"::Backlog;
        scheduleLine_gRec."Source No." := '';
        scheduleLine_gRec."Source Line No." := 0;
        scheduleLine_gRec."Item No." := ItemNo_gCod;
        scheduleLine_gRec."Location Code" := LocationCode_gCod;
        scheduleLine_gRec."Outstanding Quantity (Base)" := 0;
        scheduleLine_gRec."Receipt/Shipment Date" := FindBacklogShipmentDate(ItemNo_gCod, LocationCode_gCod);
        scheduleLine_gRec.direction := scheduleLine_gRec.direction::neutral;
        scheduleLine_gRec.insert(true);

        LastEntryNo_lInt := scheduleLine_gRec."Entry No."
    end;

    local procedure CleanSchedule()
    var

    begin
        scheduleLine_gRec.DeleteAll();
    end;

    /// <summary>
    /// Hier ist ein Großteil der Intelligenz. Die Einordnung der VK-Aufträge gem. ihrer Prioritäten
    /// </summary>
    local procedure addSalesOrderToSchedule()
    var
        matchFound_lBool: Boolean;
        PurchaseOrderOrStockOrBacklogEntryNo_lInt: Integer;
        EntryNo_lInt: Integer;
        outstandingQty_lDec: Decimal;
        splittingQty_lDec: Decimal;
        earliestShipmentDate: date;
        assignToBacklock_lBool: Boolean;
        SalesHeader_lRec: Record "Sales Header";
        nearestEntryNo: Integer;
    begin
        // wichtig: Dia Abarbeitung erfolgt nach Priorität top down
        PriorityQueueSalesLine_gRec.SetCurrentKey("COR DSDS Priority");

        SalesHeader_lRec.SetLoadFields("Sell-to Customer Name");
        if PriorityQueueSalesLine_gRec.FindSet() then begin
            repeat
                Clear(nearestEntryNo);
                clear(earliestShipmentDate);
                if ddnSetup."Reduce by JH assigned Invnet" then begin
                    // TODO ReactivateJungheinrichCode 1 Line
                    outstandingQty_lDec := PriorityQueueSalesLine_gRec."Outstanding Qty. (Base)" - PriorityQueueSalesLine_gRec."Assigned Inventory (Base) JH";
                end
                else begin
                    outstandingQty_lDec := PriorityQueueSalesLine_gRec."Outstanding Qty. (Base)";
                end;

                // Zuordnung zu Stock oder Bestellung
                if outstandingQty_lDec <> 0 then begin
                    // suche die passende Position TopDown in der ScheduleLine
                    scheduleLine_gRec.Reset();
                    scheduleLine_gRec.setrange("direction", scheduleLine_gRec.direction::positive);
                    // falls keine Jungheinrich-Reservierung vorliegt dann darf keinesfalls eine Zuordnung zu Jungheinrich
                    // stattfinden. Das ist insbesondere bei neuen Aufträgen ohne Prio der Fall
                    if ddnSetup."Reduce by JH assigned Invnet" then begin
                        // TODO ReactivateJungheinrichCode 3 Lines
                        if PriorityQueueSalesLine_gRec."Assigned Inventory (Base) JH" <= 0 then begin
                           scheduleLine_gRec.setfilter("Source Type", '<>%1', scheduleLine_gRec."Source Type"::Jungheinrich);
                        end;
                    end;
                    if splitEnabled_gBool then begin
                        //scheduleLine_gRec.setrange("direction");
                        //scheduleLine_gRec.setfilter("Source Type", '%1|%2|%3', scheduleLine_gRec."Source Type"::Backlog, scheduleLine_gRec."Source Type"::Stock, scheduleLine_gRec."Source Type"::"Purchase Order");

                        splittingQty_lDec := outstandingQty_lDec;
                        // Zeile für Zeile die unassigned Quantity verringern
                        // Jungheinricht fäält weg weil bereits eine Mengenzuordnung erfolgte
                        scheduleLine_gRec.setfilter("unassigned Quantity (Base)", '>0');
                        // if PriorityQueueSalesLine_gRec."Document No." = '100-OC-2023-00706' then
                        //     if not confirm('ScheduleLines Count=%1', true, scheduleLine_gRec.Count) then
                        //         error('');

                        if scheduleLine_gRec.FindSet() then begin
                            repeat
                                // Bsp: offene Menge 50, zuzweisende Menge 70
                                if scheduleLine_gRec."unassigned Quantity (Base)" < splittingQty_lDec then begin
                                    splittingQty_lDec -= scheduleLine_gRec."unassigned Quantity (Base)";
                                    scheduleLine_gRec."unassigned Quantity (Base)" := 0;
                                end else begin
                                    // Bsp: offene Menge 60, zuzweisende Menge 40
                                    scheduleLine_gRec."unassigned Quantity (Base)" -= splittingQty_lDec;
                                    splittingQty_lDec := 0;
                                    nearestEntryNo := scheduleLine_gRec."Entry No.";
                                end;
                                scheduleLine_gRec.Modify();
                            until (splittingQty_lDec <= 0) or (scheduleLine_gRec.Next() = 0);
                            // Filter setzen  damit danach der FindFirst funktioniert
                            if nearestEntryNo > 0 then
                                scheduleLine_gRec.SetRange("Entry No.", nearestEntryNo)
                            else
                                scheduleLine_gRec.SetRange("Entry No.", scheduleLine_gRec."Entry No.");
                        end;
                        scheduleLine_gRec.SetRange("Unassigned Quantity (Base)");
                    end else begin
                        scheduleLine_gRec.setfilter("unassigned Quantity (Base)", '>=%1', outstandingQty_lDec);
                    end;

                    //if scheduleLine_gRec.FindFirst() then begin
                    //if scheduleLine_gRec.FindFirst() then begin
                    if splitEnabled_gBool then begin
                        if splittingQty_lDec > 0 then begin
                            assignToBacklock_lBool := true;
                        end
                    end else begin
                        if not scheduleLine_gRec.FindFirst() then
                            assignToBacklock_lBool := true;
                    end;
                    // Eine Bestelzeile oder Artikelbestand wurden gefunden
                    if not assignToBacklock_lBool then begin
                        scheduleLine_gRec.FindFirst();
                        PurchaseOrderOrStockOrBacklogEntryNo_lInt := scheduleLine_gRec."Entry No.";
                        earliestShipmentDate := scheduleLine_gRec."Receipt/Shipment Date";
                        // nicht zugewiesene Menge verringern. Nur dann falls noch nicht durch Splttig geschehen
                        if not splitEnabled_gBool then begin
                            scheduleLine_gRec."Unassigned Quantity (Base)" -= PriorityQueueSalesLine_gRec."Outstanding Qty. (Base)";
                            scheduleLine_gRec.Modify();
                        end;
                        // - BufferedSalesLine_lRec."Assigned Inventory JH"

                        // prüfen der nachfolfenden Auftrags-Zeilen, die der Bestellung zugeordnet sind
                        scheduleLine_gRec.Reset();
                        scheduleLine_gRec.setfilter("Source Type", '%1|%2', scheduleLine_gRec."Source Type"::"Sales Order", scheduleLine_gRec."Source Type"::"Sales Quote");
                        //scheduleLine_gRec.setrange("unassigned Quantity (Base)");
                        scheduleLine_gRec.setrange("assigned to Entry No.", scheduleLine_gRec."Entry No.");

                        // dient nur dazu um die EntryNumber zu erhöhen
                        if scheduleLine_gRec.FindLast() then;

                        EntryNo_lInt := scheduleLine_gRec."Entry No." + 10000;
                    end
                    else begin
                        // hier gäbe es keinen einzigen Bedearfdecker
                        // also einen Eintrag am Ende erzeugen
                        scheduleLine_gRec.Reset();
                        scheduleLine_gRec.setrange("Source Type", scheduleLine_gRec."Source Type"::Backlog);
                        // Beim Backlog ist das WA-Datum enstsprechend der Wiederbeschaffungszeit belegt

                        if scheduleLine_gRec.FindLast() then begin
                            PurchaseOrderOrStockOrBacklogEntryNo_lInt := scheduleLine_gRec."Entry No.";
                            earliestShipmentDate := scheduleLine_gRec."Receipt/Shipment Date";
                            scheduleLine_gRec."calculated via Replenishment" := true;
                        end;

                        scheduleLine_gRec.Reset();
                        scheduleLine_gRec.FindLast();
                        EntryNo_lInt := scheduleLine_gRec."Entry No." + 10000;
                    end;


                    if earliestShipmentDate = 0D then begin
                        scheduleLine_gRec."calculated via Replenishment" := true;
                        earliestShipmentDate := FindBacklogShipmentDate(scheduleLine_gRec."Item No.", LocationCode_gCod);
                    end;
                    scheduleLine_gRec.Reset();
                    scheduleLine_gRec.Init();

                    // Eintrag für Bedarfsanforderer schreiben

                    // TODO Prüfen ob bei Spezialauftrag etwas anderes passieren soll
                    scheduleLine_gRec."Entry No." := EntryNo_lInt;
                    if PriorityQueueSalesLine_gRec."Document Type" = PriorityQueueSalesLine_gRec."Document Type"::Order then
                        scheduleLine_gRec."Source Type" := scheduleLine_gRec."Source Type"::"Sales Order"
                    else
                        if PriorityQueueSalesLine_gRec."Document Type" = PriorityQueueSalesLine_gRec."Document Type"::Quote then begin
                            scheduleLine_gRec."Source Type" := scheduleLine_gRec."Source Type"::"Sales Quote";
                        end;
                    scheduleLine_gRec."Source No." := PriorityQueueSalesLine_gRec."Document No.";
                    scheduleLine_gRec."Source Line No." := PriorityQueueSalesLine_gRec."Line No.";
                    scheduleLine_gRec."Item No." := ItemNo_gCod;
                    scheduleLine_gRec."Location Code" := LocationCode_gCod;
                    scheduleLine_gRec."Outstanding Quantity (Base)" := -outstandingQty_lDec;
                    scheduleLine_gRec."Receipt/Shipment Date" := PriorityQueueSalesLine_gRec."Shipment Date";
                    scheduleLine_gRec."Outgoing Priority" := PriorityQueueSalesLine_gRec."COR DSDS Priority";
                    scheduleLine_gRec."assigned to Entry No." := PurchaseOrderOrStockOrBacklogEntryNo_lInt;
                    scheduleLine_gRec.direction := scheduleLine_gRec.direction::negative;
                    scheduleLine_gRec.Indentation := 1;
                    scheduleLine_gRec."earliest shipment date" := earliestShipmentDate;
                    scheduleLine_gRec."Shift-to Date" := PriorityQueueSalesLine_gRec."COR DSDS Shift-to Date";
                    PriorityQueueSalesLine_gRec.CalcFields("Sell-to Customer Name");
                    scheduleLine_gRec."Customer / Vendor Name" := PriorityQueueSalesLine_gRec."Sell-to Customer Name";
                    scheduleLine_gRec.insert(true);
                end;

                // TODO ReactivateJungheinrichCode second line, deacitvate first Line
                //if false then begin
                    if (PriorityQueueSalesLine_gRec."Assigned Inventory (Base) JH" > 0) and (PriorityQueueSalesLine_gRec."Document Type" = PriorityQueueSalesLine_gRec."Document Type"::Order) then begin

                    scheduleLine_gRec.Reset();
                    scheduleLine_gRec.setrange("Source Type", scheduleLine_gRec."Source Type"::Jungheinrich);
                    if scheduleLine_gRec.FindFirst() then begin
                        PurchaseOrderOrStockOrBacklogEntryNo_lInt := scheduleLine_gRec."Entry No.";

                        // prüfen der nachfolfenden Auftrags-Zeilen, die der JH-Schnittstelle zugeordnet sind
                        scheduleLine_gRec.Reset();
                        scheduleLine_gRec.setrange("Source Type", scheduleLine_gRec."Source Type"::"Sales Order");
                        scheduleLine_gRec.setrange("assigned to Entry No.", scheduleLine_gRec."Entry No.");

                        // dient nur dazu um die EntryNumber zu erhöhen
                        if scheduleLine_gRec.FindLast() then begin
                            EntryNo_lInt := scheduleLine_gRec."Entry No." + 10;
                        end
                        // alternativ die Zeile mit Jungheinrich nehmen und die nächtste Zeile
                        else begin
                            EntryNo_lInt := PurchaseOrderOrStockOrBacklogEntryNo_lInt + 10;
                        end;

                        scheduleLine_gRec.Reset();
                        scheduleLine_gRec.Init();
                        scheduleLine_gRec."Entry No." := EntryNo_lInt;
                        scheduleLine_gRec."Source Type" := scheduleLine_gRec."Source Type"::"Sales Order";
                        scheduleLine_gRec."Source No." := PriorityQueueSalesLine_gRec."Document No.";
                        PriorityQueueSalesLine_gRec.CalcFields("Sell-to Customer Name");
                        scheduleLine_gRec."Customer / Vendor Name" := PriorityQueueSalesLine_gRec."Sell-to Customer Name";
                        scheduleLine_gRec."Source Line No." := PriorityQueueSalesLine_gRec."Line No.";
                        scheduleLine_gRec."Item No." := ItemNo_gCod;
                        scheduleLine_gRec."Location Code" := LocationCode_gCod;
                        // TODO ReactivateJungheinrichCode 1 Line
                        scheduleLine_gRec."Outstanding Quantity (Base)" := -PriorityQueueSalesLine_gRec."Assigned Inventory (Base) JH";
                        scheduleLine_gRec."Receipt/Shipment Date" := PriorityQueueSalesLine_gRec."Shipment Date";
                        scheduleLine_gRec."Outgoing Priority" := PriorityQueueSalesLine_gRec."COR DSDS Priority";
                        scheduleLine_gRec."assigned to Entry No." := PurchaseOrderOrStockOrBacklogEntryNo_lInt;
                        scheduleLine_gRec.direction := scheduleLine_gRec.direction::negative;
                        scheduleLine_gRec.Indentation := 2;
                        // Bei Jungheinrich nehmen wir bewusst das WA-Datum als geplantes Datum
                        // bei neu angelegten Zeilen wird das Shipment-Date zuvor künstlich erhöht.
                        // Daher auf anderes Feld ausweichen (suche nach "HACK001" um die Stelle zu finden)
                        if scheduleLine_gRec."Outgoing Priority" = 99999998 then begin
                            scheduleLine_gRec."earliest shipment date" := PriorityQueueSalesLine_gRec."trm Earliest Shipment Date";
                        end
                        else begin
                            scheduleLine_gRec."earliest shipment date" := PriorityQueueSalesLine_gRec."Shipment Date";
                        end;
                        scheduleLine_gRec.insert(true);
                    end
                end
                else begin

                end;
            until PriorityQueueSalesLine_gRec.Next() = 0;
        end;
    end;

    /// <summary>
    /// Ermittelt ein Datum basierend auf den Wiederbeschaffungszeiten eines Artikels
    /// </summary>
    /// <returns></returns>


    /// <summary>
    /// Ermittelt die Priortität initial basiered auf Belegdatum und Belegnummer
    /// Dabei wird die Priorität nicht auf den Auftragszeilen fixiert sondern stattdessen auf den temporären Datensätzen
    /// </summary>
    procedure CalculateInitialPriorityByOrderDateOrDocumentNo(sortByWhat: Option OrderDate,DocumentNo) Priority_lBigInt: BigInteger;
    var
        SalesHeader_lRec: Record "Sales Header";

    begin
        // da wir initialisieren werden keine, in der Vergangenheit gesetzten Prioritäten berücksichtigt
        PriorityQueueSalesLine_gRec.Reset();
        PriorityQueueSalesLine_gRec.ModifyAll("COR DSDS Priority", 0);

        PriorityQueueSalesLine_gRec.SetLoadFields("Document type", "Document No.", "COR DSDS Priority");
        if PriorityQueueSalesLine_gRec.FindSet() then begin
            SalesHeader_lRec.SetLoadFields("Document Date");
            repeat
                SalesHeader_lRec.get(PriorityQueueSalesLine_gRec."Document Type", PriorityQueueSalesLine_gRec."Document No.");
                SalesHeader_lRec.mark(true);
            until PriorityQueueSalesLine_gRec.Next() = 0;
        end;

        SalesHeader_lRec.MarkedOnly(true);
        if sortByWhat = sortByWhat::OrderDate then
            SalesHeader_lRec.SetCurrentKey("Document Date")
        else
            SalesHeader_lRec.SetCurrentKey("No.");

        Priority_lBigInt := PriorityIncrement();
        if SalesHeader_lRec.findset then
            repeat
                PriorityQueueSalesLine_gRec.setrange("Document No.", SalesHeader_lRec."No.");
                if PriorityQueueSalesLine_gRec.findset then
                    repeat
                        //if PriorityQueueSalesLine_gRec."COR DSDS Priority" <> Priority_lBigInt then begin
                        PriorityQueueSalesLine_gRec."COR DSDS Priority" := Priority_lBigInt;
                        PriorityQueueSalesLine_gRec.Modify();
                        //end;
                        Priority_lBigInt += PriorityIncrement();
                    until PriorityQueueSalesLine_gRec.Next() = 0;
            until SalesHeader_lRec.next = 0;
        PriorityQueueSalesLine_gRec.reset();
    end;

    /// <summary>
    /// Ermittelt die Reihenfolge basierend auf dem Timestamp
    /// </summary>
    procedure CalculateInitialPriorityBySystemCreationDate()
    var
        SalesHeader_lRec: Record "Sales Header";
        Priority_lBigInt: BigInteger;
    begin
        // da wir initialisieren werden keine, in der Vergangenheit gesetzten Prioritäten berücksichtigt
        PriorityQueueSalesLine_gRec.Reset();
        PriorityQueueSalesLine_gRec.ModifyAll("COR DSDS Priority", 0);

        // PriorityQueueSalesLine_gRec.SetRange("Document Type", PriorityQueueSalesLine_gRec."Document Type"::Order);
        // PriorityQueueSalesLine_gRec.setrange(type, PriorityQueueSalesLine_gRec.Type::Item);
        // PriorityQueueSalesLine_gRec.setrange("No.", ItemNo_iCod);
        // PriorityQueueSalesLine_gRec.setrange("Location Code", LocationCode_iCod);
        // PriorityQueueSalesLine_gRec.setfilter("Outstanding Qty. (Base)", '>0');
        PriorityQueueSalesLine_gRec.SetLoadFields("Document type", "Document No.", "COR DSDS Priority");
        if PriorityQueueSalesLine_gRec.FindSet() then begin
            SalesHeader_lRec.SetLoadFields("Document Date");
            repeat
                SalesHeader_lRec.get(PriorityQueueSalesLine_gRec."Document Type", PriorityQueueSalesLine_gRec."Document No.");
                SalesHeader_lRec.mark(true);
            until PriorityQueueSalesLine_gRec.Next() = 0;
        end;

        SalesHeader_lRec.MarkedOnly(true);
        SalesHeader_lRec.SetCurrentKey("Document Date");

        Priority_lBigInt := PriorityIncrement();
        if SalesHeader_lRec.findset then
            repeat
                PriorityQueueSalesLine_gRec.setrange("Document No.", SalesHeader_lRec."No.");
                if PriorityQueueSalesLine_gRec.findset then
                    repeat
                        //if PriorityQueueSalesLine_gRec."COR DSDS Priority" <> Priority_lBigInt then begin
                        PriorityQueueSalesLine_gRec."COR DSDS Priority" := Priority_lBigInt;
                        PriorityQueueSalesLine_gRec.Modify();
                        //end;
                        Priority_lBigInt += PriorityIncrement();
                    until PriorityQueueSalesLine_gRec.Next() = 0;
            until SalesHeader_lRec.next = 0;
    end;


    /// <summary>
    /// Ermittelt die Prioritäten basierend auf dem Warenausgangsdatum der Verkaufszeile
    /// Dabei wird die Priorität nicht auf den Auftragszeilen fixiert sondern stattdessen auf den temporären Datensätzen
    /// </summary>
    /// <param name="ItemNo_iCod"></param>
    /// <param name="LocationCode_iCod"></param>
    procedure CalculateInitialPriorityByShipmentDate() Priority_lBigInt: BigInteger;
    var
        SalesHeader_lRec: Record "Sales Header";

    begin
        // da wir initialisieren werden keine, in der Vergangenheit gesetzten Prioritäten berücksichtigt
        PriorityQueueSalesLine_gRec.Reset();
        PriorityQueueSalesLine_gRec.ModifyAll("COR DSDS Priority", 0);

        PriorityQueueSalesLine_gRec.SetLoadFields("Document type", "Document No.", "Line No.", "Shipment Date", "COR DSDS Priority");
        PriorityQueueSalesLine_gRec.SetCurrentKey("Shipment Date", "Document No.", "Line No.");

        if PriorityQueueSalesLine_gRec.findset then
            repeat
                Priority_lBigInt += PriorityIncrement();
                //if PriorityQueueSalesLine_gRec."COR DSDS Priority" <> Priority_lBigInt then begin
                PriorityQueueSalesLine_gRec."COR DSDS Priority" := Priority_lBigInt;
                PriorityQueueSalesLine_gRec.Modify();
            //end;

            until PriorityQueueSalesLine_gRec.Next() = 0;
    end;

    /// <summary>
    /// VK-Zeilen können ein DSDS Shift-to Date aufweisen
    /// Es handelt sich um ein Datum, dass im DSDS Scheduler eingegeben werden kann um VK-Aufträge zu schieben
    /// das ist insbesondere dann der Fall wenn Felix vorschlägt, Aufträge vorzuziehen oder später zu senden.
    /// </summary>
    procedure CalculateInitialPriorityByShipmentDateRegardingShifts() Priority_lBigInt: BigInteger;
    var
        SalesHeader_lRec: Record "Sales Header";
    begin
        // da wir initialisieren werden keine, in der Vergangenheit gesetzten Prioritäten berücksichtigt
        PriorityQueueSalesLine_gRec.Reset();
        PriorityQueueSalesLine_gRec.ModifyAll("COR DSDS Priority", 0);

        // hier wird das WA-Datum genommen, das in einer der beiden Spalten "Shipment date" oder "shift-to date" steht;
        PriorityQueueSalesLine_gRec.SetLoadFields("Document type", "Document No.", "Line No.", "Shipment Date", "COR DSDS shift-to Date", "COR DSDS Priority");
        if PriorityQueueSalesLine_gRec.findset then
            repeat
                if PriorityQueueSalesLine_gRec."COR DSDS Shift-to Date" = 0D then begin
                    PriorityQueueSalesLine_gRec."COR DSDS Shift-to Date" := PriorityQueueSalesLine_gRec."Shipment Date";
                    // Datensätze mit Verschiebung werden bewusst vor Datensätzen ohne Verschiebung angeordnet
                    // Dazu wird das Feld X1 zweckverfremdet.
                    PriorityQueueSalesLine_gRec."trm X1 (Unit)" := 1;
                    PriorityQueueSalesLine_gRec.Modify();
                end;
            until PriorityQueueSalesLine_gRec.next = 0;

        // Hier erfolgt nun die Priorisierung
        // Beispiel ohne Nutzung der Priorisierung verschobener Zeilen
        // PriorityQueueSalesLine_gRec.SetCurrentKey("COR DSDS shift-to Date", "Document No.", "Line No.");
        // X1 ist bei Zeilen ohne neu priorisiertes Datum 1. Bei aufsteigender Reihenfolge werden diese also hinter den priorisierte Zeilen eingeordnet.
        PriorityQueueSalesLine_gRec.SetCurrentKey("COR DSDS shift-to Date", "trm X1 (Unit)", "Document No.", "Line No.");

        if PriorityQueueSalesLine_gRec.findset then
            repeat
                Priority_lBigInt += PriorityIncrement();
                PriorityQueueSalesLine_gRec."COR DSDS Priority" := Priority_lBigInt;
                PriorityQueueSalesLine_gRec.Modify();
            until PriorityQueueSalesLine_gRec.Next() = 0;

        // Die Priorisierung ist durchgelauzfen
        // Jetzt kann das Shift-to Date wieder zurückgestellt werden
        if PriorityQueueSalesLine_gRec.findset then
            repeat
                if PriorityQueueSalesLine_gRec."COR DSDS Shift-to Date" = PriorityQueueSalesLine_gRec."Shipment Date" then begin
                    clear(PriorityQueueSalesLine_gRec."COR DSDS Shift-to Date");
                    PriorityQueueSalesLine_gRec.Modify();
                end;
            until PriorityQueueSalesLine_gRec.next = 0;
    end;

    /// <summary>
    /// Wenn Felix ein Zieldatum (shift-to date) setzt dann hat dieses Vorrang vor dem WA-Datum
    /// Erst in dem Moment in dem der Sachbearbeiter das WA-Datum ändert gilt Felix als "überstimmt";
    /// </summary>
    /// <param name="SalesLine"></param>
    /// <param name="CurrentFieldNo"></param>
    procedure SalesLineOnValidateShipmentDateOnAfterSalesLineVerifyChange(var SalesLine: Record "Sales Line"; CurrentFieldNo: Integer)
    var
    begin
        clear(SalesLine."COR DSDS Shift-to Date");

        // Bei Eingabe eines neuen WA-Datums soll der Verarbeitungshinweis automatisch entfernt werden
        // diese DEDT-463
        if CurrentFieldNo = SalesLine.FieldNo("Shipment Date") then begin
            if SalesLine."COR-DDN earliest Shipment Date" <> 0D then begin
                if SalesLine."Shipment Date" >= SalesLine."COR-DDN earliest Shipment Date" then begin
                    if SalesLine."DDN-COR Date Conflict Action" <> SalesLine."DDN-COR Date Conflict Action"::" " then begin
                        clear(SalesLine."DDN-COR Date Conflict Action");
                    end;
                end;
            end;
        end;
    end;

    /// Übernimmt die Wert aus der Page ins Modell
    /// Es erfolgt keine sonstige Weitergabe.
    /// Die Info ist wichtig wenn 
    procedure applyShiftToDate(var scheduleLine_vRec: Record "COR DSDS Schedule Line" temporary)
    var
        myInt: Integer;
    begin
        scheduleLine_gRec.get(scheduleLine_vRec."Batch No.", scheduleLine_vRec."Entry No.");
        scheduleLine_gRec."Shift-to Date" := scheduleLine_vRec."Shift-to Date";
        scheduleLine_gRec.Modify();
    end;

    /// <summary>
    /// Kopiert alle Verkaufszeilen in einem temporären Puffer
    /// Der Puffer ist die Basis für die Berechnung von Prioritäten.
    /// Ergebnis dieser Berechnung ist eine Liste mit Verkaufsaufträgen. Dies emuss danach priorisiert werden.
    /// </summary>
    /// <param name="ItemNo_iCod"></param>
    /// <param name="LocationCode_gCod"></param>
    local procedure CreatePriorityQueue()
    var
        SalesLine_lRec: Record "Sales Line";
        EntryNo_lInt: Integer;
    begin
        SalesLine_lRec.SetRange("Document Type", SalesLine_lRec."Document Type"::Order);
        SalesLine_lRec.setrange("No.", ItemNo_gCod);
        SalesLine_lRec.setrange("Location Code", LocationCode_gCod);
        SalesLine_lRec.setfilter("Outstanding Qty. (Base)", '>0');
        // Bei Spezialauftrag muss fegilterter werden
        if WorkWithFocusOnSalesLine() then begin
            if focusSalesLine_gRec."Special Order" then begin
                SalesLine_lRec.SetRange("Document No.", focusSalesLine_gRec."Document No.");
                SalesLine_lRec.SetRange("Line No.", focusSalesLine_gRec."Line No.");
            end
            else begin
                SalesLine_lRec.SetRange("Special Order", false);
            end;
        end
        else begin
            // im Stapellauf oder beim Aufruf über den Artikel wird nicht mit Fokus auf der Auftragszeile gearbeitet
            SalesLine_lRec.SetRange("Special Order", false);
        end;

        PriorityQueueSalesLine_gRec.reset();
        PriorityQueueSalesLine_gRec.DeleteAll();

        if SalesLine_lRec.FindSet() then begin
            repeat
                PriorityQueueSalesLine_gRec.init;
                PriorityQueueSalesLine_gRec.TransferFields(SalesLine_lRec);

                // ein "neuer" Auftrag soll in der Prio ganz hinten eingestellt werden
                // Das muss auch auf das WA-Datum zutreffen weil in der Zeile das WA-Datum
                // mit aktuellem Tagesdatum stehen wird
                // Das Dilemma: Wann ist ein Auftrag "neu" bzw das WA-Datum nicht bewusst korrigiert?
                if WorkWithFocusOnSalesLine() then begin
                    if (focusSalesLine_gRec."Document No." = PriorityQueueSalesLine_gRec."Document No.") and (focusSalesLine_gRec."Line No." = PriorityQueueSalesLine_gRec."Line No.") then begin
                        if FocusSalesLineSeemsToBeUnscheduled() then begin
                            // ein Hack HACK001um das ursprüngliche WA-Datum nicht zu verlieren
                            PriorityQueueSalesLine_gRec."trm Earliest Shipment Date" := PriorityQueueSalesLine_gRec."Shipment Date";
                            PriorityQueueSalesLine_gRec."Shipment Date" := 20991231D;
                            PriorityQueueSalesLine_gRec."COR DSDS Priority" := 99999998;

                        end;
                    end;
                end;
                PriorityQueueSalesLine_gRec.Insert(false);
            until SalesLine_lRec.Next() = 0;
        end;

        if WorkWithFocusOnSalesLine() then begin
            if focusSalesLine_gRec."Document Type" = focusSalesLine_gRec."Document Type"::Quote then begin
                PriorityQueueSalesLine_gRec.TransferFields(focusSalesLine_gRec);
                PriorityQueueSalesLine_gRec."Shipment Date" := 20991231D;
                PriorityQueueSalesLine_gRec."COR DSDS Priority" := 99999999;
                PriorityQueueSalesLine_gRec.Insert()
            end
        end
    end;

    /// <summary>
    /// aktualisiert die Spalte Balance für alle Zeilen
    /// Die SPalte ist wichtig für die Ermittlung des Verlaufs der Mengen
    /// </summary>
    local procedure updateBalance()
    var
    begin
        scheduleLine_gRec.Reset();
        updateBalance(scheduleLine_gRec);
        scheduleLine_gRec.Reset();
    end;

    /// Wird benötigt wenn in der Page auf Sortierung via Datum gewechselt wird
    procedure updateBalance(var scheduleLine_vRec: Record "COR DSDS Schedule Line")
    var
        balance_lDec: Decimal;
    begin
        clear(balance_lDec);
        scheduleLine_vRec.ModifyAll(Balance, 0);
        if scheduleLine_vRec.FindSet() then
            repeat
                balance_lDec += scheduleLine_vRec.Balance + scheduleLine_vRec."Outstanding Quantity (Base)";
                scheduleLine_vRec.Balance := balance_lDec;
                scheduleLine_vRec.Modify();
            until scheduleLine_vRec.next() = 0;
    end;


    local procedure deleteBacklogFromSchedule()
    var
        backlogEntryNo_lInt: Integer;
    begin
        scheduleLine_gRec.Reset();
        scheduleLine_gRec.SetRange("Source Type", scheduleLine_gRec."Source Type"::Backlog);
        if scheduleLine_gRec.findfirst() then begin
            backlogEntryNo_lInt := scheduleLine_gRec."Entry No.";
            scheduleLine_gRec.SetRange("Source Type");
            scheduleLine_gRec.SetRange("assigned to Entry No.", backlogEntryNo_lInt);
            if scheduleLine_gRec.IsEmpty then begin
                scheduleLine_gRec.Reset();
                scheduleLine_gRec.get('', backlogEntryNo_lInt);
                scheduleLine_gRec.Delete();
            end;
        end;
        scheduleLine_gRec.Reset();
    end;

    /// <summary>
    /// bestimmt, ob der Scheduler von einer VK-Zeile aus aufgerufen wurde.
    /// Das hat z.B. Auswirkungen darauf, mit welchem WA-Datum die Zeile behandelt wird wenn ein frühst mögliches Datum
    /// errechnet werden soll;
    /// </summary>
    /// <returns></returns>
    local procedure WorkWithFocusOnSalesLine(): Boolean
    var
        myInt: Integer;
    begin
        exit(focusSalesLine_gRec."Document No." <> '');
    end;

    /// <summary>
    /// Markiert den VK-Auftrag aus dem der Scheduler heraus augerufen wurde
    /// </summary>
    local procedure updateFocus()
    var
        balance_lDec: Decimal;
    begin
        if not WorkWithFocusOnSalesLine() then
            exit;
        scheduleLine_gRec.reset();
        if focusSalesLine_gRec."Document Type" = focusSalesLine_gRec."Document Type"::Order then
            scheduleLine_gRec.SetRange("Source Type", scheduleLine_gRec."Source Type"::"Sales Order")
        else
            scheduleLine_gRec.SetRange("Source Type", scheduleLine_gRec."Source Type"::"Sales Quote");
        scheduleLine_gRec.SetRange("Source No.", focusSalesLine_gRec."Document No.");
        scheduleLine_gRec.SetRange("Source Line No.", focusSalesLine_gRec."Line No.");
        scheduleLine_gRec.ModifyAll("Focus Icon", '▶');
        scheduleLine_gRec.reset();
    end;

    /// <summary>
    /// markiert Zeilen bei denen das WA-Datum nicht zum frühst möglichen WA-Datum harmoniert
    /// </summary>
    local procedure detectDateConflicts()
    var
        myInt: Integer;
    begin
        scheduleLine_gRec.Reset();
        scheduleLine_gRec.setrange(direction, scheduleLine_gRec.direction::negative);
        scheduleLine_gRec.SetFilter("earliest shipment date", '<>%1', 0D);
        if scheduleLine_gRec.FindSet() then
            repeat
                if scheduleLine_gRec."earliest shipment date" > scheduleLine_gRec."Receipt/Shipment Date" then
                    scheduleLine_gRec."Shipment Date Conflict" := scheduleLine_gRec."Shipment Date Conflict"::ShipmentDateTooEarly
                else
                    if scheduleLine_gRec."earliest shipment date" < scheduleLine_gRec."Receipt/Shipment Date" then
                        scheduleLine_gRec."Shipment Date Conflict" := scheduleLine_gRec."Shipment Date Conflict"::earlierShipmentPossible
                    else
                        scheduleLine_gRec."Shipment Date Conflict" := scheduleLine_gRec."Shipment Date Conflict"::noConflict;
                scheduleLine_gRec.Modify();
            until scheduleLine_gRec.next() = 0;
        scheduleLine_gRec.Reset();
    end;

    /// <summary>
    /// Ermittelt basierend auf dem Artikelstamm und den darin hinterlegten Wiederbschaffungszeiten das mögliche
    /// Wiederbschaffungsdatum
    /// </summary>
    local procedure FindBacklogShipmentDate(ItemNo_iCod: Code[20]; LocationCode_iCod: Code[20]) earliestShipmentDate: Date
    var
        item_lRec: Record Item;
        Location_lRec: Record Location;
        api: Codeunit "trm API Purchase Create";
        pl: record "Purchase Line";
        CustomCalendarChange: Array[2] of Record "Customized Calendar Change";
        CalChange: Record "Customized Calendar Change";
        CalendarMgmt: Codeunit "Calendar Management";
        leadTime_ldf: DateFormula;
    begin
        if ddnSetup."Leadtime on neg. availiblity" then begin
            item_lRec.get(ItemNo_iCod);
            CustomCalendarChange[1].SetSource(CalChange."Source Type"::Vendor, item_lRec."Vendor No.", '', '');
            CustomCalendarChange[2].SetSource(CalChange."Source Type"::Location, LocationCode_iCod, '', '');
            if FORMAT(item_lRec."Lead Time Calculation") <> '' then begin
                leadTime_ldf := item_lRec."Lead Time Calculation";
            end
            else begin
                ddnSetup.TestField("Worst case replen. DateForm.");
                leadTime_ldf := ddnSetup."Worst case replen. DateForm.";
            end;
            // Berechnung des Datums auf Grund der Kalender (Berückischtigung freier Tage)
            earliestShipmentDate := CalendarMgmt.CalcDateBOC(pl.AdjustDateFormula(leadTime_ldf), workdate(), CustomCalendarChange, true);
            // Wareneingangs-Handling-Zeit addieren
            if FORMAT(Location_lRec."Inbound Whse. Handling Time") <> '' then
                earliestShipmentDate := calcdate(Location_lRec."Inbound Whse. Handling Time", earliestShipmentDate);
            // auf einen passenden Tag runden
            if format(ddnSetup."Worst case replen. rounding") <> '' then
                earliestShipmentDate := calcdate(ddnSetup."Worst case replen. rounding", earliestShipmentDate);

            // if FORMAT(item_lRec."Lead Time Calculation") <> '' then begin
            //     earliestShipmentDate := CalendarMgmt.CalcDateBOC(pl.AdjustDateFormula(item_lRec."Lead Time Calculation"), workdate(), CustomCalendarChange, true);
            // end else begin
            //     ddnSetup.TestField("Worst case replen. DateForm.");
            //     earliestShipmentDate := CalendarMgmt.CalcDateBOC(pl.AdjustDateFormula(ddnSetup."Worst case replen. DateForm."), workdate(), CustomCalendarChange, true);
            //     if format(ddnSetup."Worst case replen. rounding") <> '' then
            //         earliestShipmentDate := calcdate(ddnSetup."Worst case replen. rounding", earliestShipmentDate);

            // end;
            // Location_lRec.get(LocationCode_iCod);
            // if FORMAT(Location_lRec."Inbound Whse. Handling Time") <> '' then
            //     earliestShipmentDate := calcdate(Location_lRec."Inbound Whse. Handling Time", earliestShipmentDate);


        end;
        exit;

        // // falls keine Bestellung vorliegt wird stattdessen mit der Wiederbschaffung gearbeitet
        // // und ggf. mit einem Fallback-Wert
        // if ddnSetup."Leadtime on neg. availiblity" then begin
        //     // ggf. Artikel-Wiederbeschaffungszeiten nutzen falls eingestellt
        //     // um tägliches Flattern zu verhindern wird der folgende montag zum Arbeitsdatum herangezogen
        //     item_lRec.get(ItemNo_iCod);

        //     if FORMAT(item_lRec."Lead Time Calculation") <> '' then begin
        //         earliestShipmentDate := calcdate(item_lRec."Lead Time Calculation", WorkDate())
        //     end
        //     else begin
        //         ddnSetup.TestField("Worst case replen. DateForm.");
        //         earliestShipmentDate := calcdate(ddnSetup."Worst case replen. DateForm.", WorkDate())
        //     end;

        //     Location_lRec.get(LocationCode_iCod);
        //     if FORMAT(Location_lRec."Inbound Whse. Handling Time") <> '' then
        //         earliestShipmentDate := calcdate(Location_lRec."Inbound Whse. Handling Time", earliestShipmentDate);

        //     if format(ddnSetup."Worst case replen. rounding") <> '' then
        //         earliestShipmentDate := calcdate(ddnSetup."Worst case replen. rounding", earliestShipmentDate);
        // end;
    end;



    /// <summary>
    /// Löscht die Prioritäten aus VK-Zeilen. Das machtr insbesondere zu BEginn während der Tests Sinn
    /// </summary>
    /// <param name="ItemNo_iCod"></param>
    /// <param name="LocationCode_iCod"></param>
    procedure VanishPriority(ItemNo_iCod: Code[20]; LocationCode_iCod: Code[20])
    var
        vansihConfimrDialog_lLlb: Label 'All priorities within %1 sales lines for this item will be reset. This is ok during testing or special constallations. Do you know what you do?';
        SalesLine_lRec: Record "Sales Line";
        EntryNo_lInt: Integer;
    begin
        SalesLine_lRec.SetRange("Document Type", SalesLine_lRec."Document Type"::Order);
        SalesLine_lRec.SetRange(Type, SalesLine_lRec.Type::Item);
        SalesLine_lRec.setrange("No.", ItemNo_iCod);
        SalesLine_lRec.setrange("Location Code", LocationCode_iCod);
        SalesLine_lRec.SetFilter("COR DSDS Priority", '>0');
        if not Confirm(vansihConfimrDialog_lLlb, false, SalesLine_lRec.count()) then
            exit;
        SalesLine_lRec.ModifyAll("COR DSDS Priority", 0, false);
    end;

    /// <summary>
    /// Errechnet eine Priorität für eine VK-Zeile, der bislang eine Priortität fehlt
    /// Dabei muss die VK-Zeile andere, bereits priorisierte VK-Zeilen berücksichtigen.
    /// </summary>
    procedure QueueUnpriorisedSalesLine(var SalesLine_iRec: Record "Sales Line"; doModify: Boolean)
    var
    begin
        QueueUnpriorisedSalesLineByOrderDate(SalesLine_iRec, doModify)
    end;

    /// <summary>
    /// Ordnet eine nicht priorisierte VK-Zeile am Ende der Prioritätenliste ein.
    /// Die VK-Zeile wird dabei aktualisiert.
    /// </summary>
    /// <param name="SalesLine_iRec"></param>
    local procedure QueueUnpriorisedSalesLineByOrderDate(var SalesLine_iRec: Record "Sales Line"; doModify: Boolean)
    var
        OtherSalesLine_lRec: Record "Sales Line";
        SucessorSalesLine_lRec: Record "Sales Line";
        SalesHeader_lRec: Record "Sales Header";
        priority_lBigInt: BigInteger;
        minPriority, maxPriority : BigInteger;
    begin
        if not SalesLineIsUnpriorised(SalesLine_iRec) then
            exit;

        // Aufbau des Schedules gem. Modell
        // Das Modell errechnet für jede VK-Zeile Prioritäten. Diese können von den tatsächlich, in den VK-Zeilen hinterlegten Prioritäten abweichen.

        // Eine kurz vorher erstellte VK-Zeile kann auf Grund einer Verschiebung weit nach vorne geschoben
        // worden sein. Ihre Priorität wäre damit nicht wirklich repräsentativ
        // Daher gehen wir pragmatisch den Weg und hängen den Aufrag in der Priortitätenreihenfolge an letzte Stelle
        OtherSalesLine_lRec.SetLoadFields("COR DSDS Priority");
        OtherSalesLine_lRec.SetCurrentKey("COR DSDS Priority");
        OtherSalesLine_lRec.SetRange("Document Type", SalesLine_iRec."Document Type");
        OtherSalesLine_lRec.SetRange("Location Code", SalesLine_iRec."Location Code");
        OtherSalesLine_lRec.SetRange("No.", SalesLine_iRec."No.");
        OtherSalesLine_lRec.Setfilter("COR DSDS Priority", '>0');

        if OtherSalesLine_lRec.findlast() then begin
            priority_lBigInt := OtherSalesLine_lRec."COR DSDS Priority";
        end;
        priority_lBigInt += PriorityIncrement;
        SalesLine_iRec."COR DSDS Priority" := priority_lBigInt;
        if doModify then
            SalesLine_iRec.Modify();
    end;

    local procedure QueueUnpriorisedSalesLineByShipmentDate(var SalesLine_iRec: Record "Sales Line")
    var
        PredecessorSalesLine_lRec: Record "Sales Line";
        SucessorSalesLine_lRec: Record "Sales Line";
    begin
        // Errechne dir Prioritäten basierend auf temporären VK-Zeilen
        error('QueueUnpriorisedSalesLineByShipmentDate() not yet implemented');
        //PredecessorSalesLine_lRec.setrange("Shipment Date", 0D, SalesLine_iRec."Shipment Date");
    end;


    /// <summary>
    /// wird genutzt um die Priority-Queue als Factbox darzustellen
    /// </summary>
    procedure GetPriorityQueue(var salesLine_iRec: Record "Sales Line" temporary)
    var
    begin
        if not salesLine_iRec.IsTemporary then
            error('CU51019 GetPriorityQueue() may only be called with temporary sales lines.');
        salesLine_iRec.DeleteAll();
        if PriorityQueueSalesLine_gRec.FindSet() then begin
            repeat
                salesLine_iRec := PriorityQueueSalesLine_gRec;
                salesLine_iRec.insert;
            until PriorityQueueSalesLine_gRec.next() = 0;
        end
    end;

    /// <summary>
    /// wird genutzt um die Priority-Queue als Factbox darzustellen
    /// </summary>
    procedure GetScheduleLines(var scheduleLine_iRec: Record "COR DSDS Schedule Line" temporary)
    var
    begin
        scheduleLine_iRec.DeleteAll();
        if scheduleLine_gRec.findset then
            repeat
                scheduleLine_iRec := scheduleLine_gRec;
                scheduleLine_iRec.insert;
            until scheduleLine_gRec.Next() = 0;
        scheduleLine_iRec := scheduleLine_gRec;
    end;

    local procedure PriorityIncrement(): Integer;
    var
    begin
        exit(100)
    end;

    local procedure testContext()
    var
        MissingItemContext_lLlb: Label 'Missing Item Context for CU 51019. This means that DSDS does not know on wich item it shoul work. Maybe your Session has expired before?';
    begin
        if ItemNo_gCod = '' then
            error(MissingItemContext_lLlb);
    end;

    /// <summary>
    /// muss aufgerufen werden bevor ein Schedule errechnet werden kann
    /// Es werden Lagerortcode und Artikel global gesetzt.
    /// </summary>
    /// <param name="ItemNo_iCod"></param>
    /// <param name="LocationCode_iCod"></param>
    procedure InitObject(ItemNo_iCod: Code[20]; LocationCode_iCod: Code[20])
    var
        MissingItemNo_lLbl: Label 'DSDS is initiated without an item no. That wount'' work.';
    begin
        ClearAll();
        ddnSetup.get();
        if ItemNo_iCod = '' then
            error(MissingItemNo_lLbl);
        ItemNo_gCod := ItemNo_iCod;
        if LocationCode_iCod <> '' then
            LocationCode_gCod := LocationCode_iCod
        else
            LocationCode_gCod := ddnSetup."Location Code Winsen";
        splitEnabled_gBool := ddnSetup."enable DSDS Sales Line Split";
    end;

    /// <summary>
    /// Ermittelt das nächst mögliche WA-Datum
    /// Dabei wird das Prioritäten-Modell angewandt. Dieses kann eine PErspektive basierend auf WA-Datum, Auftragsdatum oder expliziter Priorisierung annehmen.
    /// </summary>
    /// <param name="salesLine_iRec"></param>
    /// <param name="ErrorOnMissingDate_iBool"></param>
    /// <returns></returns>
    procedure FindEarliestShipmentDateForSalesLine(var salesLine_iRec: Record "Sales Line"; ErrorOnMissingDate_iBool: Boolean) earliestShipmentDate_lDate: Date
    var
        NoShipmentDateCalucaltedError_lLbl: Label 'No earliest shipment date could be calculated';
    begin
        scheduleLine_gRec.Reset();

        case salesLine_iRec."Document Type" of
            salesLine_iRec."Document Type"::Order:
                scheduleLine_gRec.setrange("Source Type", scheduleLine_gRec."Source Type"::"Sales Order");
            salesLine_iRec."Document Type"::Quote:
                scheduleLine_gRec.setrange("Source Type", scheduleLine_gRec."Source Type"::"Sales Quote");
            else
                exit;
        end;

        scheduleLine_gRec.setrange("Source No.", salesLine_iRec."Document No.");
        scheduleLine_gRec.setrange("Source Line No.", salesLine_iRec."Line No.");
        // findlast um ggf. Jungheinrich-Zeilen zu ignorieren
        if not scheduleLine_gRec.findlast() then begin
            if ErrorOnMissingDate_iBool then
                error(NoShipmentDateCalucaltedError_lLbl);
            exit;
        end;
        if scheduleLine_gRec."earliest shipment date" = 0D then begin
            if ErrorOnMissingDate_iBool then
                error(NoShipmentDateCalucaltedError_lLbl);
            exit;
        end;
        earliestShipmentDate_lDate := scheduleLine_gRec."earliest shipment date";
        scheduleLine_gRec.reset();
    end;

    /// <summary>
    /// Wird genutzt um eine Zeile im Scheduler optisch hervorzuheben.
    /// und acuh um Spezialauftrag abzuwickeln
    /// </summary>
    /// <param name="SalesLine_iRec"></param>
    procedure SetFocusOnSalesLine(var SalesLine_iRec: Record "Sales Line")
    var

    begin
        focusSalesLine_gRec := SalesLine_iRec;
    end;

    /// <summary>
    /// Versucht zu ermitteln, ob die Auftragszeile, auf der der Foku steht, terminiert wurde
    /// Hintergrund ist, dass bei Berechnung der Priorität gem. WA-Datum eine "neue" Auftragszeile weit hinten terminiert
    /// dargestellt sein sollte.
    /// </summary>
    local procedure FocusSalesLineSeemsToBeUnscheduled(): Boolean
    var
        modificationDate_lDateTime: DateTime;
        SalesHeader_lRec: Record "Sales Header";

    begin
        if not WorkWithFocusOnSalesLine() then
            exit(false);
        // Zeilen ohne errechnets frühst mögliches WA-Datum sind definitv ungeplant.
        if focusSalesLine_gRec."COR-DDN earliest Shipment Date" = 0D then
            exit(true);
        // Zelen ohne Prio wurden nie terminiert
        if SalesLineIsUnpriorised(focusSalesLine_gRec) then
            exit(true);
        // Sind WA-Datum im Kopf und in den Zeilen abweichend von einandern dann
        // weist das darauf hin, dass das WA-Datum bewusst geändert wurde
        SalesHeader_lRec.get(focusSalesLine_gRec."Document Type", focusSalesLine_gRec."Document No.");
        if SalesHeader_lRec."Shipment Date" <> focusSalesLine_gRec."Shipment Date" then
            exit(false);
        // pessimistisch gehen wird davon aus, dass die Zeile noch kein brauchbares WA-Datum hat. Sie wird hinten eingeordent.
        exit(true);
    end;

    local procedure SalesLineIsUnpriorised(var SalesLine_iRec: Record "Sales Line"): Boolean
    var
        myInt: Integer;
    begin
        //exit(SalesLine_iRec."COR DSDS Priority" in [0, 999999999, 1000009999])
        exit(SalesLine_iRec."COR DSDS Priority" in [0, 99999998, 99999999, 1000009999])
    end;

    /// <summary>
    /// Sucht aus dem Scheduler alle Verkaufszeilen um denen durch Aufruf
    /// einer Untero
    /// </summary>
    /// <returns></returns>
    procedure UpdateSalesLinesWithKnowledeAboutShipment() countModifiedLines: Integer
    var
        salesLine_lRec: Record "Sales Line";
    begin
        scheduleLine_gRec.Reset();
        scheduleLine_gRec.setrange("Source Type", scheduleLine_gRec."Source Type"::"Sales Order");
        ddnSetup.get();
        if scheduleLine_gRec.FindSet() then
            repeat
                if salesLine_lRec.get(salesLine_lRec."Document Type"::Order, scheduleLine_gRec."Source No.", scheduleLine_gRec."Source Line No.") then begin
                    // Zwischenspeichern weil scheduleLine_gRec ein globaler Record ist, dessen Filter sich
                    // durch Aufruf von UpdateSalesLineWithKnowledeAboutShipment  ändert
                    salesLine_lRec.mark(true);
                end;
            until scheduleLine_gRec.Next() = 0;
        salesLine_lRec.MarkedOnly(true);
        scheduleLine_gRec.Reset();
        if salesLine_lRec.findset then
            repeat
                if UpdateSalesLineWithKnowledeAboutShipment(salesLine_lRec) then begin
                    countModifiedLines += 1;
                end;
            until salesLine_lRec.Next() = 0;

    end;

    /// <summary>
    /// Schreibt fürhstes Lieferdatum auf die Sales-Line und schlägt Handlungsempfhelungen vor
    /// </summary>
    /// <returns></returns>
    procedure UpdateSalesLineWithKnowledeAboutShipment(var salesLine_vRec: Record "Sales Line") modified: Boolean
    var
        xSalesLine_lRec: Record "Sales Line";
    begin
        // da die Funktion auch direkt aus dem Verfügbarketischeck der VK-Zeilen abrufbar ist muss hier der Scheduler neu auf die VK-Zeile initiiert werden
        scheduleLine_gRec.Reset();
        scheduleLine_gRec.setrange("Source Type", scheduleLine_gRec."Source Type"::"Sales Order");
        scheduleLine_gRec.setrange("Source No.", salesLine_vRec."Document No.");
        scheduleLine_gRec.setrange("Source Line No.", salesLine_vRec."Line No.");
        // findlast weil es z.B. bei Jungheinrich zwei Zeilen geben könnte, denen der VK-Auftrag zugeordnet ist
        if not scheduleLine_gRec.findlast then begin
            scheduleLine_gRec.Reset();
            exit;
        end;

        xSalesLine_lRec.Copy(salesLine_vRec);
        // nehme das frühst möglichge Lieferdatum aus dem Schedule und schreibe es in die VK-Zeilen
        salesLine_vRec."COR-DDN earliest Shipment Date" := scheduleLine_gRec."earliest shipment date";
        if not (ddnSetup."Availibility Check with past") and (salesLine_vRec."COR-DDN earliest Shipment Date" < WorkDate()) then begin
            salesLine_vRec."COR-DDN earliest Shipment Date" := WorkDate();
        end;

        CalcProcessingHint_lFnc(salesLine_vRec);
        CalcDelayedFlag_lFnc(salesLine_vRec);

        if salesLine_vRec."Shipment Date" >= salesLine_vRec."COR-DDN earliest Shipment Date" then begin
            case xSalesLine_lRec."DDN-COR Date Conflict Action" of
                salesLine_vRec."DDN-COR Date Conflict Action"::DateConflictExists:
                    salesLine_vRec."DDN-COR Date Conflict Action" := salesLine_vRec."DDN-COR Date Conflict Action"::" ";
                salesLine_vRec."DDN-COR Date Conflict Action"::DateConflictPostponed:
                    salesLine_vRec."DDN-COR Date Conflict Action" := salesLine_vRec."DDN-COR Date Conflict Action"::" ";
                salesLine_vRec."DDN-COR Date Conflict Action"::" ":
                    salesLine_vRec."DDN-COR Date Conflict Action" := salesLine_vRec."DDN-COR Date Conflict Action"::" ";
                salesLine_vRec."DDN-COR Date Conflict Action"::DateConflictSolved:
                    salesLine_vRec."DDN-COR Date Conflict Action" := salesLine_vRec."DDN-COR Date Conflict Action"::" ";
            end;
        end
        // hier ist ein Datumskonflikt erkannt wordern
        else begin
            case xSalesLine_lRec."DDN-COR Date Conflict Action" of
                salesLine_vRec."DDN-COR Date Conflict Action"::DateConflictExists:
                    salesLine_vRec."DDN-COR Date Conflict Action" := salesLine_vRec."DDN-COR Date Conflict Action"::DateConflictExists;
                salesLine_vRec."DDN-COR Date Conflict Action"::DateConflictPostponed:
                    salesLine_vRec."DDN-COR Date Conflict Action" := salesLine_vRec."DDN-COR Date Conflict Action"::DateConflictPostponed;
                salesLine_vRec."DDN-COR Date Conflict Action"::" ":
                    salesLine_vRec."DDN-COR Date Conflict Action" := salesLine_vRec."DDN-COR Date Conflict Action"::DateConflictExists;
                salesLine_vRec."DDN-COR Date Conflict Action"::DateConflictSolved:
                    salesLine_vRec."DDN-COR Date Conflict Action" := salesLine_vRec."DDN-COR Date Conflict Action"::DateConflictExists;
            end;
        end;

        if (xSalesLine_lRec."DDN Processing Hint" <> salesLine_vRec."DDN Processing Hint")
        or (xSalesLine_lRec."DDN Shipment Delayed" <> salesLine_vRec."DDN Shipment Delayed")
        or (xSalesLine_lRec."COR-DDN earliest Shipment Date" <> salesLine_vRec."COR-DDN earliest Shipment Date")
        or (xSalesLine_lRec."DDN-COR Date Conflict Action" <> salesLine_vRec."DDN-COR Date Conflict Action")
        or ddnSetup."Force Avail. Sales Line Modify" then begin
            // Handlungsanweisung für Benutzer generieren, bzw. Datensatz so markieren, dass er als "ToDo" angesehen wird.
            // Das nächst mögliche Datum hat sich nach hinten verschoeben
            //if xSalesLine_lRec."COR-DDN earliest Shipment Date" < salesLine_lRec."COR-DDN earliest Shipment Date" then begin
            // Das Warenausgangsdatum ist vor dem nächst möglichen Versanddatum

            //end;
            salesLine_vRec."COR-DDN Availib. Modified Date" := WorkDate();
            salesLine_vRec.Modify(false);
            modified := true;
        end;

        scheduleLine_gRec.Reset();
    end;

    /// <summary>
    /// Die Funktion bekommt eine ScheduleLine als Parameter weil sie von der Page
    /// aufgerufen wird. In der PAge wurde ggf. eine Prio von Hand eingetippt.
    /// </summary>
    /// <param name="scheduleLine_iRec"></param>
    /// <param name="verbose"></param>
    procedure TransferPriorityFromScheduleToSalesLine_lFunction(var scheduleLine_iRec: Record "COR DSDS Schedule Line"; verbose: Boolean) countModifiedLines_lInt: Integer;
    var
        salesLine_lRec: Record "Sales Line";
        NoLinesModifiedMsg_lLbl: Label 'No changes have been detected.';
        LinesModifiedMsg_lLbl: Label '%1 Sales Lines have been modified.';
    begin
        scheduleLine_iRec.Reset();
        scheduleLine_iRec.setrange("Source Type", scheduleLine_iRec."Source Type"::"Sales Order");
        if scheduleLine_iRec.findset then
            repeat
                if salesLine_lRec.get(salesLine_lRec."Document Type"::Order, scheduleLine_iRec."Source No.", scheduleLine_iRec."Source Line No.") then begin
                    if salesLine_lRec."COR DSDS Priority" <> scheduleLine_iRec."Outgoing Priority" then begin
                        salesLine_lRec."COR DSDS Priority" := scheduleLine_iRec."Outgoing Priority";
                        salesLine_lRec.Modify();
                        countModifiedLines_lInt += 1;
                    end;
                end;
            until scheduleLine_iRec.Next() = 0;
        if verbose then begin
            if countModifiedLines_lInt = 0 then
                Message(NoLinesModifiedMsg_lLbl)
            else
                Message(LinesModifiedMsg_lLbl, countModifiedLines_lInt);

        end;
        scheduleLine_iRec.Reset();
    end;

    procedure TransferPriorityFromScheduleToSalesLine_lFunction(verbose: Boolean)
    begin
        TransferPriorityFromScheduleToSalesLine_lFunction(scheduleLine_gRec, verbose);
    end;

    local procedure CalcProcessingHint_lFnc(var SalesLine_ivRec: Record "Sales Line")
    var
        item_lRec: Record Item;
    begin
        clear(SalesLine_ivRec."DDN Processing Hint");
        // gibt es keine Zeile mit negativem Balance reicht der Bestand um alles zu bedienen
        // dann ist alles gut :)
        scheduleLine_gRec.Reset();
        scheduleLine_gRec.SetRange("Source Type", scheduleLine_gRec."Source Type"::"Sales Order");
        scheduleLine_gRec.SetRange("Source No.", SalesLine_ivRec."Document No.");
        scheduleLine_gRec.SetRange("Source Line No.", SalesLine_ivRec."Line No.");
        if not scheduleLine_gRec.FindLast() then begin
            scheduleLine_gRec.Reset();
            exit;
        end;
        // alles ist gut wenn an dem Datum der BEstand passt
        if SalesLine_ivRec."COR-DDN earliest Shipment Date" > SalesLine_ivRec."Shipment Date" then begin
            if scheduleLine_gRec.Balance >= 0 then begin
                SalesLine_ivRec."DDN Processing Hint" := SalesLine_ivRec."DDN Processing Hint"::OnStockProjected;
            end
            else begin
                SalesLine_ivRec."DDN Processing Hint" := SalesLine_ivRec."DDN Processing Hint"::OutOfStockProjected;
            end;
        end
        else begin
            if scheduleLine_gRec.Balance >= 0 then begin
                SalesLine_ivRec."DDN Processing Hint" := SalesLine_ivRec."DDN Processing Hint"::OnStock;
            end
            else begin
                SalesLine_ivRec."DDN Processing Hint" := SalesLine_ivRec."DDN Processing Hint"::OutOfStock;
            end;
        end;
        scheduleLine_gRec.Reset();
        // errechnet das Icon auf der VK-Zeile
        SalesLine_ivRec.Validate("DDN Processing Hint");
    end;


    /// <summary>
    /// Errechnet ein Kennzeichen basierend auf dem Warenausgangsdatum und dem von Trimit
    /// errechneten frühesten Warenausgangsdatum um die VK-Zeile zu kennzeichnen
    /// <see cref="#D5C7"/> 
    /// </summary>
    /// <param name="SalesLine_viRec"></param>
    procedure CalcDelayedFlag_lFnc(var SalesLine_viRec: Record "Sales Line")
    var

    begin
        SalesLine_viRec."DDN Shipment Delayed" := false;
        //SalesLine_viRec."DDN Shipment Delayed" := SalesLine_viRec."Shipment Date" < SalesLine_viRec."trm Earliest Shipment Date";
        if SalesLine_viRec."Shipment Date" < SalesLine_viRec."COR-DDN Earliest Shipment Date" then begin
            SalesLine_viRec."DDN Shipment Delayed" := true;
        end
        else begin
            if SalesLine_viRec."Shipment Date" < WorkDate() then begin
                SalesLine_viRec."DDN Shipment Delayed" := true;
            end
        end;
    end;

    procedure TransferShiftToDateFromScheduleToSalesLine_lFunction(var scheduleLine_iRec: Record "COR DSDS Schedule Line"; verbose: Boolean) countModifiedLines_lInt: Integer;
    var
        salesLine_lRec: Record "Sales Line";
        NoLinesModifiedMsg_lLbl: Label 'No changes have been detected.';
        LinesModifiedMsg_lLbl: Label '%1 Sales Lines have been modified.';
    begin
        scheduleLine_iRec.Reset();
        scheduleLine_iRec.setrange("Source Type", scheduleLine_iRec."Source Type"::"Sales Order");
        if scheduleLine_iRec.findset then
            repeat
                if salesLine_lRec.get(salesLine_lRec."Document Type"::Order, scheduleLine_iRec."Source No.", scheduleLine_iRec."Source Line No.") then begin
                    if salesLine_lRec."COR DSDS Shift-to Date" <> scheduleLine_iRec."Shift-to Date" then begin
                        salesLine_lRec."COR DSDS Shift-to Date" := scheduleLine_iRec."Shift-to Date";
                        salesLine_lRec.Modify();
                        countModifiedLines_lInt += 1;
                    end;
                end;
            until scheduleLine_iRec.Next() = 0;
        if verbose then begin
            if countModifiedLines_lInt = 0 then
                Message(NoLinesModifiedMsg_lLbl)
            else
                Message(LinesModifiedMsg_lLbl, countModifiedLines_lInt);

        end;
        scheduleLine_iRec.Reset();
    end;

    /// <summary>
    /// Gibt an, auf welchem Modell sich die Verfügbarkeiten berechnet haben
    /// </summary>
    procedure GetActivePriorityModel(): enum "COR DSDS Priority Model"
    var
    begin
        exit(activePriorityModel);
    end;

    /// <summary>
    /// hängt Angebote pauschal immer ans Ende
    /// </summary>
    local procedure shiftSalesQuotesPriorityToEnd()
    var
        Priority_iBigInt: BigInteger;
    begin

        PriorityQueueSalesLine_gRec.reset;
        PriorityQueueSalesLine_gRec.SetCurrentKey("COR DSDS Priority");
        if PriorityQueueSalesLine_gRec.findlast then
            Priority_iBigInt := PriorityQueueSalesLine_gRec."COR DSDS Priority";
        Priority_iBigInt += PriorityIncrement();
        PriorityQueueSalesLine_gRec.reset;
        PriorityQueueSalesLine_gRec.SetRange("Document Type", PriorityQueueSalesLine_gRec."Document Type"::Quote);
        PriorityQueueSalesLine_gRec.ModifyAll("COR DSDS Priority", Priority_iBigInt);
        PriorityQueueSalesLine_gRec.SetRange("Document Type");
        PriorityQueueSalesLine_gRec.reset;
    end;


    var
        ItemNo_gCod: Code[20];
        LocationCode_gCod: Code[20];
        ddnSetup: Record "DDN Setup";
        scheduleLine_gRec: Record "COR DSDS Schedule Line" temporary;
        PriorityQueueSalesLine_gRec: Record "Sales Line" temporary;
        focusSalesLine_gRec: Record "Sales Line" temporary;
        // für aufrunde Page wird die Info genutzt um darzustellen, weleche View aktiv ist
        activePriorityModel: enum "COR DSDS Priority Model";
        splitEnabled_gBool: Boolean;

}
