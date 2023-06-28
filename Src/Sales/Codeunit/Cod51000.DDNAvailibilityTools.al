codeunit 51000 "DDN Availibility Tools"
{
    /// <summary>
    /// Einstiegspunkt um die Verfügbarkeitskennzeichen und Bearbeitungshinweise zu errechnen.
    /// <see cref="#D5C7"/>
    /// </summary>
    /// <param name="SalesLine_vRec">Verkaufszeile zu der die Verfügbarkeitskennzeichen zu errrechnen sind</param>
    procedure CalcAvailibilityObsolete_gFnc(var SalesLine_vRec: Record "Sales Line"; doUpdateLastCalcDate_pBool: boolean) hasBeenModified_r: Boolean
    var
        xSalesLine_lRec: Record "Sales Line";
        ddnSetup: Record "DDN Setup";
    begin
        xSalesLine_lRec.Copy(SalesLine_vRec);

        //SalesLine_vRec.RecalcEarliestShipmentDate_gFnc(doUpdateLastCalcDate_pBool);
        SalesLine_vRec.CalculateDedonEarliestShipmentDateObsolete(doUpdateLastCalcDate_pBool);

        //CalcProcessingHint_lFnc(SalesLine_vRec);
        CalcDelayedFlag_lFnc(SalesLine_vRec);

        ddnSetup.get();
        if (xSalesLine_lRec."DDN Processing Hint" <> SalesLine_vRec."DDN Processing Hint")
        or (xSalesLine_lRec."DDN Shipment Delayed" <> SalesLine_vRec."DDN Shipment Delayed")
        or (xSalesLine_lRec."COR-DDN earliest Shipment Date" <> SalesLine_vRec."COR-DDN earliest Shipment Date")
        or ddnSetup."Force Avail. Sales Line Modify" then begin
            // Handlungsanweisung für Benutzer generieren, bzw. Datensatz so markieren, dass er als "ToDo" angesehen wird.
            // Das nächst mögliche Datum hat sich nach hinten verschoeben

            // Das WA-Datum liegt hinter dem frühst möglichen WA-Datum. Also ist eigentlich nichts zu tun.
            if SalesLine_vRec."Shipment Date" >= SalesLine_vRec."COR-DDN earliest Shipment Date" then begin
                case xSalesLine_lRec."DDN-COR Date Conflict Action" of
                    SalesLine_vRec."DDN-COR Date Conflict Action"::DateConflictExists:
                        SalesLine_vRec."DDN-COR Date Conflict Action" := SalesLine_vRec."DDN-COR Date Conflict Action"::" ";
                    SalesLine_vRec."DDN-COR Date Conflict Action"::DateConflictPostponed:
                        SalesLine_vRec."DDN-COR Date Conflict Action" := SalesLine_vRec."DDN-COR Date Conflict Action"::" ";
                    SalesLine_vRec."DDN-COR Date Conflict Action"::" ":
                        SalesLine_vRec."DDN-COR Date Conflict Action" := SalesLine_vRec."DDN-COR Date Conflict Action"::" ";
                    SalesLine_vRec."DDN-COR Date Conflict Action"::DateConflictSolved:
                        SalesLine_vRec."DDN-COR Date Conflict Action" := SalesLine_vRec."DDN-COR Date Conflict Action"::" ";
                end;
            end
            // hier ist ein Datumskonflikt erkannt wordern
            else begin
                case xSalesLine_lRec."DDN-COR Date Conflict Action" of
                    SalesLine_vRec."DDN-COR Date Conflict Action"::DateConflictExists:
                        SalesLine_vRec."DDN-COR Date Conflict Action" := SalesLine_vRec."DDN-COR Date Conflict Action"::DateConflictExists;
                    SalesLine_vRec."DDN-COR Date Conflict Action"::DateConflictPostponed:
                        SalesLine_vRec."DDN-COR Date Conflict Action" := SalesLine_vRec."DDN-COR Date Conflict Action"::DateConflictPostponed;
                    SalesLine_vRec."DDN-COR Date Conflict Action"::" ":
                        SalesLine_vRec."DDN-COR Date Conflict Action" := SalesLine_vRec."DDN-COR Date Conflict Action"::DateConflictExists;
                    SalesLine_vRec."DDN-COR Date Conflict Action"::DateConflictSolved:
                        SalesLine_vRec."DDN-COR Date Conflict Action" := SalesLine_vRec."DDN-COR Date Conflict Action"::DateConflictExists;
                end;
            end;
            SalesLine_vRec.Modify(false);
            hasBeenModified_r := true;
        end;
    end;

    /// <summary>
    /// Errechnet ein Optionfeld, das dem Verantwortlichen Hinweise darüber gibt, in wie weit der Lagerbestand eines
    /// Artikels kritisch ist. Auf <paramref name="SalesLine_ivRec"/> wird kein <c>modify()</c> ausgeführt.
    /// <see cref="#D5C7"/> 
    /// </summary>
    /// <param name="SalesLine_ivRec"></param>
    local procedure CalcProcessingHint_lFnc(var SalesLine_ivRec: Record "Sales Line")
    var
        item_lRec: Record Item;
    begin
        if SalesLine_ivRec.Type = SalesLine_ivRec.Type::Item then begin
            if not item_lRec.get(SalesLine_ivRec."No.") then
                exit;
            item_lRec.SetRange("Location Filter", SalesLine_ivRec."Location Code");
            item_lRec.CalcFields(Inventory);
            if item_lRec.Inventory <= 0 then
                SalesLine_ivRec."DDN Processing Hint" := SalesLine_ivRec."DDN Processing Hint"::OutOfStock
            else begin
                if SalesLine_ivRec."COR-DDN Earliest Shipment Date" <= WorkDate() then begin
                    if SalesLine_ivRec."Outstanding Quantity" > item_lRec.Inventory then
                        SalesLine_ivRec."DDN Processing Hint" := SalesLine_ivRec."DDN Processing Hint"::StockCritical
                    else begin
                        // hier kann eine Konkurrenz vorliegen falls in Summe über alle Aufträge mehr Bedarf besteht; aber ein Auftrag bedienbar wäre
                        // wird bei Neuterminierung errechnet
                        if SalesLine_ivRec."DDN Processing Hint" <> SalesLine_ivRec."DDN Processing Hint"::sameDayConflict then
                            SalesLine_ivRec."DDN Processing Hint" := SalesLine_ivRec."DDN Processing Hint"::OnStock
                    end;
                end
                else begin
                    SalesLine_ivRec."DDN Processing Hint" := SalesLine_ivRec."DDN Processing Hint"::OutOfStock;
                end;
            end;
        end
        else begin
            clear(SalesLine_ivRec."DDN Processing Hint");
        end;
        // errechnet das Icon auf der VK-Zeile
        SalesLine_ivRec.Validate("DDN Processing Hint");
    end;


    /// <summary>
    /// Errechnet ein Kennzeichen basierend auf dem Warenausgangsdatum und dem von Trimit
    /// errechneten frühesten Warenausgangsdatum um die VK-Zeile zu kennzeichnen
    /// <see cref="#D5C7"/> 
    /// </summary>
    /// <param name="SalesLine_viRec"></param>
    local procedure CalcDelayedFlag_lFnc(var SalesLine_viRec: Record "Sales Line")
    var

    begin
        //SalesLine_viRec."DDN Shipment Delayed" := SalesLine_viRec."Shipment Date" < SalesLine_viRec."trm Earliest Shipment Date";
        if SalesLine_viRec."Shipment Date" < SalesLine_viRec."COR-DDN Earliest Shipment Date" then begin
            SalesLine_viRec."DDN Shipment Delayed" := true;
        end
        else begin
            if SalesLine_viRec."Shipment Date" < WorkDate() then begin
                SalesLine_viRec."DDN Shipment Delayed" := true;
            end
        end;
        // SalesLine_viRec."DDN Shipment Delayed" := SalesLine_viRec."Shipment Date" < SalesLine_viRec."COR-DDN Earliest Shipment Date";
    end;

    /// <summary>
    /// Wird vom Vekraufsauftrag aus aufgerufen
    /// </summary>
    /// <param name="SalesLineSelected_lRec"></param>
    procedure calculateEarliesShipmentDate(var SalesLineSelected_lRec: Record "Sales Line")
    var
        NoSelected_lInt: Integer;
        Act_lInt: Integer;
        Status_gDlg: Dialog;
        Status_lLbl: Label '#1#######################', Locked = true;
    begin
        NoSelected_lInt := SalesLineSelected_lRec.Count;
        Status_gDlg.Open(Status_lLbl);

        if SalesLineSelected_lRec.FindSet(true, false) then
            repeat
                Act_lInt += 1;
                Status_gDlg.Update(1, SalesLineSelected_lRec."Line No.");
                //SalesLineSelected_lRec.RecalcEarliestShipmentDate_gFnc(false);
                //SalesLineSelected_lRec.Modify(true);
                CalcAvailibilityObsolete_gFnc(SalesLineSelected_lRec, false);
            until SalesLineSelected_lRec.Next() = 0;

        Status_gDlg.Close();
    end;

    procedure TransferEaliestShipmentDateToShipmentDate(var SalesLineSelected_lRec: Record "Sales Line")
    var
        NoSelected_lInt: Integer;
        Act_lInt: Integer;
        Status_gDlg: Dialog;
        Status_lLbl: Label '#1#######################', Locked = true;
    begin
        NoSelected_lInt := SalesLineSelected_lRec.Count;
        Status_gDlg.Open(Status_lLbl);

        if SalesLineSelected_lRec.FindSet(true, false) then
            repeat
                Act_lInt += 1;
                Status_gDlg.Update(1, strsubstno('%1-%2', SalesLineSelected_lRec."Document No.", SalesLineSelected_lRec."Line No."));
                SalesLineSelected_lRec.TransferEaliestShipmentDateToShipmentDate_gFnc();
                SalesLineSelected_lRec."DDN-COR Date Conflict Action" := SalesLineSelected_lRec."DDN-COR Date Conflict Action"::DateConflictSolved;
                SalesLineSelected_lRec.Modify(true);
            until SalesLineSelected_lRec.Next() = 0;

        Status_gDlg.Close();
    end;


}