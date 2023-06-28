/// <summary>
/// PageExtension DDN Item List (ID 51007) extends Record Item List.
/// <see cref="#HR3T"/>
/// </summary>
pageextension 51007 "DDN Item List" extends "Item List"
{
    layout
    {
        addafter("No.")
        {
            /// <see cref="#HR3T"/>
            field("No. 2"; Rec."No. 2")
            {
                ApplicationArea = All;
            }
            // <see cref="#HR3T"/>
            field("DDM Legacy System Item No."; Rec."DDM Legacy System Item No.")
            {
                ApplicationArea = All;
                width = 50;
            }
            field("COR-DDN InstockHint"; InstockHint_gTxt)
            {
                ApplicationArea = all;
                width = 20;
                Caption = 'Instock Information';
                AssistEdit = true;
                ToolTip = 'When you click on the Instock Information then the system will recaluclate the data for the item. Please keep in mind that Instock Information is primary used for furnitures and not for single components.';

                trigger OnAssistEdit()
                var
                begin
                    refrestInstockHint();
                end;

            }
        }
        modify(Description)
        {
            width = 100;
        }
        modify("trm Description 2")
        {
            width = 100;
        }
        addlast(Control1)
        {
            field("DDN Item Planning Status Code"; Rec."DDN Item Planning Status Code")
            {
                ApplicationArea = All;
            }
            field("DDN Item Status Code"; Rec.getStatusCode())
            {
                ApplicationArea = All;
                editable = false;
                Caption = 'Status Code (Matrix/Item)';
                ToolTip = 'This is a DEDON field that is stored in the table MatrxCell of the corresponding master.';
            }
            field("DDN is active Version"; Rec.isActiveVersion())
            {
                ApplicationArea = all;
                Editable = false;
                Caption = 'active Version';
                ToolTip = 'This is a DEDON field wich is not stored in the item itselt but wich is calculated via searchtable ACTIVEVERSION';
                Visible = false;
            }
            field("Statistics Group"; Rec."Statistics Group")
            {
                ApplicationArea = All;
            }
            field("trm Item Statistics Group"; Rec."trm Item Statistics Group")
            {
                ApplicationArea = All;
            }
            field("trm Item Statistics Group 2"; Rec."trm Item Statistics Group 2")
            {
                ApplicationArea = All;
            }
            field("trm Item Statistics Group 3"; Rec."trm Item Statistics Group 3")
            {
                ApplicationArea = All;
            }
            field("trm Item Statistics Group 4"; Rec."trm Item Statistics Group 4")
            {
                ApplicationArea = All;
            }
            field("trm Item Statistics Group 5"; Rec."trm Item Statistics Group 5")
            {
                ApplicationArea = All;
            }

        }
    }
    actions
    {
        addlast(Availability)
        {
            action("COR open DSDS Schedule")
            {
                ApplicationArea = All;
                Image = ItemAvailability;
                Caption = 'DEDON Shipment Date Schedule (DSDS)';

                trigger OnAction()
                var
                    dsdsAvailitbilityMgmt_lCodeUnit: Codeunit "COR DSDS Availibility Mgmt.";
                    Schedule_lPage: Page "COR DSDS Schedule Line";
                begin
                    Schedule_lPage.SetContext(Rec);
                    Schedule_lPage.Run();
                end;
            }
        }

        addlast(Reporting)
        {
            group("COR-DDN Print Label Group")
            {
                Caption = 'Label';
                action("COR-DDN print A6 Label")
                {
                    ApplicationArea = All;
                    Caption = 'Print A6 label';
                    Image = PrintCover;
                    Ellipsis = true;

                    trigger OnAction()
                    var
                        item: Record Item;
                    begin
                        CurrPage.SetSelectionFilter(item);
                        Rec.printLabel(item, 1);
                    end;
                }
                action("COR-DDN print A5 Label")
                {
                    ApplicationArea = All;
                    Caption = 'Print A5 label';
                    Image = PrintCover;
                    Ellipsis = true;

                    trigger OnAction()
                    var
                        item: Record Item;
                    begin
                        CurrPage.SetSelectionFilter(item);
                        Rec.printLabel(item, 0);
                    end;
                }
            }
        }
    }

    var
        InstockHint_gTxt: Text;

    trigger OnAfterGetRecord()
    var
    begin
        calcInstockHint();
    end;

    local procedure calcInstockHint()
    var
        InstockMgmt: Codeunit "COR-DDN Instock Delegator";
    begin
        clear(InstockHint_gTxt);
        InstockHint_gTxt := InstockMgmt.CalcInstockAvailibilityHint(Rec."No.", false);
    end;

    /// <summary>
    /// Errechnet neue Instock-Daten durch Aufbau einer Stückliste und Abruf von
    /// Beständen
    /// </summary>
    local procedure refrestInstockHint()
    var
        InstockMgmt: Codeunit "COR-DDN Instock Delegator";
        UpdateDoneMessage_lLabel: Label 'The Instock Information was recalucalted.';
    begin
        clear(InstockHint_gTxt);
        InstockHint_gTxt := InstockMgmt.CalcInstockAvailibilityHint(Rec."No.", true);
        Message((UpdateDoneMessage_lLabel));
    end;
}