/// <summary>
/// Codeunit DDN Price/Cost Determination (ID 51005) ermittelt Listenpreise um schnell Preisauskünfte erteilen zu können
/// <see cref="#K2RD"/>
/// </summary>
codeunit 51005 "DDN Price/Cost Determination"
{
    trigger OnRun()
    var
        TrimitServiceSalesCreate: Codeunit "trm API Sales Create";
        TrimitServicePurchaseCreate: Codeunit "trm API Purchase Create";
        item: Record Item;
        vendorNo: code[20];
        ddnSetup: Record "DDN Setup";
        Customer: Record Customer;
    begin
        ddnSetup.get;
        // Notfall-Schalter falls etwas klemmt.
        if not ddnSetup."Enable Price/Cost Determin." then
            exit;
        unitPrice := (-0.00001);
        unitCost := (-0.00001);
        if not item.get(ItemNo) then
            exit;
        if item.type = item.type::"Non-Inventory" then
            exit;

        if CalcUnitPrice then begin
            if CustomerNo = '' then begin
                unitPrice := TrimitServiceSalesCreate.GetUnitPrice1(item."No.");
            end else begin
                if quantity = 0 then begin
                    unitPrice := TrimitServiceSalesCreate.GetUnitPrice2(item."No.", CustomerNo);
                end
                else begin
                    Customer.SetLoadFields("Customer Price Group", "Currency Code");
                    if Customer.get(CustomerNo) then;
                    unitPrice := TrimitServiceSalesCreate.GetUnitPrice5(Item."No.", customerNo, Customer."Customer Price Group", referenceDate, Customer."Currency Code", '', Item."Base Unit of Measure", quantity);
                end;
            end;

        end;
        if CalcUnitCost then begin
            vendorNo := Item."Vendor No.";
            unitCost := TrimitServicePurchaseCreate.GetDirectUnitCost(vendorNo, item."No.", referenceDate, '', '', item."Base Unit of Measure", quantity);
        end;
    end;

    var
        itemNo: Code[20];
        CustomerNo: Code[20];
        CalcUnitPrice: Boolean;
        CalcUnitCost: Boolean;
        unitPrice: Decimal;
        unitCost: Decimal;
        referenceDate: Date;
        TransactionSaveMode: Boolean;
        quantity: Decimal;

    procedure initUnitPriceRequest(ItemNo2: code[20]; CustomerNo2: code[20])
    begin
        initUnitPriceRequest(ItemNo2);
        CustomerNo := CustomerNo2;
    end;

    procedure initUnitPriceRequest(ItemNo2: code[20])
    begin
        CalcUnitPrice := true;
        itemNo := ItemNo2;
    end;

    procedure initUnitCostRequest(ItemNo2: code[20]; referenceDate2: Date)
    begin
        CalcUnitCost := true;
        itemNo := ItemNo2;
        referenceDate := referenceDate2;
    end;

    procedure initUnitCostRequest(ItemNo2: code[20]; referenceDate2: Date; quantity2: Decimal)
    begin
        initUnitCostRequest(ItemNo2, referenceDate2);
        quantity := quantity2;
    end;

    procedure initUnitPriceRequest(ItemNo2: code[20]; referenceDate2: Date; quantity2: Decimal; CustomerNo2: code[20])
    begin
        initUnitPriceRequest(ItemNo2, CustomerNo2);
        referenceDate := referenceDate2;
        quantity := quantity2;
    end;

    procedure getUnitPrice(): Decimal
    begin
        exit(unitPrice);
    end;

    procedure getUnitCost(): Decimal
    begin
        exit(unitCost);
    end;

}


