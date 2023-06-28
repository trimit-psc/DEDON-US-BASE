pageextension 51044 "COR-DDN Transfer Order Subform" extends "Transfer Order Subform"
{
    layout
    {
        addlast(Control1)
        {

            field("Qty. in Transit"; Rec."Qty. in Transit")
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        addafter("Item Availability by")
        {
            action("COR-DDN AvailibilityByEventViaItem")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Event';
                Image = "Event";
                ToolTip = 'View how the actual and the projected available balance of an item will develop over time according to supply and demand events.';

                trigger OnAction()
                var
                    item_lRec: Record item;
                    ItemAvailFormsMgt: Codeunit "Item Availability Forms Mgt";
                begin
                    item_lRec.get(Rec."Item No.");
                    ItemAvailFormsMgt.ShowItemAvailFromItem(Item_lRec, ItemAvailFormsMgt.ByEvent);
                end;
            }
        }
    }
}
