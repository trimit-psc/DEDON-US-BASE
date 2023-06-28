codeunit 51010 "DDN Purch Post"
{
    Permissions = tabledata "Item Ledger Entry" = rm, tabledata "Value Entry" = rm;
    /// <summary>
    /// Containernummer an Posten weiterreichen
    /// <see cref="#7JRN"/>
    /// </summary>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterFinalizePostingOnBeforeCommit', '', false, false)]
    local procedure DDNPurchPostOnAfterFinalizePostingOnBeforeCommit(var PurchHeader: Record "Purchase Header"; var PurchRcptHeader: Record "Purch. Rcpt. Header"; var PurchInvHeader: Record "Purch. Inv. Header"; var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; var ReturnShptHeader: Record "Return Shipment Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PreviewMode: Boolean; CommitIsSupressed: Boolean; EverythingInvoiced: Boolean)
    var
        ValueEntry_lRec: Record "Value Entry";
        purchInvoiceLine_lRec: Record "Purch. Inv. Line";
        purchCrMemoLine_lRec: Record "Purch. Cr. Memo Line";
        purchRcptLine_lRec: Record "Purch. Rcpt. Line";
    begin
        ValueEntry_lRec.SetLoadFields("Document Type", "Document No.", "Document Line No.");

        if PurchRcptHeader."No." <> '' then begin
            ValueEntry_lRec.SetRange("Document Type", ValueEntry_lRec."Document Type"::"Sales Shipment");
            ValueEntry_lRec.SetRange("Document No.", PurchRcptHeader."No.");
            if ValueEntry_lRec.findset then begin
                purchRcptLine_lRec.SetLoadFields("trm Container No.");
                repeat
                    if purchRcptLine_lRec.get(PurchRcptHeader."No.", ValueEntry_lRec."Document Line No.") then begin
                        assingContainerToValueEntryAndLedgerEntry(ValueEntry_lRec, purchRcptLine_lRec."trm Container No.");
                    end;
                until ValueEntry_lRec.next = 0;
            end;
        end;

        if (PurchInvHeader."No." <> '') then begin
            ValueEntry_lRec.SetRange("Document Type", ValueEntry_lRec."Document Type"::"Sales Invoice");
            ValueEntry_lRec.SetRange("Document No.", PurchInvHeader."No.");
            if ValueEntry_lRec.findset then begin
                purchInvoiceLine_lRec.SetLoadFields("trm Container No.");
                repeat
                    if purchInvoiceLine_lRec.get(PurchInvHeader."No.", ValueEntry_lRec."Document Line No.") then begin
                        assingContainerToValueEntryAndLedgerEntry(ValueEntry_lRec, purchInvoiceLine_lRec."trm Container No.");
                    end;
                until ValueEntry_lRec.next = 0;
            end;
        end;
    end;

    /// <summary>
    /// Containernummer an Posten weiterreichen
    /// <see cref="#7JRN"/>
    /// </summary>
    procedure assingContainerToValueEntryAndLedgerEntry(var ValueEntry_viRec: Record "Value Entry"; ContainerNo_iCod: code[20])
    var
        ItemLedgerEntry_lRec: Record "Item Ledger Entry";
        container_lRec: Record "trm Container";
        containererID_lCod: Code[20];
    begin
        if ContainerNo_iCod = '' then
            exit;
        if container_lRec.get(ContainerNo_iCod) then
            containererID_lCod := container_lRec."Container ID";
        ValueEntry_viRec."DDN Container No." := ContainerNo_iCod;
        ValueEntry_viRec."DDN Container ID" := containererID_lCod;
        ValueEntry_viRec.Modify(false);
        if ValueEntry_viRec."Item Ledger Entry No." <> 0 then begin
            if ItemLedgerEntry_lRec.get(ValueEntry_viRec."Item Ledger Entry No.") then begin
                ItemLedgerEntry_lRec."DDN Container No." := ContainerNo_iCod;
                ItemLedgerEntry_lRec."DDN Container ID" := containererID_lCod;
                ItemLedgerEntry_lRec.Modify(false);
            end;
        end;
    end;
}
