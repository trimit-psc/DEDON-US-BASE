pageextension 51047 "COR-DDN Transfer Order" extends "Transfer Order"
{
    layout
    {

        addLast(General)
        {

            field("COR-DDN Comment"; Rec."COR-DDN Comment")
            {
                ApplicationArea = All;
                AssistEdit = true;

                trigger OnAssistEdit()
                var
                    InventoryCommentLine: Record "Inventory Comment Line";
                begin
                    InventoryCommentLine.setrange("Document Type", InventoryCommentLine."Document Type"::"Transfer Order");
                    InventoryCommentLine.setrange("No.", Rec."No.");
                    Page.Run(Page::"Inventory Comment Sheet", InventoryCommentLine);
                end;
            }
        }
    }
}
