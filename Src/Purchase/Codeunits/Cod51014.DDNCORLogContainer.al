/// <summary>
/// <see cref="#Q84K"/>
/// </summary>
codeunit 51014 "COR-DDN Log Container"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        logPurchaseContainerLines(false);
    end;

    procedure logPurchaseContainerLines(verbose: Boolean)
    var
        Container_lRec: Record "trm Container";
        historyHeader_lRec: Record "COR-DDN Container Hist. Header";
        historyLine_lRec: Record "COR-DDN Container Hist. Line";
        PurchaseLine: Record "Purchase Line";
        HistoryId: Integer;
        PurchaseHeader_lRec: Record "Purchase Header";
        countLines_lInt: Integer;
        linesCreated_lLbl: Label '%1 lines have been logged.';
    begin
        Container_lRec.SetRange(Type, Container_lRec.Type::Inbound);
        if not Container_lRec.findset then
            exit;
        repeat
            PurchaseLine.setrange("trm Container No.", Container_lRec."No.");
            if PurchaseLine.findset then begin
                PurchaseHeader_lRec.get(PurchaseLine."Document Type", PurchaseLine."Document No.");
                if HistoryId = 0 then begin
                    historyHeader_lRec.insert(true);
                    HistoryId := historyHeader_lRec.id;
                end;
                repeat
                    historyLine_lRec."Container History Id" := HistoryId;
                    historyLine_lRec."Amount (LCY)" := PurchaseLine."Line Amount";
                    historyLine_lRec."Container ID" := Container_lRec."Container ID";
                    historyLine_lRec."Container No." := PurchaseLine."trm Container No.";
                    historyLine_lRec."Document No." := PurchaseLine."Document No.";
                    historyLine_lRec."Document Type" := PurchaseLine."Document Type";
                    historyLine_lRec."Estimated time of arrival" := PurchaseLine."Planned Receipt Date";
                    historyLine_lRec."Estimated time of departure" := PurchaseLine."DDN Effective Shipment Date";
                    historyLine_lRec."Gen. Product Posting Group" := PurchaseLine."Gen. Prod. Posting Group";
                    historyLine_lRec."Item Description" := PurchaseLine.Description;
                    historyLine_lRec."Item Description 2" := PurchaseLine."Description 2";
                    historyLine_lRec."Item No." := PurchaseLine."No.";
                    historyLine_lRec."Master No." := PurchaseLine."trm Master No.";
                    historyLine_lRec."Line No." := PurchaseLine."Line No.";
                    historyLine_lRec.Quantity := PurchaseLine."Outstanding Quantity";
                    historyLine_lRec."Quantity (Base)" := PurchaseLine."Outstanding Qty. (Base)";
                    historyLine_lRec."Shipment Method" := PurchaseHeader_lRec."Shipment Method Code";
                    historyLine_lRec.Status := Container_lRec.Status;
                    historyLine_lRec."VAT Product Posting Group" := PurchaseLine."VAT Prod. Posting Group";
                    historyLine_lRec."Vendor No." := PurchaseLine."Buy-from Vendor No.";
                    historyLine_lRec."Vendor Posting Group" := PurchaseLine."Gen. Bus. Posting Group";
                    historyLine_lRec.insert();
                    countLines_lInt += 1;
                until PurchaseLine.Next() = 0;
            end;
        until Container_lRec.next = 0;

        if verbose then
            message(linesCreated_lLbl, countLines_lInt);
    end;
}
