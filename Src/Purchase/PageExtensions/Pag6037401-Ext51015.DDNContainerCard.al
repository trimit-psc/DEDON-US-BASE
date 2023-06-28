pageextension 51015 "DDN Container Card" extends "trm Container Card" //6037401
{
    layout
    {
        addlast(Content)
        {
            group(DDNDateGroup)
            {
                Caption = 'DEDON';
                /// <summary>
                /// <see cref="#7JRN"/>
                /// </summary>
                field("DDN Effective Shipment Date"; Rec."DDN Effective Shipment Date")
                {
                    ApplicationArea = All;
                }
                /// <summary>
                /// <see cref="#7JRN"/>
                /// </summary>
                field("DDN Estimated Date Ready"; Rec."DDN Estimated Date Ready")
                {
                    ApplicationArea = All;
                }
                /// <summary>
                /// <see cref="#7JRN"/>
                /// </summary>
                field("DDN Requested Shipment Date"; Rec."DDN Requested Shipment Date")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        addlast(processing)
        {
            action("COR-DDN CreteUnpostedPrepayPurchaseInvoice")
            {
                ApplicationArea = All;
                Caption = 'Create unposted Prepayment Purchase Invocie';
                Image = Prepayment;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    Container_lRec: Record "trm Container";
                begin
                    CurrPage.SetSelectionFilter(Container_lRec);
                    Codeunit.run(Codeunit::"COR-DDN Cont. Pre. Purch. Inv.", Container_lRec);
                end;
            }

            /// <summary>
            /// Aufruf der CU zum erzeigen einer ungebuchten EK-Rechnung
            /// hier auch Containerübergreifend
            /// <see cref="#AT4L"/>
            /// </summary>
            action("COR-DDN CreteUnpostedFinalPurchaseInvoice")
            {
                ApplicationArea = All;
                Caption = 'Create unposted final Purchase Invocie';
                Image = Invoice;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    Container_lRec: Record "trm Container";
                begin
                    CurrPage.SetSelectionFilter(Container_lRec);
                    Codeunit.run(Codeunit::"COR-DDN Cont. Fin. Purch. Inv.", Container_lRec);
                end;
            }


        }
    }
}