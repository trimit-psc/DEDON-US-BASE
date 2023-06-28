// codeunit partially copied from NAV2018 an changed slightly for BC
/// <summary>
/// <see cref="#TW84"/>
/// </summary>      
codeunit 51017 "Dedon Utils"
{
    procedure HasTracking(sourceType_p: Text; sourceSubtype_p: Text; sourceID_p: Code[20]; sourceRefNo_p: Text; resrvStatus_p: Text; serialNo_p: Code[20]; lotNo_p: Code[20]) hasTracking_out: Boolean
    var
        resrvEntry_l: Record "Reservation Entry";
    begin
        resrvEntry_l.RESET;
        resrvEntry_l.SETCURRENTKEY("Source ID",
                                   "Source Ref. No.",
                                   "Source Type",
                                   "Source Subtype",
                                   "Source Batch Name",
                                   "Source Prod. Order Line",
                                   "Reservation Status",
                                   "Shipment Date",
                                   "Expected Receipt Date");

        resrvEntry_l.SETFILTER("Source Type", sourceType_p);
        resrvEntry_l.SETFILTER("Source Subtype", sourceSubtype_p);
        resrvEntry_l.SETFILTER("Source ID", sourceID_p);
        resrvEntry_l.SETFILTER("Source Ref. No.", sourceRefNo_p);
        resrvEntry_l.SETFILTER("Reservation Status", resrvStatus_p);
        resrvEntry_l.SETFILTER("Serial No.", serialNo_p);
        resrvEntry_l.SETFILTER("Lot No.", lotNo_p);
        hasTracking_out := NOT resrvEntry_l.ISEMPTY;
    end;

    procedure CreateUpdateReservationEntry(sourceType_p: Integer; sourceSubtype_p: Integer; sourceID_p: Code[20]; sourceRefNo_p: Integer; positive_p: Boolean; reservationStatus_p: Integer; itemNo_p: Code[20]; VariantCode_p: Code[10]; locationCode_p: Code[10]; lotNo_p: Code[20]; serialNo_p: Code[20]; qty_p: Decimal; qtyBase_p: Decimal; exporationDate_p: Date; importEntryNo_p: Integer) entryNo_out: Integer
    var
        resEntry_l: Record "Reservation Entry";
        dedonUtils_l: Codeunit "Dedon Utils";
        entryNo_l: Integer;
    begin
        resEntry_l.RESET;
        resEntry_l.SETRANGE("Source Type", sourceType_p);
        resEntry_l.SETRANGE("Source Subtype", sourceSubtype_p);
        resEntry_l.SETRANGE("Source ID", sourceID_p);
        resEntry_l.SETRANGE("Source Ref. No.", sourceRefNo_p);
        resEntry_l.SETRANGE(Positive, positive_p);
        resEntry_l.SETRANGE("Reservation Status", reservationStatus_p);
        resEntry_l.SETRANGE("Item No.", itemNo_p);
        resEntry_l.SETRANGE("Variant Code", VariantCode_p);
        resEntry_l.SETRANGE("Lot No.", lotNo_p);
        resEntry_l.SETRANGE("Location Code", locationCode_p);
        IF NOT resEntry_l.FINDFIRST THEN BEGIN
            entryNo_l := dedonUtils_l.GetLastReservationEntryNo();

            resEntry_l.INIT;
            resEntry_l."Entry No." := entryNo_l + 1;
            resEntry_l.Positive := positive_p;
            resEntry_l."Source Type" := sourceType_p;
            resEntry_l."Source Subtype" := sourceSubtype_p;
            resEntry_l."Source ID" := sourceID_p;
            resEntry_l."Source Ref. No." := sourceRefNo_p;
            resEntry_l."Reservation Status" := reservationStatus_p;
            resEntry_l."Item No." := itemNo_p;
            resEntry_l."Variant Code" := VariantCode_p;
            resEntry_l."Location Code" := locationCode_p;
            resEntry_l."Lot No." := lotNo_p;
            resEntry_l."Serial No." := serialNo_p;
            resEntry_l."Created By" := USERID;
            resEntry_l."Creation Date" := TODAY;
            // field not available yet: resEntry_l."JH. Import Entry No." := importEntryNo_p;
            resEntry_l.INSERT();
        END;

        resEntry_l."Changed By" := USERID;
        resEntry_l."Quantity (Base)" += -qtyBase_p;
        resEntry_l."Qty. to Handle (Base)" += -qtyBase_p;
        resEntry_l."Qty. to Invoice (Base)" += -qtyBase_p;
        resEntry_l.Quantity += -qty_p;

        IF lotNo_p <> '' THEN
            resEntry_l."Item Tracking" := resEntry_l."Item Tracking"::"Lot No.";

        IF serialNo_p <> '' THEN
            resEntry_l."Item Tracking" := resEntry_l."Item Tracking"::"Serial No.";

        IF (serialNo_p <> '') AND (lotNo_p <> '') THEN
            resEntry_l."Item Tracking" := resEntry_l."Item Tracking"::"Lot and Serial No.";


        resEntry_l.MODIFY();

        entryNo_out := resEntry_l."Entry No.";
    end;

    procedure GetLastReservationEntryNo() entryNo_out: Integer
    var
        reservEntry_l: Record "Reservation Entry";
    begin
        reservEntry_l.RESET;
        reservEntry_l.LOCKTABLE();
        IF NOT reservEntry_l.FINDLAST THEN
            EXIT;

        entryNo_out := reservEntry_l."Entry No.";
    end;

    procedure CalcQtyToUOM(itemNo_p: Code[20]; fromUnitOfMeasureCode_p: Code[10]; toUnitOfMeasureCode_p: Code[10]; qty_p: Decimal) newQty_out: Decimal
    var
        fromIUOM: Record "Item Unit of Measure";
        toIUOM: Record "Item Unit of Measure";
    begin
        IF NOT fromIUOM.GET(itemNo_p, fromUnitOfMeasureCode_p) THEN
            EXIT;

        IF NOT toIUOM.GET(itemNo_p, toUnitOfMeasureCode_p) THEN
            EXIT;

        newQty_out := qty_p * fromIUOM."Qty. per Unit of Measure" / toIUOM."Qty. per Unit of Measure";
    end;

    // sucht zu einer bestimmten Chargennummer die Menge, die bewegt werden kann
    procedure CalcResrvQtyToHandleBase(sourceType_p: Text; sourceSubtype_p: Text; sourceID_p: Text; sourceRefNo_p: Text; lotNo_p: Text; serialNo_p: Text; resrvStatus_p: Text; itemNo_p: Text; locationCode_p: Text; positive_p: Boolean) resrvQty_out: Decimal
    var
        resrvEntry_l: Record "Reservation Entry";
    begin
        resrvEntry_l.RESET;
        resrvEntry_l.SETCURRENTKEY("Source ID",
                                   "Source Ref. No.",
                                   "Source Type",
                                   "Source Subtype",
                                   "Source Batch Name",
                                   "Source Prod. Order Line",
                                   "Reservation Status",
                                   "Shipment Date",
                                   "Expected Receipt Date");

        resrvEntry_l.SETFILTER("Source Type", sourceType_p);
        resrvEntry_l.SETFILTER("Source Subtype", sourceSubtype_p);
        resrvEntry_l.SETFILTER("Source ID", sourceID_p);
        resrvEntry_l.SETFILTER("Source Ref. No.", sourceRefNo_p);
        resrvEntry_l.SETFILTER("Reservation Status", resrvStatus_p);
        resrvEntry_l.SETFILTER("Serial No.", serialNo_p);
        resrvEntry_l.SETFILTER("Lot No.", lotNo_p);
        resrvEntry_l.SETFILTER("Location Code", locationCode_p);
        resrvEntry_l.SETFILTER("Item No.", itemNo_p);
        resrvEntry_l.setrange(Positive, positive_p);
        resrvEntry_l.CALCSUMS("Qty. to Handle (Base)");
        resrvQty_out := -resrvEntry_l."Qty. to Handle (Base)";
    end;
}