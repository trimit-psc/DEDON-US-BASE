/// <summary>
/// Report COR-DDN IC Pricelist (ID 51003).
/// </summary>
/// <see cref="#CP7T"/>
/// <see cref="https://dedongroup.atlassian.net/browse/DEDT-538"/>
report 51003 "COR-DDN IC Pricelist"
{
    RDLCLayout = 'Src/Sales/Reports/Rep51003.CORDDNICPricelist.rdl';
    DefaultLayout = Rdlc;
    Caption = 'COR-DDN IC Pricelist';
    UsageCategory = ReportsAndAnalysis;
    PreviewMode = Normal;


    dataset
    {
        /// <summary>
        /// Dient zum manuellen Filtern 
        /// </summary>
        dataitem(Item_DataItem; Item)
        {
            RequestFilterFields = "No.", "trm Master No.";

            // es mag merkwürig wirken; aber die EK-Preise werden genutzt
            // um zu filtern, welche Artikel in welchen Mengenstaffeln an IC-Partner
            // verkauft werden.
            // Der Verkaufspreis ermittelt sich mittels Formel, die iene Zuschlagskalkulation
            // auf dem EK-Preis abbildet        
            dataitem(tmpPurchasePrice; "Purchase Price")
            {
                UseTemporary = true;
                DataItemTableView = sorting("Item No.", "Vendor No.", "Starting Date", "Currency Code", "Variant Code", "Unit of Measure Code", "Minimum Quantity");
                // DataItemLinkReference = Item_DataItem;
                // DataItemLink = "Item No." = field("No.");

                column(ItemNo; Item_DataItem."No.") { }
                column(Nav18ItemNo; Item_DataItem."DDM Legacy System Item No.") { }
                column(Description; Item_DataItem.Description) { }
                column(Description2; Item_DataItem."Description 2") { }
                column(quantity; tmpPurchasePrice."Minimum Quantity") { }
                column(Price; SalesPrice_gDec)
                {
                    DecimalPlaces = 2 : 2;
                }

                // DataItem PurchasePrice
                trigger OnPreDataItem()
                var

                begin

                end;

                // DataItem PurchasePrice
                trigger OnAfterGetRecord()
                var
                    salesPrice_lRec: Record "Sales Price";
                    quantity_lDec: Decimal;
                begin
                    clear(SalesPrice_gDec);

                    // prüfe, ob es zu dem Artikel oder Master einen IC-Vk-Preis gibt
                    if Item_DataItem."trm Master No." = '' then
                        salesPrice_lRec.setrange("Item No.", Item_DataItem."No.")
                    else
                        salesPrice_lRec.SetFilter("Item No.", '%1|%2', Item_DataItem."No.", Item_DataItem."trm Master No.");
                    salesPrice_lRec.setrange("Sales Type", salesPrice_lRec."Sales Type"::"Customer Price Group");
                    salesPrice_lRec.setrange("Sales Code", CustomerPriceGroup_gCode);

                    if salesPrice_lRec.IsEmpty then
                        CurrReport.Skip();

                    // Es wird mit Menge 1 gerechnet; aber Menge 0 in der Ausgabe angezeigt
                    if tmpPurchasePrice."Minimum Quantity" = 0 then
                        quantity_lDec := 1
                    else
                        quantity_lDec := tmpPurchasePrice."Minimum Quantity";

                    if not CalcSalesPrice(Item_DataItem."No.", quantity_lDec) then begin
                        if excludeLinesWithError_gBool then
                            CurrReport.Skip();
                    end;
                end;
            }

            // DataItem Item
            trigger OnPreDataItem()
            var
                CustomerNotSelectedError_lLbl: Label 'You must select a customer.';
                Customer_lRec: Record Customer;
            begin
                if CustomerNo_gCode = '' then
                    error(CustomerNotSelectedError_lLbl);
                customer_lRec.get(CustomerNo_gCode);
                Customer_lRec.TestField("Customer Price Group");
                CustomerPriceGroup_gCode := customer_lRec."Customer Price Group";

            end;

            // DataItem Item
            trigger OnAfterGetRecord()
            var
                PurchasePrice_lRec: record "Purchase Price";
            begin
                PurchasePrice_lRec.SetFilter("Starting Date", '..%1', referenceDate_gDate);
                PurchasePrice_lRec.SetFilter("Ending Date", '%1..|%2', referenceDate_gDate, 0D);
                PurchasePrice_lRec.setrange("Item No.", Item_DataItem."No.");

                if not tmpPurchasePrice.IsTemporary then
                    error('You tried to delete Purchase Prices. Thats no good idea!');
                tmpPurchasePrice.DeleteAll(false);

                // immer einen Datensatz mit 0 Stück ergänzen
                if PurchasePrice_lRec.findfirst then begin
                    tmpPurchasePrice := PurchasePrice_lRec;
                    tmpPurchasePrice."Minimum Quantity" := 0;
                    tmpPurchasePrice.insert;
                end;

                PurchasePrice_lRec.setfilter("Minimum Quantity", '<>1&<>0');
                if PurchasePrice_lRec.findset then begin
                    repeat
                        tmpPurchasePrice := PurchasePrice_lRec;
                        tmpPurchasePrice.insert;
                    until PurchasePrice_lRec.next() = 0;
                end;
            end;
        }


    }

    requestpage
    {
        SaveValues = true;
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                    Caption = 'Options';
                    field(CustomerNo; CustomerNo_gCode)
                    {
                        Caption = 'Customer No.';
                        ApplicationArea = All;
                        TableRelation = "Customer"."No." where("Customer Price Group" = filter('<>'''''));
                    }
                    field(referenceDate; referenceDate_gDate)
                    {
                        Caption = 'Date';
                        ApplicationArea = All;
                    }
                    field(excludeLinesWithError; excludeLinesWithError_gBool)
                    {
                        Caption = 'Exclude Lines with error in Price Calculation';
                        ApplicationArea = All;
                    }
                }
            }
        }



        actions
        {
            area(processing)
            {
            }
        }

        trigger OnOpenPage()
        var
            myInt: Integer;
        begin
            CustomerPriceGroup_gCode := 'IC';
            referenceDate_gDate := WorkDate();
        end;
    }

    local procedure CalcSalesPrice(itemNo_lCode: Code[20]; quantity_iDec: Decimal) ret: Boolean
    var
        "DDN Price/Cost Determination": Codeunit "DDN Price/Cost Determination";
    begin
        clear(SalesPrice_gDec);
        clear(SalesPriceCalculationError_gTxt);
        "DDN Price/Cost Determination".initUnitPriceRequest(itemNo_lCode, referenceDate_gDate, quantity_iDec, CustomerNo_gCode);
        if not "DDN Price/Cost Determination".run() then begin
            SalesPrice_gDec := 0;
            SalesPriceCalculationError_gTxt := 'Calculation failed';
        end
        else begin
            SalesPrice_gDec := "DDN Price/Cost Determination".getUnitPrice();
            ret := true;
        end;

    end;

    var
        /// <summary>
        /// Datum zu dem der VK-Preis gültig sein soll
        /// </summary>
        referenceDate_gDate: Date;
        CustomerPriceGroup_gCode: Code[20];
        CustomerNo_gCode: Code[20];
        SalesPrice_gDec: Decimal;
        SalesPriceCalculationError_gTxt: Text;
        excludeLinesWithError_gBool: boolean;
}
