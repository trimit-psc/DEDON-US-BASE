pageextension 51013 "DDN Purchase Order Subform" extends "Purchase Order Subform" //54
{
    layout
    {
        addafter("No.")
        {
            /// <summary>
            /// <see cref="#1Z54"/>
            /// </summary>     
            field("Item No. 2"; Rec."Item No. 2")
            {
                ApplicationArea = All;
                Visible = false;
            }

            /// <summary>
            /// <see cref="#1Z54"/>
            /// </summary>                 
            field("Item Search Description"; Rec."Item Search Description")
            {
                ApplicationArea = All;
                Width = 50;
            }
            field("COR-DDN Legacy System Item No."; Rec."COR-DDN Legacy System Item No.")
            {
                ApplicationArea = All;
            }


            /// <summary>
            /// <see cref="#V5MQ"/>
            /// </summary>    
            field("DDN Item Planning Status Code"; Rec."DDN Item Planning Status Code")
            {
                ApplicationArea = All;
            }
        }
        addafter("Order Date")
        {
            /// <summary>
            /// <see cref="#7JRN"/>
            /// </summary>
            field("DDN Effective Shipment Date"; Rec."DDN Effective Shipment Date")
            {
                ApplicationArea = All;
                ToolTip = 'real date of delivery';
            }
            /// <summary>
            /// <see cref="#7JRN"/>
            /// </summary>            
            field("DDN Estimated Date Ready"; Rec."DDN Estimated Date Ready")
            {
                ApplicationArea = All;
                ToolTip = 'Estimated date that the Vendor communicated to us';
            }
            /// <summary>
            /// <see cref="#7JRN"/>
            /// </summary>            
            field("DDN Requested Shipment Date"; Rec."DDN Requested Shipment Date")
            {
                ApplicationArea = All;
                ToolTip = 'Requested by us';
            }
            field("Special Order"; Rec."Special Order")
            {
                ApplicationArea = All;
            }
            field("Special Order Sales No."; Rec."Special Order Sales No.")
            {
                ApplicationArea = All;
            }
            field("Special Order Sales Line No."; Rec."Special Order Sales Line No.")
            {
                ApplicationArea = All;
            }
        }
        addafter(Quantity)
        {
            /// <summary>
            /// <see cref="#6SWK"/>
            /// </summary>
            field("DDN Original Qty."; Rec."DDN Original Qty.")
            {
                ApplicationArea = All;
            }
        }
        modify("trm Container No.")
        {
            Visible = true;
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
                    Rec.TestField(type, Rec.type::Item);
                    item_lRec.get(Rec."No.");
                    ItemAvailFormsMgt.ShowItemAvailFromItem(Item_lRec, ItemAvailFormsMgt.ByEvent);
                end;
            }
        }
    }
}
