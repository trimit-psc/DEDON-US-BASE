pageextension 51018 "DDN Container List" extends "trm Container List" //6037402
{
    layout
    {
        addafter("No.")
        {
            field("DDN Transit Icon"; rec.GetTransitIcon())
            {
                AboutText = 'Zeigt Dir, ob ein Container auf dem Schiff unterwegs ist.';
                Editable = false;
                Caption = 'Icon';
                ApplicationArea = All;
            }
        }
        addafter(Type)
        {
            field("COR-DDN Description"; Rec.Description)
            {
                ApplicationArea = All;
            }

            field("COR-DDN Description 2"; Rec."Description 2")
            {
                ApplicationArea = All;
            }
        }
        addafter("Filter Vendor/Customer")
        {
            field("COR-DDN VendorCustomerName"; VendorCustomerName_gTxt)
            {
                ApplicationArea = all;
                Caption = 'Vendor/Customer Name';
                Editable = false;
            }
        }
    }
    actions
    {
        addlast(reporting)
        {
            action(DDNschwimmendeWare)
            {
                Caption = 'Incoming Containers (Print)';
                ApplicationArea = All;
                Image = Shipment;
                Promoted = true;
                PromotedCategory = Report;

                trigger OnAction()
                var
                    ReportLayoutSelection_lRec: Record "Report Layout Selection";
                    RememberLayout_lCod: Code[20];
                begin
                    RememberLayout_lCod := ReportLayoutSelection_lRec.GetTempLayoutSelected();
                    ReportLayoutSelection_lRec.SetTempLayoutSelected('sexy');
                    Report.Run(Report::"DDN Incoming Containers");
                    ReportLayoutSelection_lRec.SetTempLayoutSelected(RememberLayout_lCod);
                end;

            }
            /// <summary>
            /// <see cref="#Q84K"/>
            /// </summary>              
            action(DDNIncomingContainersExcel)
            {
                Caption = 'Incoming Containers (Excel)';
                ApplicationArea = All;
                Image = Shipment;
                Promoted = true;
                PromotedCategory = Report;

                trigger OnAction()
                var
                    ReportLayoutSelection_lRec: Record "Report Layout Selection";
                    RememberLayout_lCod: Code[20];
                begin
                    RememberLayout_lCod := ReportLayoutSelection_lRec.GetTempLayoutSelected();
                    ReportLayoutSelection_lRec.SetTempLayoutSelected('ExcelPrepared');
                    Report.Run(Report::"DDN Incoming Containers");
                    ReportLayoutSelection_lRec.SetTempLayoutSelected(RememberLayout_lCod);
                end;
            }
            /// <summary>
            /// Aufruf der CU zum erzeigen einer ungebuchten EK-Rechnung
            /// hier auch Containerübergreifend
            /// <see cref="#AT4L"/>
            /// </summary>
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
            action("COR-DDN CreteUnpostedPurchaseInvoice")
            {
                ApplicationArea = All;
                Caption = 'Create unposted Purchase Invoice';
                ToolTip = 'Creates an unposted invoice with all incoming receipt lines of the selected container(s). This is a shortcut for creating final invoices and an alterantive to the old way of getting receipt lines.';
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

    var
        VendorCustomerName_gTxt: Text[80];

    trigger OnAfterGetRecord()
    var
        Vendor_lRec: Record Vendor;
        Customer_lRec: Record Customer;
    begin
        clear(VendorCustomerName_gTxt);

        if Rec."Filter Vendor/Customer" = '' then
            exit;
        case Rec.Type of
            Rec.Type::Inbound:
                begin
                    Vendor_lRec.SetLoadFields(Name);
                    if Vendor_lRec.get(Rec."Filter Vendor/Customer") then
                        VendorCustomerName_gTxt := Vendor_lRec.name;
                end;
            Rec.Type::Outbound:
                begin
                    Customer_lRec.SetLoadFields(Name);
                    if Customer_lRec.get(Rec."Filter Vendor/Customer") then
                        VendorCustomerName_gTxt := Customer_lRec.name;
                end;
        end;
    end;
}
