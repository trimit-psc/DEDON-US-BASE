pageextension 51033 "COR-DDN Posted Sales Invocie" extends "Posted Sales Invoice"
{
    layout
    {
        addafter("No.")
        {

            field("Prepayment Invoice"; Rec."Prepayment Invoice")
            {
                ApplicationArea = All;
            }
        }

        addafter("Attached Documents")
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
        addafter(Print)
        {
            /// Sammellieferschein drucken
            /// <see cref="#MCAP"/>
            action("COR-DDN Print ShipmentNote Summary Invoice")
            {
                ApplicationArea = All;
                Caption = 'Print Shipment note Summary Invoice';
                ToolTip = 'DEDON Prints a special shipment note that aggregates all shipment lines touched by this invoice.';
                Image = Print;
                Ellipsis = true;
                Promoted = true;
                PromotedCategory = Category6;

                trigger OnAction()
                var
                    DocumentSendingProfile: Record "Document Sending Profile";
                    DummyReportSelections: Record "Report Selections";
                    SalesInvHeader: Record "Sales Invoice Header";
                begin
                    SalesInvHeader := Rec;
                    CurrPage.SetSelectionFilter(SalesInvHeader);
                    DocumentSendingProfile.TrySendToPrinter(
                      DummyReportSelections.Usage::"COR-DDN ShipmentNoteSummaryInvoice".AsInteger(), SalesInvHeader, Rec.FieldNo("Bill-to Customer No."), true);
                end;
            }
        }
    }
}
