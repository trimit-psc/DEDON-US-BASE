pageextension 51017 "DDN Sales Order" extends "Sales Order" //42
{
    layout
    {
        addafter(Control1901314507)
        {
            part("DDN Item Detail Factbox"; "DDN Item Detail Sales Factbox")
            {
                ApplicationArea = Basic, Suite;
                Provider = SalesLines;
                SubPageLink = "Document Type" = FIELD("Document Type"),
                              "Document No." = FIELD("Document No."),
                              "Line No." = FIELD("Line No.");
                UpdatePropagation = SubPart;
            }
            /// <summary>
            /// <see cref="#SMH1"/>
            /// </summary>
            part("Comments FactBox"; "Comments FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "Table Name" = const(Customer), "No." = field("Sell-to Customer No.");
            }
        }

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
    }

    actions
    {
        addlast("F&unctions")
        {
            group(DDNFunctionsGroup)
            {
                Caption = 'DEDON';
                action(DDNrecalcEarliestShipmentDates)
                {
                    Caption = 'caclulate eraliest shipment date';
                    ApplicationArea = All;
                    Image = ChangeDates;
                    Enabled = false;

                    trigger OnAction()
                    var
                        salesLine_lRec: Record "Sales Line";
                        AvailibilityTool: Codeunit "DDN Availibility Tools";
                    begin
                        salesLine_lRec.SetRange("Document Type", Rec."Document Type");
                        salesLine_lRec.SetRange("Document No.", Rec."No.");
                        salesLine_lRec.SetRange(Type, salesLine_lRec.type::Item);
                        AvailibilityTool.calculateEarliesShipmentDate(salesLine_lRec);
                    end;
                }

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
                        salesLine_lRec.SetFilter("Quantity", '<>0');
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
                action(DDNTransferEaliestShipmentDateToShipmentDate)
                {
                    Caption = 'transfer earliest shipment date';
                    ApplicationArea = All;
                    Image = ChangeDates;

                    trigger OnAction()
                    var
                        salesLine_lRec: Record "Sales Line";
                        AvailibilityTool: Codeunit "DDN Availibility Tools";
                    begin
                        salesLine_lRec.SetRange("Document Type", Rec."Document Type");
                        salesLine_lRec.SetRange("Document No.", Rec."No.");
                        salesLine_lRec.SetRange(Type, salesLine_lRec.type::Item);
                        AvailibilityTool.TransferEaliestShipmentDateToShipmentDate(salesLine_lRec);
                    end;
                }
                /// Zuständigketiseinheit im NAchgang korrigieren
                /// <see cref="https://dedongroup.atlassian.net/browse/DEDT-504"/>
                action(DDNModifyResponsibilityCenter)
                {
                    Caption = 'Reassign repsonsibility center';
                    ApplicationArea = All;
                    Image = Responsibility;
                    ToolTip = 'This is a Dedon function wich is used to repair sales orders withour a responsibility center';

                    trigger OnAction()
                    var
                    begin
                        Rec.ReassignResponsibilityCenter(0);
                    end;
                }
            }
        }

        addlast(trmLineDiscountGroup)
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

        addfirst("Request Approval")
        {
            action("COR-DDN Request Apporval")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Send A&pproval Request';
                Enabled = NOT OpenApprovalEntriesExist2 AND CanRequestApprovalForFlow2;
                Image = SendApprovalRequest;
                Promoted = true;
                PromotedCategory = Category9;
                PromotedIsBig = true;
                ToolTip = 'Request approval of the document. (DEDON)';

                trigger OnAction()
                var
                    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                begin
                    Rec.CalculateApprovalDelta();
                    Rec.Modify();
                    if ApprovalsMgmt.CheckSalesApprovalPossible(Rec) then
                        ApprovalsMgmt.OnSendSalesDocForApproval(Rec);
                end;
            }
        }
    }
    var
        [indataset]
        OpenApprovalEntriesExist2: Boolean;
        [indataset]
        CanRequestApprovalForFlow2: Boolean;


    local procedure CORDDNSetControlVisibility()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
        CanCancelApprovalForFlow: Boolean;

    begin
        OpenApprovalEntriesExist2 := ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
        WorkflowWebhookMgt.GetCanRequestAndCanCancel(Rec.RecordId, CanRequestApprovalForFlow2, CanCancelApprovalForFlow);
    end;

    trigger OnAfterGetRecord()
    begin
        CORDDNSetControlVisibility;
    end;
}