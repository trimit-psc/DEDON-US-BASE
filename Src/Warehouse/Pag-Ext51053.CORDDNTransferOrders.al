pageextension 51053 "COR-DDN Transfer Orders" extends "Transfer Orders"
{
    layout
    {
        addlast(Control1)
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
