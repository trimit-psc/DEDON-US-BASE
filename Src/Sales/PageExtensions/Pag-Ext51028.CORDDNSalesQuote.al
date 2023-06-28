pageextension 51028 "COR-DDN Sales Quote" extends "Sales Quote"
{
    layout
    {
        /// <summary>
        /// <see cref="#U29F"/>
        /// </summary>
        addafter("trm Salesperson 3")
        {
            field("COR-DDN Respons. Person Code"; Rec."COR-DDN Respons. Person Code")
            {
                ApplicationArea = All;
            }
        }

        addafter(IncomingDocAttachFactBox)
        {
            /// <summary>
            /// <see cref="#SMH1"/>
            /// </summary>
            part("Comments FactBox"; "Comments FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "Table Name" = const(Customer), "No." = field("Sell-to Customer No.");
            }
        }
    }

    actions
    {
        addlast("F&unctions")
        {
            group(DDNFunctionsGroup)
            {
                Caption = 'Dedon Functions';
                // #DSDS
                action("COR calc earlises Shipment Date via DSDS Schedule")
                {
                    ApplicationArea = All;
                    Image = ChangeDate;
                    Caption = 'Calculate earliest shipment date via DSDS';
                    ToolTip = 'Calculates the earliest Shipment date based on the DSDS. If your sales line has not yet a priority then your priority is calculated before.';

                    trigger OnAction()
                    var
                        dsdsAvailitbilityMgmt_lCodeUnit: Codeunit "COR DSDS Availibility Mgmt.";
                        salesLine_lRec: Record "Sales Line";
                    begin
                        salesLine_lRec.SetRange("Document Type", Rec."Document Type");
                        salesLine_lRec.SetRange("Document No.", Rec."No.");
                        salesLine_lRec.SetRange(Type, salesLine_lRec.type::Item);
                        salesLine_lRec.SetFilter("No.", '<>''''');
                        salesLine_lRec.setfilter(Quantity, '<>0');
                        if salesLine_lRec.findset then
                            repeat
                                clear(dsdsAvailitbilityMgmt_lCodeUnit);
                                dsdsAvailitbilityMgmt_lCodeUnit.InitObject(salesLine_lRec."No.", salesLine_lRec."Location Code");
                                dsdsAvailitbilityMgmt_lCodeUnit.SetFocusOnSalesLine(salesLine_lRec);
                                dsdsAvailitbilityMgmt_lCodeUnit.QueueUnpriorisedSalesLine(salesLine_lRec, true);
                                dsdsAvailitbilityMgmt_lCodeUnit.createSchedule();
                                salesLine_lRec."COR-DDN earliest Shipment Date" := dsdsAvailitbilityMgmt_lCodeUnit.FindEarliestShipmentDateForSalesLine(salesLine_lRec, false);
                                salesLine_lRec.modify;
                            until salesLine_lRec.next() = 0;
                    end;
                }
            }

        }
        addlast("F&unctions")
        {
            action("COR-DDN DeleteDiscountCombinations")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Delete Discount Combination';
                Image = DeactivateDiscounts;
                ToolTip = 'Deletes the discount combination for all sales lines within this document and sets the line discount ot zero.';

                trigger OnAction()
                var
                begin
                    Rec.VanishLineDiscounts();
                end;
            }
        }
        addlast(Reporting)
        {
            action(ProformaInvoice)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Pro Forma Invoice';
                Ellipsis = true;
                Image = ViewPostedOrder;
                ToolTip = 'View or print the pro forma sales invoice.';

                trigger OnAction()
                var
                    DocPrint: Codeunit "Document-Print";
                begin
                    DocPrint.PrintProformaSalesInvoice(Rec);
                end;
            }
        }

    }

    local procedure Prepayment37OnAfterValidate()
    begin
        CurrPage.Update();
    end;
}
