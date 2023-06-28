pageextension 51041 "COR-DDN Sales Quote Subfrom" extends "Sales Quote Subform"
{
    layout
    {
        addafter(Quantity)
        {
            field("COR-DDN erliest Shipment Date"; Rec."COR-DDN earliest Shipment Date")
            {
                ApplicationArea = All;
            }
            /// <summary>
            /// Ausgeblendet weil das Angebot auf Komponenten-Ebene arbeiten wird
            /// Komponenten selbst tragen normalerweise keine Instock-Information
            /// </summary>
            field("COR-DDN Instock-Info"; InstockHint)
            {
                width = 20;
                Editable = false;
                Caption = 'Instock Information';
                Visible = false;
            }
        }
        addafter("Description 2")
        {
            /// <summary>
            /// <see cref="#DM4X"/>
            /// </summary>
            field("DDN Set Item No."; Rec."DDN Set Item No.")
            {
                ApplicationArea = All;
            }
            field("COR-DDN Item No."; Rec."COR-DDN Item No.")
            {
                ApplicationArea = All;
            }
            field("COR-DDN Legacy System Item No."; Rec."COR-DDN Legacy System Item No.")
            {
                ApplicationArea = All;
            }


            /// <summary>
            /// <see cref="#1QA2"/>
            /// </summary>
            field(FabricConsumption_gText; FabricConsumption_gText)
            {
                Caption = 'Fabric Consumption';
                ApplicationArea = all;
                Editable = false;
            }
            /// <summary>
            /// <see cref="#1QA2"/>
            /// </summary>            
            field(FabricConsumptionTotal_gText; FabricConsumptionTotal_gText)
            {
                Caption = 'Fabric Consumption Total';
                ApplicationArea = all;
                Editable = false;
            }
            /// <summary>
            /// <see cref="#M92Y"/>
            /// </summary>
            field("DDN Item Planning Status Code"; Rec."DDN Item Planning Status Code")
            {
                ApplicationArea = all;
            }
        }

        addafter("Line Discount %")
        {
            field("trm Freeze Line Discount"; Rec."trm Freeze Line Discount")
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        // #DSDS
        addlast("Item Availability by")
        {
            action("COR open DSDS Schedule")
            {
                ApplicationArea = All;
                Image = ItemAvailability;
                Caption = 'DSDS Schedule';
                Enabled = Rec.Type = rec.Type::Item;

                trigger OnAction()
                var
                    dsdsAvailitbilityMgmt_lCodeUnit: Codeunit "COR DSDS Availibility Mgmt.";
                    Schedule_lPage: Page "COR DSDS Schedule Line";
                begin
                    Schedule_lPage.SetContext(Rec);
                    Schedule_lPage.Run();
                end;
            }

            action("COR calc earliest Shipment Date via DSDS Schedule")
            {
                ApplicationArea = All;
                Image = ChangeDate;
                Caption = 'Calculate earliest shipment date via DSDS';
                ToolTip = 'Calculates the earliest Shipment date based on the DSDS. If your sales line has not yet a priority then your priority is calculated before.';
                Enabled = Rec.Type = rec.Type::Item;

                trigger OnAction()
                var
                    dsdsAvailitbilityMgmt_lCodeUnit: Codeunit "COR DSDS Availibility Mgmt.";
                    Schedule_lPage: Page "COR DSDS Schedule Line";
                begin
                    Rec.TestField(type, rec.type::item);
                    dsdsAvailitbilityMgmt_lCodeUnit.InitObject(Rec."No.", rec."Location Code");
                    dsdsAvailitbilityMgmt_lCodeUnit.SetFocusOnSalesLine(Rec);
                    dsdsAvailitbilityMgmt_lCodeUnit.QueueUnpriorisedSalesLine(Rec, true);
                    dsdsAvailitbilityMgmt_lCodeUnit.createSchedule();
                    Rec."COR-DDN earliest Shipment Date" := dsdsAvailitbilityMgmt_lCodeUnit.FindEarliestShipmentDateForSalesLine(Rec, true);
                end;
            }

        }
        addafter("Event")
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
        addlast(trmLineDiscountCombGroup)
        {
            action("COR-DDN DeleteDiscountCombinations")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Delete Discount Combination';
                Image = DeactivateDiscounts;
                ToolTip = 'Deletes the discount combination for the currently selected line and sets the line discount ot zero.';

                trigger OnAction()
                var
                begin
                    Rec.VanishLineDiscounts();
                end;
            }
        }


    }
    var
        InstockHint: Text;
        FabricConsumption_gText: Text;
        FabricConsumptionTotal_gText: Text;

    trigger OnAfterGetRecord()
    var
        fabricsEnabled_lBool: Boolean;
        Desginer_lText: Text;
        DDNItemAndMasterDetails_lCod: Codeunit "DDN Item and Master Details";
        Color_gText: Text;
    begin
        calcInstockHint();
        DDNItemAndMasterDetails_lCod.getItemDetails(Rec, FabricConsumption_gText, FabricConsumptionTotal_gText, fabricsEnabled_lBool, Desginer_lText, Color_gText, false)
    end;

    local procedure calcInstockHint()
    var
        InstockMgmt: Codeunit "COR-DDN Instock Delegator";
    begin
        clear(InstockHint);
        if Rec.Type <> rec.Type::Item then
            exit;
        InstockHint := InstockMgmt.CalcInstockAvailibilityHint(Rec."No.", false);
    end;
}
