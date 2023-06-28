pageextension 51036 "Purchase Lines (DDN)" extends "Purchase Lines" //518
{
    layout
    {
        addlast(Control1)
        {
            field("trm Container No."; Rec."trm Container No.")
            {
                ApplicationArea = All;
            }
            field("COR-DDN Special Order Sales No."; Rec."Special Order Sales No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Special Order Sales No. field.';
            }
            field("COR-DDN Special Order"; Rec."Special Order")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Special Order field.';
            }
            field("COR-DDN Special Order Sales Line No."; Rec."Special Order Sales Line No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Special Order Sales Line No. field.';
            }
            field("COR-DDN Shipment Date Sales"; shipmentDateSales_gDate)
            {
                Caption = 'Shipment Date Sales';
                ApplicationArea = All;
                Editable = false;
            }
            field("COR-DDN Sell-to Customer No."; sellToCustomerNo_gCod)
            {
                Caption = 'Sell-to Customer No.';
                ApplicationArea = All;
                Editable = false;
            }
            field("COR-DDN Sell-to Customer Name"; sellToCustomerName_gTxt)
            {
                Caption = 'Sell-to Customer Name';
                ApplicationArea = All;
                Editable = false;
            }
            field("COR-DDN Warehouse Receipt No."; WareHouseReceiptNo_gCod)
            {
                Caption = 'Warehouse Receipt No.';
                ApplicationArea = All;
                Editable = false;
                DrillDown = true;

                trigger OnDrillDown()
                var
                    whseReceiptHeader_lRec: Record "Warehouse Receipt Header";
                begin
                    whseReceiptHeader_lRec.get(WareHouseReceiptNo_gCod);
                    page.run(Page::"Warehouse Receipt", whseReceiptHeader_lRec);
                end;
            }
            field("COR-DDN JungheinrichStatus"; JungheinrichStatus)
            {
                Caption = 'Jungheinrich Status';
                OptionCaption = 'New,Released to WMS,Receiving Started,Receiving Completed,Canceled,Error Export,Error Import, ';
                ApplicationArea = All;
                Editable = false;
            }
            field("COR-DDN Vendor Order No."; Rec."COR-DDN Vendor Order No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Vendor Order No. field.';
            }

            field("COR-DDN Requested Receipt Date"; Rec."Requested Receipt Date")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the date that you want the vendor to deliver to the ship-to address. The value in the field is used to calculate the latest date you can order the items to have them delivered on the requested receipt date. If you do not need delivery on a specific date, you can leave the field blank.';
            }
            field("COR-DDN Promised Receipt Date"; Rec."Promised Receipt Date")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the date that the vendor has promised to deliver the order.';
            }
            field(SystemCreatedAt; Rec.SystemCreatedAt)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the SystemCreatedAt field.';
            }
            field("COR-DDN Purchaser Code"; Rec."COR-DDN Purchaser Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Purchaser Code field.';
            }
            field("Planned Receipt Date"; Rec."Planned Receipt Date")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the date when the item is planned to arrive in inventory. Forward calculation: planned receipt date = order date + vendor lead time (per the vendor calendar and rounded to the next working day in first the vendor calendar and then the location calendar). If no vendor calendar exists, then: planned receipt date = order date + vendor lead time (per the location calendar). Backward calculation: order date = planned receipt date - vendor lead time (per the vendor calendar and rounded to the previous working day in first the vendor calendar and then the location calendar). If no vendor calendar exists, then: order date = planned receipt date - vendor lead time (per the location calendar).';
            }
            field("DDN Effective Shipment Date"; Rec."DDN Effective Shipment Date")
            {
                ApplicationArea = All;
                ToolTip = 'real date of delivery';
            }
            field("COR-DDN Legacy System Item No."; Rec."COR-DDN Legacy System Item No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Legacy System Item No. field.';
            }
            field("COR-DDN Item GTIN"; Rec."COR-DDN Item GTIN")
            {
                ApplicationArea = All;
            }
        }
        addafter("Buy-from Vendor No.")
        {

            field("Buy-from Vendor Name"; Rec."Buy-from Vendor Name")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Buy-from Vendor Name field.';
            }
        }
        addafter("Expected Receipt Date")
        {
            field("DDN Estimated Date Ready"; Rec."DDN Estimated Date Ready")
            {
                ApplicationArea = All;
            }
        }
        addafter("No.")
        {

            field("Item No. 2"; Rec."Item No. 2")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Item No. 2 field.';
            }
            field("DDN Item Planning Status Code"; Rec."DDN Item Planning Status Code")
            {
                ApplicationArea = All;
            }
        }
        modify("Outstanding Quantity")
        {
            Visible = true;
        }
    }

    var
        shipmentDateSales_gDate: Date;
        sellToCustomerNo_gCod: Code[20];
        sellToCustomerName_gTxt: Text[80];
        WareHouseReceiptNo_gCod: Code[20];
        JungheinrichStatus: Option New,"Released to WMS","Receiving Started","Receiving Completed",Canceled,"Error Export","Error Import","undefined";

    local procedure lookupSalesInformation()
    var
        SalesLine_lRec: Record "Sales Line";
    begin
        clear(shipmentDateSales_gDate);
        IF Rec."Special Order" THEN BEGIN
            SalesLine_lRec.reset;
            SalesLine_lRec.SetLoadFields("Shipment Date", "Sell-to Customer No.");
            IF SalesLine_lRec.GET(SalesLine_lRec."Document Type"::Order, Rec."Special Order Sales No.", Rec."Special Order Sales Line No.") THEN begin
                shipmentDateSales_gDate := SalesLine_lRec."Shipment Date";
                sellToCustomerNo_gCod := SalesLine_lRec."Sell-to Customer No.";
                SalesLine_lRec.CalcFields("Sell-to Customer Name");
                sellToCustomerName_gTxt := SalesLine_lRec."Sell-to Customer Name";
            end;
        END;
    end;

    local procedure lookupReceiptInformation()
    var
        WarehouseRecieptLine_lRec: Record "Warehouse Receipt Line";
        WarehouseRecieptHeader_lRec: Record "Warehouse Receipt Header";
    begin
        clear(WareHouseReceiptNo_gCod);
        JungheinrichStatus := JungheinrichStatus::undefined;
        WarehouseRecieptLine_lRec.RESET;
        WarehouseRecieptLine_lRec.SETRANGE("Source Type", Database::"Purchase Line");
        WarehouseRecieptLine_lRec.SETRANGE("Source Subtype", Rec."Document Type");
        WarehouseRecieptLine_lRec.SETRANGE("Source No.", Rec."Document No.");
        WarehouseRecieptLine_lRec.SETRANGE("Source Line No.", Rec."Line No.");

        WarehouseRecieptLine_lRec.SetLoadFields("No.");
        // TODO ReactivateJungheinrichCode following 6 Lines
        WarehouseRecieptHeader_lRec.SetLoadFields("No.", "Status JH");
        IF WarehouseRecieptLine_lRec.FINDFIRST THEN begin
            WareHouseReceiptNo_gCod := WarehouseRecieptLine_lRec."No.";
            WarehouseRecieptHeader_lRec.get(WarehouseRecieptLine_lRec."no.");
            JungheinrichStatus := WarehouseRecieptHeader_lRec."Status JH";
        end;
    end;

    trigger OnAfterGetRecord()
    var
    begin
        lookupSalesInformation();
        lookupReceiptInformation();
    end;



}