tableextension 51030 "DDN Container" extends "trm Container"
{

    fields
    {

        modify("Original Expected Receipt Date")
        {
            // Workaround weil Translations hier nicht greifen
            CaptionML = ENU = 'Original Expected Receipt Date', DEU = 'ursprünglich geplantes Wareneingangsdatum';
        }
        modify("Expected Receipt Date")
        {
            // Workaround weil Translations hier nicht greifen
            CaptionML = ENU = 'Expected Receipt Date', DEU = 'geplantes Wareneingangsdatum';
        }


        /// <summary>
        /// Gewünschtes Versanddatum
        /// <see cref="#7JRN"/>
        /// </summary>
        field(51000; "DDN Requested Shipment Date"; Date)
        {
            Caption = 'Requested Shipment Date';
            DataClassification = ToBeClassified;

        }
        /// <summary>
        /// Zugesagtes Versanddatum
        /// <see cref="#7JRN"/>
        /// </summary>        
        field(51001; "DDN Estimated Date Ready"; Date)
        {
            Caption = 'Estimated date ready';
            DataClassification = ToBeClassified;
        }
        /// <summary>
        /// Tatsächliches Versanddatum
        /// <see cref="#7JRN"/>
        /// </summary>        
        field(51002; "DDN Effective Shipment Date"; Date)
        {
            Caption = 'effective shipment date';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                Vendor_lRec: Record Vendor;
                // wird lediglich für eine Datumsberechnung genutzt
                // es wird keine Bestellzeile geändert
                purchaseLine_lRec: Record "Purchase Line";
                LocationCode_lCod: Code[20];
                ddnSetup: Record "DDN Setup";
            begin
                Testfield("Filter Vendor/Customer");
                purchaseLine_lRec.setrange("trm Container No.", Rec."No.");
                purchaseLine_lRec.setfilter("Location Code", '<>''''');
                purchaseLine_lRec.SetLoadFields("Location Code");
                if purchaseLine_lRec.FindFirst() then begin
                    LocationCode_lCod := purchaseLine_lRec."Location Code"
                end
                else begin
                    ddnSetup.get();
                    LocationCode_lCod := ddnSetup."Location Code 1_WMS";
                end;
                //Vendor_lRec.get("Filter Vendor/Customer");
                //Vendor_lRec.TestField("COR-DDN Transit Periode");
                //Rec."Update Receipt Date" := calcdate(Vendor_lRec."COR-DDN Transit Periode", Rec."DDN Effective Shipment Date");
                //es soll der Dedon-Kalender berücksichtigt werden

                Rec."Update Receipt Date" := purchaseLine_lRec.CalcPlannedRecieptDate(Rec."DDN Effective Shipment Date", rec."Filter Vendor/Customer", LocationCode_lCod);
            end;
        }
    }

    /// <summary>
    /// Bestimmt, ob ein Container im Report "schwimmende Ware" aufgeführt werden muss oder nicht
    /// <see cref="Q84K"/>
    /// </summary>
    procedure InTransitOnShip() inTransit_RetBool: Boolean
    var
        Workflow_lRec: Record "trm Workflow";
    begin
        exit(Rec."Status Code" = 'ONBOARD');

        // Idee: Lösung via Workflow-Zeilen mit enem bestimmten Statuscode
        Workflow_lRec.setrange(TableNo, Database::"trm Container");
        Workflow_lRec.setrange(RecordID, Rec.RecordId);
        Workflow_lRec.setrange("Assign Status Code", 'ONBOARD');
        // Wenn keine Workflow-Zeilen "ONBOARD" vorhanden sind dann gilt ein Container nicht
        if Workflow_lRec.IsEmpty then
            exit(false);

        // Wenn alle Zeilen geschlossen wurden dann ist der Container nicht mehr auf Wasser
        Workflow_lRec.SetRange(Closed, false);
        exit(not Workflow_lRec.isempty);
    end;

    procedure GetTransitIcon(): Text[1]
    var
        myInt: Integer;
    begin
        if InTransitOnShip() then
            exit('⛴');
    end;
}
