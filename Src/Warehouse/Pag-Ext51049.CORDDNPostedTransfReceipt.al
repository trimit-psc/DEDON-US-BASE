pageextension 51049 "COR-DDN Posted Transf. Receipt" extends "Posted Transfer Receipt"
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
                    InventoryCommentLine.setrange("Document Type", InventoryCommentLine."Document Type"::"Posted Transfer Receipt");
                    InventoryCommentLine.setrange("No.", Rec."No.");
                    Page.Run(Page::"Inventory Comment Sheet", InventoryCommentLine);
                end;
            }
        }
    }
}
