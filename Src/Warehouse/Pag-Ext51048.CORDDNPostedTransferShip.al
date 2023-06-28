pageextension 51048 "COR-DDN Posted Transfer Ship." extends "Posted Transfer Shipment"
{
    layout
    {
        addlast(General)
        {
            field("COR-DDN Comment"; Rec."COR-DDN Comment")
            {
                ApplicationArea = All;
                trigger OnAssistEdit()
                var
                    InventoryCommentLine: Record "Inventory Comment Line";
                begin
                    InventoryCommentLine.setrange("Document Type", InventoryCommentLine."Document Type"::"Posted Transfer Shipment");
                    InventoryCommentLine.setrange("No.", Rec."No.");
                    Page.Run(Page::"Inventory Comment Sheet", InventoryCommentLine);
                end;
            }
        }
    }
}
