pageextension 51002 "Sales Order Subform (DDN)" extends "Sales Order Subform" //46
{
    layout
    {
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
        }
        addafter("Shipment Date")
        {
            field(ProcessingHintIcon; Rec."DDN Processing Hint Icon")
            {
                ApplicationArea = All;
                width = 5;
                StyleExpr = ProcessingHintIconStyleExpr;
                ToolTip = 'Shows an Icon to notify you if shipment is possible accoring to stock and availibility.';
            }
        }
        addafter("Shipment Date")
        {
            /// <summary>
            /// <see cref="#M92Y"/>
            /// </summary>
            field("DDN Order Intake Date"; Rec."DDN Order Intake Date")
            {
                ApplicationArea = All;
            }
        }
        /// <summary>
        /// <see cref="#M92Y"/>
        /// </summary>        
        modify("Shortcut Dimension 1 Code")
        {
            Visible = true;
        }
        /// <summary>
        /// <see cref="#M92Y"/>
        /// </summary>
        modify("Shortcut Dimension 2 Code")
        {
            Visible = true;
        }

        addafter("Drop Shipment")
        {
            /// <summary>
            /// <see cref="#M92Y"/>
            /// </summary>
            field("Purchase Order No."; Rec."Purchase Order No.")
            {
                ApplicationArea = All;
            }

        }
        /// <summary>
        /// <see cref="#NFSX"/>
        /// </summary>
        modify("Special Order")
        {
            Visible = true;
        }
        addafter("Special Order")
        {
            /// <summary>
            /// <see cref="#NFSX"/>
            /// </summary>
            field("Special Order Purchase No."; Rec."Special Order Purchase No.")
            {
                ApplicationArea = all;
            }
            /// <summary>
            /// <see cref="#NFSX"/>
            /// </summary>            
            field("Special Order Purch. Line No."; Rec."Special Order Purch. Line No.")
            {
                ApplicationArea = All;
            }
        }

        /// <summary>
        /// <see cref="#3N8B"/>
        /// </summary>
        modify("trm Earliest Shipment Date")
        {
            Visible = false;
        }

        addafter("trm Earliest Shipment Date")
        {
            field("COR-DDN erliest Shipment Date"; Rec."COR-DDN earliest Shipment Date")
            {
                ApplicationArea = All;
            }
            field("DDN-COR Date Conflict Action"; Rec."DDN-COR Date Conflict Action")
            {
                ApplicationArea = All;
            }

            field("DDN lock Shiment Date"; Rec."DDN lock Shiment Date")
            {
                ApplicationArea = All;
            }
        }

        /// <summary>
        /// <see cref="#M92Y"/>
        /// </summary>
        addfirst(Control1)
        {
            field("DDN Line No."; Rec."Line No.")
            {
                ApplicationArea = All;
            }
        }

        addafter("Description 2")
        {
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


        addlast(Control1)
        {
            field("Country/Region of Origin"; Rec."Country/Region of Origin")
            {
                ApplicationArea = All;
                Style = Strong;
                StyleExpr = Rec."trm Show Bold";
            }
            field("Vendor No."; Rec."Vendor No.")
            {
                ApplicationArea = All;
                Style = Strong;
                StyleExpr = Rec."trm Show Bold";
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
        addlast("O&rder")
        {
            // button copied from NAV2018 and changed slightly for BC
            /// <summary>
            /// <see cref="#TW84"/>
            /// </summary>              
            action("Select Tracking")
            {
                Caption = 'Select Tracking';
                ApplicationArea = All;
                Image = Lot;
                ShortcutKey = "Ctrl+Q";

                trigger OnAction()
                var
                    salesUtils_l: Codeunit "COR-DDN Legacy Sales Utils";
                begin
                    salesUtils_l.ChoseTrackingAndCreateReservationEntriesForSalesLine(Rec);
                end;
            }
        }

        // #DSDS
        addafter("Item Availability by")
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

            action("COR calc earlises Shipment Date via DSDS Schedule")
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
                    NoOutstandingQtyError_lLbl: Label 'Everything has been shipped already. There is nothing to be done for DSDS.';
                begin
                    Rec.TestField(type, rec.type::item);
                    if Rec."Outstanding Qty. (Base)" = 0 then
                        error(NoOutstandingQtyError_lLbl);
                    dsdsAvailitbilityMgmt_lCodeUnit.InitObject(Rec."No.", rec."Location Code");
                    dsdsAvailitbilityMgmt_lCodeUnit.SetFocusOnSalesLine(Rec);
                    dsdsAvailitbilityMgmt_lCodeUnit.QueueUnpriorisedSalesLine(Rec, true);
                    dsdsAvailitbilityMgmt_lCodeUnit.createSchedule();
                    Rec."COR-DDN earliest Shipment Date" := dsdsAvailitbilityMgmt_lCodeUnit.FindEarliestShipmentDateForSalesLine(Rec, true);
                end;
            }
        }
        addafter("<Action3>")
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

        modify(trmEditLineDiscCombinations)
        {
            ShortcutKey = 'Ctrl+r';
        }
        addlast(trmDiscountGroup)
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
        addlast(trmVarDimGroup)
        {
            action("COR-DDN RecalcAdjustmentsOnVarDimOrder")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Recalcuate Adjustments';
                //Image = ;

                trigger OnAction()
                var
                    vdo: record "trm VarDim Order";
                    callEditVarDimOrder_loc: Record "trm Call Edit VarDim Order";
                    varDimOrderHandling_loc: Codeunit "trm VarDim Order Handling";
                begin


                    callEditVarDimOrder_loc.InitOrderTypeStartLevel := callEditVarDimOrder_loc.Initordertypestartlevel::"Sales Line";
                    callEditVarDimOrder_loc.InitDocumentTypeStartLevel := Rec."Document Type";
                    callEditVarDimOrder_loc.InitOrderNoStartLevel := Rec."Document No.";
                    callEditVarDimOrder_loc.InitOrderLineNoStartLevel := Rec."Line No.";
                    callEditVarDimOrder_loc.CalledOnDemand := false;
                    varDimOrderHandling_loc.Set_SalesLine(Rec);
                    varDimOrderHandling_loc.EditVarDimOrder1(callEditVarDimOrder_loc, false);
                    varDimOrderHandling_loc.Get_SalesLine(Rec);

                    // Bei Kissen wird der VK über die Farbkaregorie bestimmt
                    vdo.setrange("Order Type", vdo."Order Type"::"Sales Order");
                    vdo.setrange("Document Type", Rec."Document Type");
                    vdo.setrange("Document Name", Rec."Document No.");
                    vdo.SetRange("Document Line No.", Rec."Line No.");
                    vdo.setfilter("Adjustment Amount Sales", '<>0');
                    if vdo.FindSet() then
                        repeat
                            vdo.Validate("Adjustment Amount Sales");
                            //message('Ich versuche eine Preisanpassung zu setzen.');
                            vdo.modify(true);
                        until vdo.next() = 0;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        DDNSetup_lRec: Record "DDN Setup";
        DDNItemAndMasterDetails_lCod: Codeunit "DDN Item and Master Details";
        fabricsEnabled_lBool: Boolean;
        Desginer_lText: Text;
        Color_gText: Text;
    begin
        ProcessingHintIconStyleExpr := DDNSetup_lRec.GetIconStyle(Rec."DDN Processing Hint Icon");
        // #1QA2
        DDNItemAndMasterDetails_lCod.getItemDetails(Rec, FabricConsumption_gText, FabricConsumptionTotal_gText, fabricsEnabled_lBool, Desginer_lText, Color_gText, false)
    end;

    var
        ProcessingHintIconStyleExpr: Text[20];
        FabricConsumption_gText: Text;
        FabricConsumptionTotal_gText: Text;

}