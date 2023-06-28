/// <summary>
/// Page DDN Purchase Line List (ID 51003).
/// <see cref="#TCP5"/>
/// </summary>
page 51003 "DDN Purchase Line List"
{
    Caption = 'DEDON Purchase Line Overview';
    PageType = Worksheet;
    SourceTable = "Purchase Line";
    SourceTableView = where("Document Type" = const("Order"), Type = const(Item));
    ApplicationArea = All;
    UsageCategory = Lists;
    InsertAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                FreezeColumn = "Description 2";
                field("DDN Document Status"; Rec."DDN Document Status")
                {
                    ApplicationArea = All;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = all;
                    AssistEdit = true;
                    trigger OnAssistEdit()
                    var
                        PurchaseHader_lRec: Record "Purchase Header";
                    begin
                        PurchaseHader_lRec.get(Rec."Document Type", Rec."Document No.");
                        Page.Run(Page::"Purchase Order", PurchaseHader_lRec);
                    end;
                }

                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field("Quantity (Base)"; Rec."Quantity (Base)")
                {
                    ApplicationArea = All;
                }
                field("Buy-from Vendor No."; Rec."Buy-from Vendor No.")
                {
                    ApplicationArea = All;
                }
                field("Purchasing Code"; Rec."Purchasing Code")
                {
                    ApplicationArea = All;
                }
                field("Qty. Invoiced (Base)"; Rec."Qty. Invoiced (Base)")
                {
                    ApplicationArea = All;
                }
                field("Qty. Rcd. Not Invoiced"; Rec."Qty. Rcd. Not Invoiced")
                {
                    ApplicationArea = All;
                }
                field("Qty. Rcd. Not Invoiced (Base)"; Rec."Qty. Rcd. Not Invoiced (Base)")
                {
                    ApplicationArea = All;
                }
                field("Qty. Received (Base)"; Rec."Qty. Received (Base)")
                {
                    ApplicationArea = All;
                }
                field("Qty. Rounding Precision"; Rec."Qty. Rounding Precision")
                {
                    ApplicationArea = All;
                }
                field("Qty. Rounding Precision (Base)"; Rec."Qty. Rounding Precision (Base)")
                {
                    ApplicationArea = All;
                }
                field("Qty. per Unit of Measure"; Rec."Qty. per Unit of Measure")
                {
                    ApplicationArea = All;
                }
                field("Qty. to Assign"; Rec."Qty. to Assign")
                {
                    ApplicationArea = All;
                }
                field("Qty. to Invoice"; Rec."Qty. to Invoice")
                {
                    ApplicationArea = All;
                }
                field("Qty. to Invoice (Base)"; Rec."Qty. to Invoice (Base)")
                {
                    ApplicationArea = All;
                }
                field("Qty. to Receive"; Rec."Qty. to Receive")
                {
                    ApplicationArea = All;
                }
                field("Qty. to Receive (Base)"; Rec."Qty. to Receive (Base)")
                {
                    ApplicationArea = All;
                }
                field("Quantity Invoiced"; Rec."Quantity Invoiced")
                {
                    ApplicationArea = All;
                }
                field("DDN Estimated Date Ready"; Rec."DDN Estimated Date Ready")
                {
                    ApplicationArea = All;
                }
                field("DDN Effective Shipment Date"; Rec."DDN Effective Shipment Date")
                {
                    ApplicationArea = All;
                }
                field("DDN Requested Shipment Date"; Rec."DDN Requested Shipment Date")
                {
                    ApplicationArea = All;
                }
                field("DDN Original Qty."; Rec."DDN Original Qty.")
                {
                    ApplicationArea = All;
                }


                field("Document Type"; Rec."Document Type") { ApplicationArea = All; }
                field("Line No."; Rec."Line No.") { ApplicationArea = All; }
                field("Type"; Rec."Type") { ApplicationArea = All; }
                field("VendorItemNo"; Rec."Item Reference No.") { ApplicationArea = All; }
                field("Variant Code"; Rec."Variant Code") { ApplicationArea = All; }
                field("Location Code"; Rec."Location Code") { ApplicationArea = All; }
                field("Reserved Qty. (Base)"; Rec."Reserved Qty. (Base)") { ApplicationArea = All; }
                field("Unit of Measure Code"; Rec."Unit of Measure Code") { ApplicationArea = All; }
                field("Direct Unit Cost"; Rec."Direct Unit Cost") { ApplicationArea = All; }
                field("Indirect Cost %"; Rec."Indirect Cost %") { ApplicationArea = All; }
                field("Unit Cost (LCY)"; Rec."Unit Cost (LCY)") { ApplicationArea = All; }
                field("Unit Price (LCY)"; Rec."Unit Price (LCY)") { ApplicationArea = All; }
                field("Line Amount"; Rec."Line Amount") { ApplicationArea = All; }
                field("Job No."; Rec."Job No.") { ApplicationArea = All; }
                field("Job Task No."; Rec."Job Task No.") { ApplicationArea = All; }
                field("Requested Receipt Date"; Rec."Requested Receipt Date") { ApplicationArea = All; }
                field("Promised Receipt Date"; Rec."Promised Receipt Date") { ApplicationArea = All; }
                field("Planned Receipt Date"; Rec."Planned Receipt Date") { ApplicationArea = All; }
                field("Order Date"; Rec."Order Date") { ApplicationArea = All; }
                field("Job Line Type"; Rec."Job Line Type") { ApplicationArea = All; }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code") { ApplicationArea = All; }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code") { ApplicationArea = All; }
                field("Expected Receipt Date"; Rec."Expected Receipt Date") { ApplicationArea = All; }
                field("Outstanding Quantity"; Rec."Outstanding Quantity") { ApplicationArea = All; }
                field("Outstanding Qty. (Base)"; Rec."Outstanding Qty. (Base)") { ApplicationArea = All; }
                field("Outstanding Amount (LCY)"; Rec."Outstanding Amount (LCY)") { ApplicationArea = All; }
                field("Amt. Rcd. Not Invoiced (LCY)"; Rec."Amt. Rcd. Not Invoiced (LCY)") { ApplicationArea = All; }
                field("Blanket Order No."; Rec."Blanket Order No.") { ApplicationArea = All; }
                field("Blanket Order Line No."; Rec."Blanket Order Line No.") { ApplicationArea = All; }
                field("Special Order"; Rec."Special Order") { ApplicationArea = All; }
                field("Special Order Sales No."; Rec."Special Order Sales No.") { ApplicationArea = All; }
                field("Special Order Sales Line No."; Rec."Special Order Sales Line No.") { ApplicationArea = All; }
                field("Sales Order No."; Rec."Sales Order No.") { ApplicationArea = All; }
                field("Sales Order Line No."; Rec."Sales Order Line No.") { ApplicationArea = All; }
            }
        }
    }


}
