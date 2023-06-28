/// <summary>
/// Rechnungsnummer aus Cebu erfragen
/// <see cref="#AT4L"/>
/// </summary>
page 51015 "COR-DDN Container Inv. Dialog"
{
    Caption = 'COR-DDN Container Invoice No.';
    PageType = StandardDialog;

    layout
    {
        area(content)
        {
            field(vendorInvoiceNoWithAppendix; vendorInvoiceNo_gCode)
            {
                ApplicationArea = All;
                Caption = 'Vendor Invoice No.';
                Editable = true;
                Lookup = true;

                trigger OnLookup(var lookupText: Text): Boolean
                var
                    PurchaseInvoiceHeader_lRec: Record "Purch. Inv. Header";
                begin
                    PurchaseInvoiceHeader_lRec.setrange("Buy-from Vendor No.", VendorNo_gCode);
                    if page.RunModal(Page::"Posted Purchase Invoices", PurchaseInvoiceHeader_lRec) = Action::LookupOK then begin
                        vendorInvoiceNo_gCode := PurchaseInvoiceHeader_lRec."Vendor Invoice No.";
                    end;
                end;

                trigger OnValidate()
                var
                    appendix_lCode: Code[5];
                begin
                    // VendorInvoiceNo entspricht der Eingabe des Benutzers
                    // withAppendixCode trägt die Erweiterung als Suffix
                    // withoutAppendixCode ist die Nummer, wie sie der Lieferant ursprünglich mitgeteilt hat
                    clear(vendorInvoiceNoWithoutAppendix_gCode);
                    clear(vendorInvoiceNoWithAppendix_gCode);

                    appendix_lCode := AppendixForInvoiceNo();
                    //if strlen(vendorInvoiceNo_gCode) > strlen(appendix_lCode) then begin
                    // prüfe, ob die Nummer bereits so endet als sei der Appendix angefügt
                    // ABCD-1234/1 -> 10  = 12-2 
                    // a := strpos(vendorInvoiceNo_gCode, appendix_lCode);
                    // b := strlen(vendorInvoiceNo_gCode);
                    // c := strlen(appendix_lCode);
                    // message('%1 = %2 - %3', a, b, c);
                    if strpos(vendorInvoiceNo_gCode, appendix_lCode) = strlen(vendorInvoiceNo_gCode) - strlen(appendix_lCode) + 1 then begin

                    end
                    else begin
                        vendorInvoiceNoWithAppendix_gCode := vendorInvoiceNo_gCode + appendix_lCode;
                        vendorInvoiceNo_gCode := vendorInvoiceNoWithAppendix_gCode;
                    end;
                    if appendix_lCode <> '' then
                        vendorInvoiceNoWithoutAppendix_gCode := copystr(vendorInvoiceNo_gCode, 1, strlen(vendorInvoiceNo_gCode) - strlen(appendix_lCode))
                    else
                        vendorInvoiceNoWithoutAppendix_gCode := vendorInvoiceNo_gCode;

                    //end;
                    findPostedInvoices(whatToCreate_gOpt::glAccountInvoice, vendorInvoiceNoWithoutAppendix_gCode);
                    findPostedInvoices(whatToCreate_gOpt::itemInvoice, vendorInvoiceNoWithoutAppendix_gCode);
                    findUnpostedInvoices(whatToCreate_gOpt::glAccountInvoice, vendorInvoiceNoWithoutAppendix_gCode);
                    findUnpostedInvoices(whatToCreate_gOpt::itemInvoice, vendorInvoiceNoWithoutAppendix_gCode);
                end;
            }

            field(UnpostedAccountInvoiceCreated_gBool; UnpostedAccountInvoiceCreated_gBool)
            {
                ApplicationArea = All;
                Caption = 'unposted G/L Account Invoice exists';
                editable = false;
                ToolTip = 'Indicates if an invoice has already been created and posted. Please be careful not to create invoices twice or more.';
            }
            field(UnpostedItemInvoiceCreated_gBool; UnpostedItemInvoiceCreated_gBool)
            {
                ApplicationArea = All;
                Caption = 'unposted Item Invoice exists';
                editable = false;
                ToolTip = 'Indicates if an invoice has already been created and posted. Please be careful not to create invoices twice or more.';
            }

            field(PostedAccountInvoiceCreated_gBool; PostedAccountInvoiceCreated_gBool)
            {
                ApplicationArea = All;
                Caption = 'Posted G/L Account Invoice exists';
                editable = false;
                ToolTip = 'Indicates if an invoice has already been created and posted. Please be careful not to create invoices twice or more.';
            }
            field(PostedItemInvoiceCreated_gBool; PostedItemInvoiceCreated_gBool)
            {
                ApplicationArea = All;
                Caption = 'posted Item Invoice exists';
                editable = false;
                ToolTip = 'Indicates if an invoice has already been created and posted. Please be careful not to create invoices twice or more.';
            }

        }
    }

    trigger OnClosePage()
    var
        BeCarfulConfirmation_lLabel: Label 'It seems like there hasve alreday been taks done with the Customers Invoice.';
    begin
        // Prüfe, ob der Anwender tortz existierender Belege wirklich einen neuen Beleg erfassen will
        case whatToCreate_gOpt of
            whatToCreate_gOpt::glAccountInvoice:
                begin
                    if UnpostedAccountInvoiceCreated_gBool or PostedAccountInvoiceCreated_gBool then begin
                        if not confirm(BeCarfulConfirmation_lLabel, false) then;
                    end;
                end;
            whatToCreate_gOpt::itemInvoice:
                begin
                    if UnpostedItemInvoiceCreated_gBool or PostedItemInvoiceCreated_gBool then begin
                        if not confirm(BeCarfulConfirmation_lLabel, false) then;
                    end;
                end;
        end;
    end;

    var
        vendorInvoiceNo_gCode: Code[35];
        vendorInvoiceNoWithAppendix_gCode: Code[35];
        vendorInvoiceNoWithoutAppendix_gCode: Code[35];
        UnpostedAccountInvoiceCreated_gBool: Boolean;
        UnpostedItemInvoiceCreated_gBool: Boolean;
        PostedAccountInvoiceCreated_gBool: Boolean;
        PostedItemInvoiceCreated_gBool: Boolean;

        VendorNo_gCode: Code[20];
        whatToCreate_gOpt: Option glAccountInvoice,itemInvoice;


    local procedure findPostedInvoices(what_iOpt: Option glAccountInvoice,itemInvoice; searchCode_iCode: Code[35])
    var
        PurchaseInvoiceHeader_lRec: Record "Purch. Inv. Header";
        ddnSetup: Record "DDN Setup";
    begin
        ddnSetup.get();
        PurchaseInvoiceHeader_lRec.setrange("Reason Code", ddnSetup."Reason Code Cont. Prepay");
        PurchaseInvoiceHeader_lRec.setfilter("Vendor Invoice No.", searchCode_iCode + buildAppendixFilterExpression(what_iOpt));
        PurchaseInvoiceHeader_lRec.setrange("Buy-from Vendor No.", VendorNo_gCode);
        case what_iOpt of
            what_iOpt::glAccountInvoice:
                begin
                    PurchaseInvoiceHeader_lRec.setrange("Reason Code", ddnSetup."Reason Code Cont. Prepay");
                    PostedAccountInvoiceCreated_gBool := not PurchaseInvoiceHeader_lRec.IsEmpty();
                end;
            what_iOpt::itemInvoice:
                begin
                    PurchaseInvoiceHeader_lRec.setrange("Reason Code", ddnSetup."Reason Code Cont. Final Inv.");
                    PostedItemInvoiceCreated_gBool := not PurchaseInvoiceHeader_lRec.IsEmpty();
                end;
        end;
    end;

    local procedure findUnpostedInvoices(what_iOpt: Option glAccountInvoice,itemInvoice; searchCode_iCode: Code[35])
    var
        PurchaseHeader_lRec: Record "Purchase Header";
        ddnSetup: Record "DDN Setup";
    begin
        ddnSetup.get();
        PurchaseHeader_lRec.setrange("Reason Code", ddnSetup."Reason Code Cont. Prepay");
        PurchaseHeader_lRec.setfilter("Vendor Invoice No.", searchCode_iCode + buildAppendixFilterExpression(what_iOpt));
        PurchaseHeader_lRec.setrange("Buy-from Vendor No.", VendorNo_gCode);
        case what_iOpt of
            what_iOpt::glAccountInvoice:
                begin
                    PurchaseHeader_lRec.setrange("Reason Code", ddnSetup."Reason Code Cont. Prepay");
                    UnpostedAccountInvoiceCreated_gBool := not PurchaseHeader_lRec.IsEmpty();
                end;
            what_iOpt::itemInvoice:
                begin
                    PurchaseHeader_lRec.setrange("Reason Code", ddnSetup."Reason Code Cont. Final Inv.");
                    UnpostedItemInvoiceCreated_gBool := not PurchaseHeader_lRec.IsEmpty();
                end;
        end;
    end;

    procedure SetContext(BuyFromVendorNo_iCode: Code[20]; whatToCreate_iCode: Option glAccountInvoice,itemInvoice)
    var
        myInt: Integer;
    begin
        VendorNo_gCode := BuyFromVendorNo_iCode;
        whatToCreate_gOpt := whatToCreate_iCode;
    end;

    local procedure AppendixForInvoiceNo(): Code[5]
    var
        ddnSetup: Record "DDN Setup";
    begin
        ddnSetup.get();
        case whatToCreate_gOpt of
            whatToCreate_gOpt::glAccountInvoice:
                begin
                    //ddnSetup.TestField("Appendix Cont. Prepay");
                    exit(ddnSetup."Appendix Cont. Prepay");
                end;
            whatToCreate_gOpt::itemInvoice:
                begin
                    //ddnSetup.TestField("Appendix Cont. Final Inv.");
                    exit(ddnSetup."Appendix Cont. Final Inv.")
                end;
        end;
    end;

    procedure getVendorInvoiceNo(WithAppendix: Boolean) ret: code[35]
    var
        myInt: Integer;
    begin
        if vendorInvoiceNoWithAppendix_gCode = AppendixForInvoiceNo() then
            ret := ''
        else begin
            if WithAppendix then
                ret := vendorInvoiceNoWithAppendix_gCode
            else
                ret := vendorInvoiceNoWithoutAppendix_gCode;
        end;
    end;

    /// <summary>
    /// Erzeugt bei einem Appendix von z.B "/S" ein "??"
    /// </summary>
    /// <returns></returns>
    local procedure buildAppendixFilterExpression(what_iOpt: Option glAccountInvoice,itemInvoice) ret: code[5]
    var
        i: Integer;
        strLenAppendix: integer;
        ddnSetup: record "DDN Setup";
    begin
        ddnSetup.get();
        case what_iOpt of
            what_iOpt::glAccountInvoice:
                begin
                    //ddnSetup.TestField("Appendix Cont. Prepay");
                    strLenAppendix := strlen(ddnSetup."Appendix Cont. Prepay");
                end;
            what_iOpt::itemInvoice:
                begin
                    strLenAppendix := strlen(ddnSetup."Appendix Cont. Final Inv.");
                end;
        end;

        for i := 1 to strLenAppendix do begin
            ret += '?';
        end;
    end;
}
