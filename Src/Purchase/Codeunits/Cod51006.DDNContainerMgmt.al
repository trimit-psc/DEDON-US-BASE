codeunit 51006 "DDN Container Mgmt."
{
    /// <summary>
    /// Die Datumswerte, die über den Container geändert werden, vererben sich auf die Bestellzeilen
    /// <see cref="#7JRN"/>
    /// </summary>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"trm Container Management", 'Pf_OnUpdateDateOnPurchaseLine', '', false, false)]
    local procedure trmContainerManagementPf_OnUpdateDateOnPurchaseLine(var purchaseLine_par: Record "Purchase Line"; var container_par: Record "trm Container")
    begin
        if container_par."DDN Estimated Date Ready" <> 0D then
            purchaseLine_par."DDN Estimated Date Ready" := container_par."DDN Estimated Date Ready";
        if container_par."DDN Effective Shipment Date" <> 0D then
            purchaseLine_par."DDN Effective Shipment Date" := container_par."DDN Effective Shipment Date";
        if container_par."DDN Requested Shipment Date" <> 0D then
            purchaseLine_par."DDN Requested Shipment Date" := container_par."DDN Requested Shipment Date";

        // anstelle des erwarteten WA-Datum soll das geplante WA-Datum gesetzt werden
        //if purchaseLine_par."Expected Receipt Date" <> 0D then begin
        //purchaseLine_par.validate("Planned Receipt Date", purchaseLine_par."Expected Receipt Date");
        //end;

        // 08.03.2023 wieder andere BErechnungslogik gewünscht
        // die beiden Felder "DDN Estimated Date Ready" und "DDN Effective Shipment Date" 
        // berechnen zum Zeitpunkt der Validierung das "Planned Receipt Date";
        if container_par."DDN Estimated Date Ready" <> 0D then begin
            //purchaseLine_par.validate("DDN Estimated Date Ready");

        end else
            if container_par."DDN Effective Shipment Date" <> 0D then begin
                //purchaseLine_par.validate("DDN Effective Shipment Date");
            end;

        // Stand 16.03.2023 soll gegen dieses Datum validiert werden
        purchaseLine_par.validate("Planned Receipt Date", container_par."Update Receipt Date");
    end;

    /// <summary>
    /// Methode zum Erstellen von EK-Rechnungen basierend auf einem oder mehreren Containern
    /// <see cref="#Q84K" />
    /// </summary>
    procedure CreateInvoForContainer(var Container_iRec: Record "trm Container")
    var
        pl: record "Purchase Line";
        cu715384096: codeunit 6036669;
        vdm: record "trm vardim Master";
    begin
        //pl."Promised Receipt Date"
        // Prüfung, ob alle Container dem selbigen Kreditor zugehörig sind
    end;

    /*
        [EventSubscriber(ObjectType::Table, DataBASE::"trm Container", 'OnAfterValidateEvent', 'DDN Effective Shipment Date', false, false)]
        local procedure trmContainer_onAfterValidateEffectiveShipmentDate(Rec: Record "trm Container")
        begin
            Rec."Update Receipt Date" := Rec."DDN Effective Shipment Date";
        end;
        */
}
