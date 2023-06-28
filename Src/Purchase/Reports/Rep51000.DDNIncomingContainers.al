/// <summary>
/// <see cref="#Q84K"/>
/// </summary>
report 51000 "DDN Incoming Containers"
{
    ApplicationArea = All;
    Caption = 'DEDON Incoming Containers';
    UsageCategory = ReportsAndAnalysis;
    EnableHyperlinks = true;
    DefaultRenderingLayout = sexy;

    dataset
    {
        dataitem(Captions; Integer)
        {
            DataItemTableView = sorting(Number) where(Number = const(1));

            column(PurchOrderNoCaption_gLbl; PurchOrderNoCaption_gLbl)
            {
            }
            column(VendorNoCaption_gLbl; VendorNoCaption_gLbl)
            {
            }
            column(FreightContainerIDCaption_gLbl; FreightContainerIDCaption_gLbl)
            {
            }
            column(PurchOrderLineNoCaption_gLbl; PurchOrderLineNoCaption_gLbl)
            {
            }
            column(QuantityCaption_gLbl; QuantityCaption_gLbl)
            {
            }
            column(StatusCaption_gLbl; StatusCaption_gLbl)
            {
            }
            column(ItemNoCaption_gLbl; ItemNoCaption_gLbl)
            {
            }
            column(ItemDescriptionCaption_gLbl; ItemDescriptionCaption_gLbl)
            {
            }
            column(ETACaption_gLbl; ETACaption_gLbl)
            {
            }
            column(ETDCaption_gLbl; ETDCaption_gLbl)
            {
            }
            column(AmountCaption_gLbl; AmountCaption_gLbl)
            {
            }
            column(ContainerNoCaption_gLbl; ContainerNoCaption_gLbl)
            {
            }
            column(VendorPostingGroupCaption_gLbl; VendorPostingGroupCaption_gLbl)
            {
            }
        }

        dataitem(Container; "trm Container")
        {
            column(MainAreaIndicator; 1)
            {
            }
            column(No; "No.")
            {
            }
            column(Container_ContainerID; "Container ID")
            {
            }
            column(Container_Description; Description)
            {
            }
            column(Container_Description2; "Description 2")
            {
            }
            column(Container_DDNEffectiveShipmentDate; "DDN Effective Shipment Date")
            {
            }
            column(Container_DDNEstimatedDateReady; "DDN Estimated Date Ready")
            {
            }
            column(Container_DDNRequestedShipmentDate; "DDN Requested Shipment Date")
            {
            }
            column(Container_TransitPercent; TransitPercent)
            {
            }
            column(Container_TransitStartDate; FormatedTransitStartDate)
            { }
            column(Container_TransitEndDate; FormatedTransitEndDate)
            { }
            column(Container_Posting_Date; "Posting Date")
            {
            }
            column(Container_ContainerDetail; ContainerDetail)
            { }
            column(Container_OnBoard; OnBoard)
            { }
            column(Status; Status)
            {
            }

            dataitem(ContainerContentDataItem; "trm Temp Container Content")
            {
                DataItemTableView = sorting("Line No.");
                UseTemporary = true;
                column(ContainerContent_Description; Description) { }
                column(ContainerContent_Description2; "Description 2") { }
                column(ContainerContent_OutstandingQuantity; "Outstanding Quantity") { }
                column(ContainerContent_OutstandingAmountLcy; "Outstanding Amount (LCY)") { }
                column(ContainerContent_DocumentNo; "Document No.") { }
                column(ContainerContent_DocumentLineNo; "Line No.") { }
                column(ContainerContent_LinkToDocument; LinkToDocument()) { }
                column(RelatedPurchLine_gRec_Buy_from_Vendor_No; RelatedPurchLine_gRec."Buy-from Vendor No.")
                {
                }
                column(RelatedItem_gRec_No; RelatedItem_gRec."No.")
                {
                }
                column(RelatedItem_gRec_Description; RelatedItem_gRec.Description)
                {
                }
                column(RelatedPurchLine_gRec_Expected_Receipt_Date; RelatedPurchLine_gRec."Expected Receipt Date")
                {
                }
                column(Vendor_Vendor_Posting_Group; Vendor_gRec."Vendor Posting Group")
                {
                }

                trigger OnPreDataItem()
                var
                begin
                    generateTempContainerContent(Container, ContainerContentDataItem);
                end;

                trigger OnAfterGetRecord()
                var
                    Temp_lDec: Decimal;
                begin
                    if not RelatedPurchLine_gRec.Get(RelatedPurchLine_gRec."Document Type"::Order, "Document No.", "Line No.") then
                        Clear(RelatedPurchLine_gRec);
                    if not Vendor_gRec.Get(RelatedPurchLine_gRec."Buy-from Vendor No.") then
                        Clear(Vendor_gRec);

                    if not RelatedItem_gRec.Get(RelatedPurchLine_gRec."No.") then
                        Clear(RelatedItem_gRec);

                    if VendPostGrpSumBuffer_gDtn.ContainsKey(Vendor_gRec."Vendor Posting Group") then begin
                        Temp_lDec := VendPostGrpSumBuffer_gDtn.Get(Vendor_gRec."Vendor Posting Group");
                        VendPostGrpSumBuffer_gDtn.Set(Vendor_gRec."Vendor Posting Group", Temp_lDec + "Outstanding Amount (LCY)");
                    end else begin
                        VendPostGrpSumBuffer_gDtn.Add(Vendor_gRec."Vendor Posting Group", "Outstanding Amount (LCY)");
                    end;

                    TotalSum_gDec += "Outstanding Amount (LCY)";
                end;
            }


            trigger OnPreDataItem()
            begin
                Container.setfilter("Attached to Container No.", '''''');
            end;

            trigger OnAfterGetRecord() // Container
            var
                TotalDaysInTransit: Integer;
                DaysElapsedUntilNow: Integer;
            begin
                if Container.InTransitOnShip then
                    OnBoard := 1
                else
                    OnBoard := 0;
                clear(TransitPercent);
                clear(formatedTransitStartDate);
                clear(formatedTransitEndDate);
                clear(ContainerDetail);

                transitStartDate := Container."Actual Shipment Date";
                if TransitStartDate = 0D then
                    TransitStartDate := Container."Update Shipment Date";
                transitEndDate := Container."Actual Receipt Date";
                if transitEndDate = 0D then
                    TransitEndDate := Container."Update Receipt Date";
                if TransitStartDate = 0D then
                    formatedTransitStartDate := '?'
                else
                    formatedTransitStartDate := format(transitStartDate, 0, 0);

                if TransitStartDate = 0D then
                    formatedTransitEndDate := '?'
                else
                    formatedTransitEndDate := format(transitEndDate, 0, 0);

                ContainerDetail := strsubstno('TransitStartDate %1, TransitEndDate %2', TransitStartDate, TransitEndDate);
                if (TransitStartDate <> 0D) and (TransitEndDate <> 0D) then begin
                    TotalDaysInTransit := TransitEndDate - TransitStartDate;
                    DaysElapsedUntilNow := WorkDate() - TransitStartDate;

                    ContainerDetail += strsubstno(' DaysElapsedUntilNow %1, TotalDaysInTransit %2', DaysElapsedUntilNow, TotalDaysInTransit);
                    if (DaysElapsedUntilNow <= 0) or (TotalDaysInTransit <= 0) then
                        TransitPercent := 0
                    else
                        // 7 Tage seit Beginn, 28 Tage Gesamtzeit
                        TransitPercent := 100 / (TotalDaysInTransit / DaysElapsedUntilNow);
                end;

                Clear(VendPostGrpSumBuffer_gDtn);
                Clear(TotalSum_gDec);
            end;
        } // Container
        dataitem(SumsArea; Integer)
        {
            DataItemTableView = sorting(Number);

            column(SumsAreaIndicator; 1)
            {
            }

            column(SumLineNo; Number)
            {
            }

            column(SumVendorPostingGroup_gCod; SumVendorPostingGroup_gCod)
            {
            }

            column(SumValueVendorPostingGroup_gDec; SumValueVendorPostingGroup_gDec)
            {
            }

            column(SumLineCaption_gTxt; SumLineCaption_gTxt)
            {
            }

            trigger OnPreDataItem() // SumsArea
            begin
                SetRange(Number, 0, VendPostGrpSumBuffer_gDtn.Count);
            end;

            trigger OnAfterGetRecord()
            begin
                if Number = 0 then begin
                    SumVendorPostingGroup_gCod := '';
                    SumValueVendorPostingGroup_gDec := TotalSum_gDec;
                end else begin
                    VendPostGrpSumBuffer_gDtn.Keys.Get(Number, SumVendorPostingGroup_gCod);
                    VendPostGrpSumBuffer_gDtn.Values.Get(Number, SumValueVendorPostingGroup_gDec);
                end;

                SumLineCaption_gTxt := StrSubstNo(SumLineCaption_gLbl, SumVendorPostingGroup_gCod);
            end;
        } // SumsArea
    }

    rendering
    {
        layout(sexy)
        {
            Type = RDLC;
            Caption = 'hübsch aufbereitet';
            LayoutFile = 'Src/Purchase/Reports/Rep51000.DDNIncomingContainers.rdl';
        }
        layout(ExcelPrepared)
        {
            Type = RDLC;
            Caption = 'Excel prepared Layout';
            LayoutFile = 'Src/Purchase/Reports/Rep51000.DDNIncomingContainersExcelPrepared.rdl';
        }
    }
    var
        OnBoard: Integer;
        ContainerDetail: Text;
        TransitPercent: Decimal;
        TransitStartDate: Date;
        TransitEndDate: Date;
        formatedTransitStartDate: Text;
        formatedTransitEndDate: Text;
        PurchLineTemp: Record "Purchase Line" temporary;
        PurchInvLineTemp: Record "Purch. Inv. Line" temporary;
        SalesLineTemp: Record "Sales Line" temporary;
        SalesInvLineTemp: Record "Sales Invoice Line" temporary;
        TransferLineTemp: Record "Transfer Line" temporary;
        TransferReceiptLineTemp: Record "Transfer Receipt Line" temporary;
        TempContainerContentSelect: Record "trm Temp Container Cont Select" temporary;
        PickLineTemp: Record "trm Pick Document Line" temporary;
        PostedPickLineTemp: Record "trm Posted Pick Document Line" temporary;

        RelatedPurchLine_gRec: Record "Purchase Line";
        RelatedItem_gRec: Record Item;
        Vendor_gRec: Record Vendor;
        TotalSum_gDec: Decimal;
        SumValueVendorPostingGroup_gDec: Decimal;
        SumVendorPostingGroup_gCod: Code[20];
        SumLineCaption_gTxt: Text;
        VendPostGrpSumBuffer_gDtn: Dictionary of [Code[20], Decimal];
        PurchOrderNoCaption_gLbl: Label 'Purchase Order No.';
        VendorNoCaption_gLbl: Label 'Vendor No.';
        FreightContainerIDCaption_gLbl: Label 'Freight Container ID';
        PurchOrderLineNoCaption_gLbl: Label 'Purchase Order Line No.';
        QuantityCaption_gLbl: Label 'Quantity';
        StatusCaption_gLbl: Label 'Status';
        ItemNoCaption_gLbl: Label 'Item No.';
        ItemDescriptionCaption_gLbl: Label 'Item Description';
        ETACaption_gLbl: Label 'ETA';
        ETDCaption_gLbl: Label 'ETD';
        AmountCaption_gLbl: Label 'Amount (LCY)';
        ContainerNoCaption_gLbl: Label 'Container No.';
        SumLineCaption_gLbl: Label 'Sum %1';
        VendorPostingGroupCaption_gLbl: Label 'Vendor Posting Group';

    local procedure LinkToDocument() ret_text: text
    var
        p: Page "Purchase Order";
        PurchaseHEader_lRec: Record "Purchase Header";
    begin
        PurchaseHEader_lRec.setrange("No.", ContainerContentDataItem."Document No.");
        if PurchaseHEader_lRec.FindFirst() then
            exit(geturl(CLIENTTYPE::Web, COMPANYNAME, OBJECTTYPE::Page, PAGE::"Purchase Order", PurchaseHEader_lRec, true));
    end;

    procedure generateTempContainerContent(var container_par: Record "trm Container"; var tempContainerContent_loc: Record "trm Temp Container Content" temporary)
    var
        //tempContainerContent_loc: Record "trm Temp Container Content" temporary;
        tempContainerContent2_loc: Record "trm Temp Container Content" temporary;
        transferReceiptLine_loc: Record "Transfer Receipt Line";
        customer_loc: Record Customer;
        vendor_loc: Record Vendor;
    begin
        PurchLineTemp.DeleteAll;
        PurchInvLineTemp.DeleteAll;
        PurchInvLineTemp.DeleteAll;
        SalesLineTemp.DeleteAll;
        SalesInvLineTemp.DeleteAll;
        TransferLineTemp.DeleteAll;
        TransferReceiptLineTemp.DeleteAll;
        tempContainerContent_loc.DeleteAll;
        ContainerContent(container_par);
        if not PurchLineTemp.IsEmpty then begin
            PurchLineTemp.FindFirst;
            repeat
                vendor_loc.Get(PurchLineTemp."Buy-from Vendor No.");
                Clear(tempContainerContent_loc);
                tempContainerContent_loc."Container No." := container_par."No.";
                tempContainerContent_loc.Origin := tempContainerContent_loc.Origin::"Purchase Order";
                tempContainerContent_loc."Document No." := PurchLineTemp."Document No.";
                tempContainerContent_loc."Line No." := PurchLineTemp."Line No.";
                case PurchLineTemp."trm Type" of
                    PurchLineTemp."trm type"::Item:
                        tempContainerContent_loc.Type := tempContainerContent_loc.Type::Item;
                    PurchLineTemp."trm type"::Matrix:
                        tempContainerContent_loc.Type := tempContainerContent_loc.Type::Matrix;
                    PurchLineTemp."trm type"::"Assortment Matrix":
                        tempContainerContent_loc.Type := tempContainerContent_loc.Type::"Assortment Matrix";
                end;
                tempContainerContent_loc."No." := PurchLineTemp."trm No.";
                tempContainerContent_loc."Location Code" := PurchLineTemp."Location Code";
                tempContainerContent_loc."Expected Receipt/Shipment Date" := PurchLineTemp."Expected Receipt Date";
                tempContainerContent_loc.Description := PurchLineTemp.Description;
                tempContainerContent_loc."Description 2" := PurchLineTemp."Description 2";
                tempContainerContent_loc."Unit of Measure Code" := PurchLineTemp."Unit of Measure Code";
                tempContainerContent_loc.Quantity := PurchLineTemp.Quantity;
                tempContainerContent_loc."Outstanding Quantity" := PurchLineTemp."Outstanding Quantity";
                tempContainerContent_loc."Shipped Quantity" := 0;
                tempContainerContent_loc."Received Quantity" := PurchLineTemp."Quantity Received";
                tempContainerContent_loc."Expand Matrix" := PurchLineTemp."trm Expand Matrix";
                tempContainerContent_loc."Hide Line" := PurchLineTemp."trm Hide Line";
                tempContainerContent_loc."Master No." := PurchLineTemp."trm Master No.";
                tempContainerContent_loc.Matrix := PurchLineTemp."trm Matrix";
                tempContainerContent_loc."Actual Container No." := PurchLineTemp."trm Container No.";
                tempContainerContent_loc."Vendor No./Customer No." := vendor_loc."No.";
                tempContainerContent_loc.Name := vendor_loc.Name;
                // BEtrag errechnen

                tempContainerContent_loc."Outstanding Amount (LCY)" := PurchLineTemp."Outstanding Amt. Ex. VAT (LCY)";
                tempContainerContent_loc.Insert;
            until PurchLineTemp.Next = 0;
        end;
        if not PurchInvLineTemp.IsEmpty then begin
            PurchInvLineTemp.FindFirst;
            repeat
                vendor_loc.Get(PurchInvLineTemp."Buy-from Vendor No.");
                Clear(tempContainerContent_loc);
                tempContainerContent_loc."Container No." := container_par."No.";
                tempContainerContent_loc.Origin := tempContainerContent_loc.Origin::"Purchase Order";
                tempContainerContent_loc."Document No." := PurchInvLineTemp."trm Original Order No.";
                tempContainerContent_loc."Line No." := PurchInvLineTemp."trm Original Line No.";
                tempContainerContent_loc."Invoice No." := PurchInvLineTemp."Document No.";
                case PurchInvLineTemp."trm Type" of
                    PurchInvLineTemp."trm type"::Item:
                        tempContainerContent_loc.Type := tempContainerContent_loc.Type::Item;
                    PurchInvLineTemp."trm type"::Matrix:
                        tempContainerContent_loc.Type := tempContainerContent_loc.Type::Matrix;
                    PurchInvLineTemp."trm type"::"Assortment Matrix":
                        tempContainerContent_loc.Type := tempContainerContent_loc.Type::"Assortment Matrix";
                end;
                tempContainerContent_loc."No." := PurchInvLineTemp."trm No.";
                tempContainerContent_loc."Location Code" := PurchInvLineTemp."Location Code";
                tempContainerContent_loc."Expected Receipt/Shipment Date" := PurchInvLineTemp."Expected Receipt Date";
                tempContainerContent_loc.Description := PurchInvLineTemp.Description;
                tempContainerContent_loc."Description 2" := PurchInvLineTemp."Description 2";
                tempContainerContent_loc."Unit of Measure Code" := PurchInvLineTemp."Unit of Measure Code";
                tempContainerContent_loc.Quantity := PurchInvLineTemp.Quantity;
                tempContainerContent_loc."Outstanding Quantity" := 0;
                tempContainerContent_loc."Shipped Quantity" := 0;
                tempContainerContent_loc."Received Quantity" := PurchInvLineTemp.Quantity;
                tempContainerContent_loc."Expand Matrix" := PurchInvLineTemp."trm Expand Matrix";
                tempContainerContent_loc."Hide Line" := PurchInvLineTemp."trm Hide Line";
                tempContainerContent_loc."Master No." := PurchInvLineTemp."trm Master No.";
                tempContainerContent_loc.Matrix := PurchInvLineTemp."trm Matrix";
                tempContainerContent_loc."Actual Container No." := PurchInvLineTemp."trm Container No.";
                tempContainerContent_loc."Vendor No./Customer No." := vendor_loc."No.";
                tempContainerContent_loc.Name := vendor_loc.Name;
                if not tempContainerContent_loc.Insert then
                    tempContainerContent_loc.Modify;
            until PurchInvLineTemp.Next = 0;
        end;
        if not SalesLineTemp.IsEmpty then begin
            SalesLineTemp.FindFirst;
            repeat
                customer_loc.Get(SalesLineTemp."Sell-to Customer No.");
                Clear(tempContainerContent_loc);
                tempContainerContent_loc."Container No." := container_par."No.";
                tempContainerContent_loc.Origin := tempContainerContent_loc.Origin::"Sales Order";
                tempContainerContent_loc."Document No." := SalesLineTemp."Document No.";
                tempContainerContent_loc."Line No." := SalesLineTemp."Line No.";
                case SalesLineTemp."trm Type" of
                    SalesLineTemp."trm type"::Item:
                        tempContainerContent_loc.Type := tempContainerContent_loc.Type::Item;
                    SalesLineTemp."trm type"::Matrix:
                        tempContainerContent_loc.Type := tempContainerContent_loc.Type::Matrix;
                    SalesLineTemp."trm type"::"Assortment Matrix":
                        tempContainerContent_loc.Type := tempContainerContent_loc.Type::"Assortment Matrix";
                end;
                tempContainerContent_loc."No." := SalesLineTemp."trm No.";
                tempContainerContent_loc."Location Code" := SalesLineTemp."Location Code";
                tempContainerContent_loc."Expected Receipt/Shipment Date" := SalesLineTemp."Shipment Date";
                tempContainerContent_loc.Description := SalesLineTemp.Description;
                tempContainerContent_loc."Description 2" := SalesLineTemp."Description 2";
                tempContainerContent_loc."Unit of Measure Code" := SalesLineTemp."Unit of Measure Code";
                tempContainerContent_loc.Quantity := SalesLineTemp.Quantity;
                tempContainerContent_loc."Outstanding Quantity" := SalesLineTemp."Outstanding Quantity";
                tempContainerContent_loc."Shipped Quantity" := SalesLineTemp."Quantity Shipped";
                tempContainerContent_loc."Received Quantity" := 0;
                tempContainerContent_loc."Expand Matrix" := SalesLineTemp."trm Expand Matrix";
                tempContainerContent_loc."Hide Line" := SalesLineTemp."trm Hide Line";
                tempContainerContent_loc."Master No." := SalesLineTemp."trm Master No.";
                tempContainerContent_loc.Matrix := SalesLineTemp."trm Matrix";
                tempContainerContent_loc."Actual Container No." := SalesLineTemp."trm Container No.";
                tempContainerContent_loc."Vendor No./Customer No." := customer_loc."No.";
                tempContainerContent_loc.Name := customer_loc.Name;
                tempContainerContent_loc.Insert;
            until SalesLineTemp.Next = 0;
        end;
        if not SalesInvLineTemp.IsEmpty then begin
            SalesInvLineTemp.FindFirst;
            repeat
                customer_loc.Get(SalesInvLineTemp."Sell-to Customer No.");
                Clear(tempContainerContent_loc);
                tempContainerContent_loc."Container No." := container_par."No.";
                tempContainerContent_loc.Origin := tempContainerContent_loc.Origin::"Sales Order";
                tempContainerContent_loc."Document No." := SalesInvLineTemp."trm Original Order No.";
                tempContainerContent_loc."Line No." := SalesInvLineTemp."trm Original Line No.";
                tempContainerContent_loc."Invoice No." := SalesInvLineTemp."Document No.";
                case SalesInvLineTemp."trm Type" of
                    SalesInvLineTemp."trm type"::Item:
                        tempContainerContent_loc.Type := tempContainerContent_loc.Type::Item;
                    SalesInvLineTemp."trm type"::Matrix:
                        tempContainerContent_loc.Type := tempContainerContent_loc.Type::Matrix;
                    SalesInvLineTemp."trm type"::"Assortment Matrix":
                        tempContainerContent_loc.Type := tempContainerContent_loc.Type::"Assortment Matrix";
                end;
                tempContainerContent_loc."No." := SalesInvLineTemp."trm No.";
                tempContainerContent_loc."Location Code" := SalesInvLineTemp."Location Code";
                tempContainerContent_loc."Expected Receipt/Shipment Date" := SalesInvLineTemp."Shipment Date";
                tempContainerContent_loc.Description := SalesInvLineTemp.Description;
                tempContainerContent_loc."Description 2" := SalesInvLineTemp."Description 2";
                tempContainerContent_loc."Unit of Measure Code" := SalesInvLineTemp."Unit of Measure Code";
                tempContainerContent_loc.Quantity := SalesInvLineTemp.Quantity;
                tempContainerContent_loc."Outstanding Quantity" := 0;
                tempContainerContent_loc."Shipped Quantity" := SalesInvLineTemp.Quantity;
                tempContainerContent_loc."Received Quantity" := 0;
                tempContainerContent_loc."Expand Matrix" := SalesInvLineTemp."trm Expand Matrix";
                tempContainerContent_loc."Hide Line" := SalesInvLineTemp."trm Hide Line";
                tempContainerContent_loc."Master No." := SalesInvLineTemp."trm Master No.";
                tempContainerContent_loc.Matrix := SalesInvLineTemp."trm Matrix";
                tempContainerContent_loc."Actual Container No." := SalesInvLineTemp."trm Container No.";
                tempContainerContent_loc."Vendor No./Customer No." := customer_loc."No.";
                tempContainerContent_loc.Name := customer_loc.Name;
                if not tempContainerContent_loc.Insert then
                    tempContainerContent_loc.Modify;
            until SalesInvLineTemp.Next = 0;
        end;
        if not TransferLineTemp.IsEmpty then begin
            TransferLineTemp.FindFirst;
            repeat
                Clear(tempContainerContent_loc);
                tempContainerContent_loc."Container No." := container_par."No.";
                tempContainerContent_loc.Origin := tempContainerContent_loc.Origin::"Transfer Order";
                tempContainerContent_loc."Document No." := TransferLineTemp."Document No.";
                tempContainerContent_loc."Line No." := TransferLineTemp."Line No.";
                case TransferLineTemp."trm Type" of
                    TransferLineTemp."trm type"::Item:
                        tempContainerContent_loc.Type := tempContainerContent_loc.Type::Item;
                    TransferLineTemp."trm type"::Matrix:
                        tempContainerContent_loc.Type := tempContainerContent_loc.Type::Matrix;
                    TransferLineTemp."trm type"::"Assortment Matrix":
                        tempContainerContent_loc.Type := tempContainerContent_loc.Type::"Assortment Matrix";
                end;
                tempContainerContent_loc.Type := TransferLineTemp."trm Type";
                tempContainerContent_loc."No." := TransferLineTemp."Item No.";
                tempContainerContent_loc."Location Code" := ' ';
                tempContainerContent_loc."Expected Receipt/Shipment Date" := TransferLineTemp."Receipt Date";
                tempContainerContent_loc.Description := TransferLineTemp.Description;
                tempContainerContent_loc."Description 2" := TransferLineTemp."Description 2";
                tempContainerContent_loc."Unit of Measure Code" := TransferLineTemp."Unit of Measure Code";
                tempContainerContent_loc.Quantity := TransferLineTemp.Quantity;
                tempContainerContent_loc."Outstanding Quantity" := TransferLineTemp."Outstanding Quantity";
                tempContainerContent_loc."Expand Matrix" := TransferLineTemp."trm Expand Matrix";
                tempContainerContent_loc."Hide Line" := TransferLineTemp."trm Hide Line";
                tempContainerContent_loc."Master No." := TransferLineTemp."trm Master No.";
                tempContainerContent_loc.Matrix := TransferLineTemp."trm Matrix";
                tempContainerContent_loc."Actual Container No." := TransferLineTemp."trm Container No.";
                tempContainerContent_loc."Shipped Quantity" := TransferLineTemp."Quantity Shipped";
                tempContainerContent_loc."Received Quantity" := TransferLineTemp."Quantity Received";
                if (TransferLineTemp."Qty. in Transit" = 0) and
                   (TransferLineTemp."Outstanding Quantity" = 0)
                then begin
                    transferReceiptLine_loc.Reset;
                    transferReceiptLine_loc.SetRange("Transfer Order No.", TransferLineTemp."Document No.");
                    transferReceiptLine_loc.SetRange("Line No.", TransferLineTemp."Line No.");
                    transferReceiptLine_loc.SetRange("trm Container No.", TransferLineTemp."trm Container No.");
                    if transferReceiptLine_loc.FindFirst then
                        tempContainerContent_loc."Invoice No." := transferReceiptLine_loc."Document No.";
                end;
                tempContainerContent_loc.Insert;
            until TransferLineTemp.Next = 0;
        end;
        if not TransferReceiptLineTemp.IsEmpty then begin
            TransferReceiptLineTemp.FindFirst;
            repeat
                Clear(tempContainerContent_loc);
                tempContainerContent_loc."Container No." := container_par."No.";
                tempContainerContent_loc.Origin := tempContainerContent_loc.Origin::"Transfer Order";
                tempContainerContent_loc."Document No." := TransferReceiptLineTemp."Document No.";
                tempContainerContent_loc."Line No." := TransferReceiptLineTemp."Line No.";
                tempContainerContent_loc.Type := tempContainerContent_loc.Type::Item;
                tempContainerContent_loc."No." := TransferReceiptLineTemp."Item No.";
                tempContainerContent_loc."Location Code" := ' ';
                tempContainerContent_loc."Expected Receipt/Shipment Date" := 0D;
                tempContainerContent_loc.Description := TransferReceiptLineTemp.Description;
                tempContainerContent_loc."Description 2" := TransferReceiptLineTemp."Description 2";
                tempContainerContent_loc."Unit of Measure Code" := TransferReceiptLineTemp."Unit of Measure Code";
                tempContainerContent_loc.Quantity := TransferReceiptLineTemp.Quantity;
                tempContainerContent_loc."Outstanding Quantity" := 0;
                tempContainerContent_loc."Shipped Quantity" := 0;
                tempContainerContent_loc."Received Quantity" := TransferReceiptLineTemp.Quantity;
                tempContainerContent_loc."Expand Matrix" := false;
                tempContainerContent_loc."Hide Line" := false;
                tempContainerContent_loc."Master No." := '';
                tempContainerContent_loc."Actual Container No." := TransferReceiptLineTemp."trm Container No.";
                tempContainerContent_loc.Insert;
            until TransferReceiptLineTemp.Next = 0;
        end;

        if not PickLineTemp.IsEmpty then begin
            PickLineTemp.FindFirst;
            repeat
                Clear(tempContainerContent_loc);
                tempContainerContent_loc."Container No." := container_par."No.";
                tempContainerContent_loc.Origin := tempContainerContent_loc.Origin::"Pick Document";
                tempContainerContent_loc."Document No." := PickLineTemp."Pick Document No.";
                tempContainerContent_loc."Line No." := PickLineTemp."Line No.";
                tempContainerContent_loc."No." := PickLineTemp."No.";
                case PickLineTemp.Type of
                    PickLineTemp.Type::Item:
                        tempContainerContent_loc.Type := tempContainerContent_loc.Type::Item;
                    PickLineTemp.Type::Matrix:
                        tempContainerContent_loc.Type := tempContainerContent_loc.Type::Matrix;
                    PickLineTemp.Type::"Assortment Matrix":
                        tempContainerContent_loc.Type := tempContainerContent_loc.Type::"Assortment Matrix";
                end;
                tempContainerContent_loc."Location Code" := PickLineTemp."Location Code";
                tempContainerContent_loc."Expected Receipt/Shipment Date" := 0D;
                tempContainerContent_loc.Description := PickLineTemp.Description;
                tempContainerContent_loc."Description 2" := PickLineTemp."Description 2";
                if PickLineTemp."Quantity Picked (Base)" = 0 then
                    tempContainerContent_loc.Quantity := PickLineTemp."Quantity to be Picked (Base)"
                else
                    tempContainerContent_loc.Quantity := PickLineTemp."Quantity Picked (Base)";
                tempContainerContent_loc."Outstanding Quantity" := 0;
                tempContainerContent_loc."Master No." := PickLineTemp."Master No.";
                tempContainerContent_loc."Actual Container No." := PickLineTemp."Container No.";
                tempContainerContent_loc.Insert;
            until PickLineTemp.Next = 0;
        end;
        if not PostedPickLineTemp.IsEmpty then begin
            PostedPickLineTemp.FindFirst;
            repeat
                Clear(tempContainerContent_loc);
                tempContainerContent_loc."Container No." := container_par."No.";
                tempContainerContent_loc.Origin := tempContainerContent_loc.Origin::"Pick Document";
                tempContainerContent_loc."Document No." := PostedPickLineTemp."Pick Document No.";
                tempContainerContent_loc."Line No." := PostedPickLineTemp."Line No.";
                case PostedPickLineTemp.Type of
                    PostedPickLineTemp.Type::Item:
                        tempContainerContent_loc.Type := tempContainerContent_loc.Type::Item;
                    PostedPickLineTemp.Type::Matrix:
                        tempContainerContent_loc.Type := tempContainerContent_loc.Type::Matrix;
                    PostedPickLineTemp.Type::"Assortment Matrix":
                        tempContainerContent_loc.Type := tempContainerContent_loc.Type::"Assortment Matrix";
                end;
                tempContainerContent_loc."No." := PostedPickLineTemp."No.";
                tempContainerContent_loc."Location Code" := PostedPickLineTemp."Location Code";
                tempContainerContent_loc."Expected Receipt/Shipment Date" := 0D;
                tempContainerContent_loc.Description := PostedPickLineTemp.Description;
                tempContainerContent_loc."Description 2" := PostedPickLineTemp."Description 2";
                tempContainerContent_loc.Quantity := PostedPickLineTemp."Quantity Picked (Base)";
                tempContainerContent_loc."Outstanding Quantity" := 0;
                tempContainerContent_loc."Master No." := PostedPickLineTemp."Master No.";
                tempContainerContent_loc."Invoice No." := PostedPickLineTemp."Document No.";
                tempContainerContent_loc."Actual Container No." := PostedPickLineTemp."Container No.";
                if not tempContainerContent_loc.Insert then
                    tempContainerContent_loc.Modify;
            until PostedPickLineTemp.Next = 0;
        end;

        if not tempContainerContent_loc.IsEmpty then begin
            tempContainerContent2_loc.Copy(tempContainerContent_loc, true);
            tempContainerContent_loc.SetRange(Type, tempContainerContent_loc.Type::Matrix, tempContainerContent_loc.Type::"Assortment Matrix");
            if tempContainerContent_loc.FindFirst then
                repeat
                    tempContainerContent2_loc.SetRange("Container No.", tempContainerContent_loc."Container No.");
                    tempContainerContent2_loc.SetRange(Origin, tempContainerContent_loc.Origin);
                    tempContainerContent2_loc.SetRange("Document No.", tempContainerContent_loc."Document No.");
                    tempContainerContent2_loc.SetRange(Type, tempContainerContent2_loc.Type::Item);
                    tempContainerContent2_loc.SetRange(Matrix, tempContainerContent_loc."Line No.");
                    if tempContainerContent2_loc.FindFirst then
                        repeat
                            tempContainerContent_loc.Quantity :=
                              tempContainerContent_loc.Quantity +
                              tempContainerContent2_loc.Quantity;
                            tempContainerContent_loc."Outstanding Quantity" :=
                              tempContainerContent_loc."Outstanding Quantity" +
                              tempContainerContent2_loc."Outstanding Quantity";
                            tempContainerContent_loc."Expected Receipt/Shipment Date" :=
                              tempContainerContent2_loc."Expected Receipt/Shipment Date";
                            tempContainerContent_loc."Location Code" :=
                              tempContainerContent2_loc."Location Code";
                        until tempContainerContent2_loc.Next = 0;
                    tempContainerContent_loc.Modify;
                until tempContainerContent_loc.Next = 0;
        end;

        tempContainerContent_loc.Reset;
        //Page.RunModal(Page::"trm Temp Container Content", tempContainerContent_loc);
        //if not confirm('BBB Container %1 enthält %2 Zeilen Content', true, Container."No.", tempContainerContent_loc.Count()) then
        //    error('')

    end;


    procedure ContainerContent(var container_par: Record "trm Container")
    var
        purchLine_loc: Record "Purchase Line";
        container_loc: Record "trm Container";
        container2_loc: Record "trm Container";
        container3_loc: Record "trm Container";
        container4_loc: Record "trm Container";
        container5_loc: Record "trm Container";
        InventorySetup: Record "Inventory Setup";
        ConvertEnum: Codeunit "trm Convert Enum";
    begin
        InventorySetup.Get;
        TempContainerContentSelect.DeleteAll;
        PurchLineTemp.DeleteAll;
        SalesLineTemp.DeleteAll;
        TransferLineTemp.DeleteAll;
        PickLineTemp.DeleteAll;
        PostedPickLineTemp.DeleteAll;


        ConvertEnum.PurchDocTypeToContainerDocType(purchLine_loc."Document Type", TempContainerContentSelect."Document Type");
        TempContainerContentSelect."No." := container_par."No.";
        TempContainerContentSelect.Insert;

        container_loc.SetRange("Attached to Container No.", container_par."No.");
        if container_loc.FindFirst then
            repeat
                TempContainerContentSelect."Document Type" := TempContainerContentSelect."document type"::Container;
                TempContainerContentSelect."No." := container_loc."No.";
                TempContainerContentSelect.Insert;
                container2_loc.SetRange("Attached to Container No.", container_loc."No.");
                if container2_loc.FindFirst then
                    repeat
                        TempContainerContentSelect."Document Type" := TempContainerContentSelect."document type"::Container;
                        TempContainerContentSelect."No." := container2_loc."No.";
                        TempContainerContentSelect.Insert;
                        container3_loc.SetRange("Attached to Container No.", container2_loc."No.");
                        if container3_loc.FindFirst then
                            repeat
                                TempContainerContentSelect."Document Type" := TempContainerContentSelect."document type"::Container;
                                TempContainerContentSelect."No." := container3_loc."No.";
                                TempContainerContentSelect.Insert;
                                container4_loc.SetRange("Attached to Container No.", container3_loc."No.");
                                if container4_loc.FindFirst then
                                    repeat
                                        TempContainerContentSelect."Document Type" := TempContainerContentSelect."document type"::Container;
                                        TempContainerContentSelect."No." := container4_loc."No.";
                                        TempContainerContentSelect.Insert;
                                        container5_loc.SetRange("Attached to Container No.", container4_loc."No.");
                                        if container5_loc.FindFirst then
                                            repeat
                                                TempContainerContentSelect."Document Type" := TempContainerContentSelect."document type"::Container;
                                                TempContainerContentSelect."No." := container5_loc."No.";
                                                TempContainerContentSelect.Insert;
                                            until container5_loc.Next = 0;
                                    until container4_loc.Next = 0;
                            until container3_loc.Next = 0;
                    until container2_loc.Next = 0;
            until container_loc.Next = 0;

        case container_par.Type of
            container_par.Type::Inbound:
                begin
                    TempContainerContentSelect.Reset;
                    if TempContainerContentSelect.FindFirst then
                        repeat
                            Insert_PurchLineTemp(TempContainerContentSelect."No.");
                        until TempContainerContentSelect.Next = 0;
                end;
            container_par.Type::Outbound:
                begin
                    TempContainerContentSelect.Reset;
                    if TempContainerContentSelect.FindFirst then begin
                        case InventorySetup."trm Sales/Container Management" of
                            InventorySetup."trm sales/container management"::"Via Container Management":
                                repeat
                                    Insert_SalesLineTemp(TempContainerContentSelect."No.");
                                until TempContainerContentSelect.Next = 0;
                            InventorySetup."trm sales/container management"::"Via Pick":
                                repeat
                                    Insert_PickLineTemp(TempContainerContentSelect."No.");
                                until TempContainerContentSelect.Next = 0;
                        end;
                    end;
                end;
            container_par.Type::Transfer:
                begin
                    TempContainerContentSelect.Reset;
                    if TempContainerContentSelect.FindFirst then
                        repeat
                            Insert_TransferLineTemp(TempContainerContentSelect."No.");
                        until TempContainerContentSelect.Next = 0;
                end;
        end;

        case container_par.Type of
            container_par.Type::Inbound:
                begin
                    TempContainerContentSelect.Reset;
                    if TempContainerContentSelect.FindFirst then
                        repeat
                            Insert_PurchInvLineTemp(TempContainerContentSelect."No.");
                        until TempContainerContentSelect.Next = 0;
                end;
            container_par.Type::Outbound:
                begin
                    TempContainerContentSelect.Reset;
                    if TempContainerContentSelect.FindFirst then begin
                        case InventorySetup."trm Sales/Container Management" of
                            InventorySetup."trm sales/container management"::"Via Container Management":
                                repeat
                                    Insert_SalesInvLineTemp(TempContainerContentSelect."No.");
                                until TempContainerContentSelect.Next = 0;
                        end;
                    end;
                end
        end;
    end;

    local procedure Insert_PurchLineTemp(containerNo_par: Code[20])
    var
        purchLine_loc: Record "Purchase Line";
        purchLine2_loc: Record "Purchase Line";
    begin
        purchLine_loc.SetRange("trm Container No.", containerNo_par);
        if purchLine_loc.FindFirst then
            repeat
                Clear(PurchLineTemp);
                PurchLineTemp := purchLine_loc;
                PurchLineTemp.Insert;
                if PurchLineTemp."trm Matrix" > 0 then begin
                    purchLine2_loc.Get(purchLine_loc."Document Type", purchLine_loc."Document No.", purchLine_loc."trm Matrix");
                    PurchLineTemp := purchLine2_loc;
                    PurchLineTemp."trm Container No." := containerNo_par;
                    if PurchLineTemp.Insert then;
                end;
            until purchLine_loc.Next = 0;
    end;

    local procedure Insert_PurchInvLineTemp(containerNo_par: Code[20])
    var
        purchInvLine_loc: Record "Purch. Inv. Line";
        purchInvLine2_loc: Record "Purch. Inv. Line";
    begin
        purchInvLine_loc.SetRange("trm Container No.", containerNo_par);
        if purchInvLine_loc.FindFirst then
            repeat
                Clear(PurchInvLineTemp);
                PurchInvLineTemp := purchInvLine_loc;
                PurchInvLineTemp.Insert;
                if PurchInvLineTemp."trm Matrix" > 0 then begin
                    if purchInvLine2_loc.Get(purchInvLine_loc."Document No.", purchInvLine_loc."trm Matrix") then begin
                        PurchInvLineTemp := purchInvLine2_loc;
                        PurchInvLineTemp."trm Container No." := containerNo_par;
                        if PurchInvLineTemp.Insert then;
                    end;
                end;
            until purchInvLine_loc.Next = 0;
    end;

    local procedure Insert_SalesLineTemp(containerNo_par: Code[20])
    var
        salesline_loc: Record "Sales Line";
        salesLine2_loc: Record "Sales Line";
    begin
        salesline_loc.SetRange("trm Container No.", containerNo_par);
        if salesline_loc.FindFirst then
            repeat
                Clear(SalesLineTemp);
                SalesLineTemp := salesline_loc;
                SalesLineTemp.Insert;
                if SalesLineTemp."trm Matrix" > 0 then begin
                    salesLine2_loc.Get(salesline_loc."Document Type", salesline_loc."Document No.", salesline_loc."trm Matrix");
                    SalesLineTemp := salesLine2_loc;
                    SalesLineTemp."trm Container No." := containerNo_par;
                    if SalesLineTemp.Insert then;
                end;
            until salesline_loc.Next = 0;
    end;

    local procedure Insert_SalesInvLineTemp(containerNo_par: Code[20])
    var
        salesInvLine_loc: Record "Sales Invoice Line";
        salesInvLine2_loc: Record "Sales Invoice Line";
    begin
        salesInvLine_loc.SetRange("trm Container No.", containerNo_par);
        if salesInvLine_loc.FindFirst then
            repeat
                Clear(SalesInvLineTemp);
                SalesInvLineTemp := salesInvLine_loc;
                SalesInvLineTemp.Insert;
                if SalesInvLineTemp."trm Matrix" > 0 then begin
                    salesInvLine2_loc.Get(salesInvLine_loc."Document No.", salesInvLine_loc."trm Matrix");
                    SalesInvLineTemp := salesInvLine2_loc;
                    SalesInvLineTemp."trm Container No." := containerNo_par;
                    if SalesInvLineTemp.Insert then;
                end;
            until salesInvLine_loc.Next = 0;
    end;

    procedure Insert_TransferLineTemp(containerNo_par: Code[20])
    var
        transferLine_loc: Record "Transfer Line";
        transferLine2_loc: Record "Transfer Line";
        transferReceiptLine_loc: Record "Transfer Receipt Line";
    begin
        transferLine_loc.SetRange("trm Container No.", containerNo_par);
        transferLine_loc.SetRange("Derived From Line No.", 0);
        if transferLine_loc.FindFirst then
            repeat
                Clear(TransferLineTemp);
                TransferLineTemp := transferLine_loc;
                TransferLineTemp.Insert;
                if TransferLineTemp."trm Matrix" > 0 then begin
                    transferLine2_loc.Get(transferLine_loc."Document No.", transferLine_loc."trm Matrix");
                    TransferLineTemp := transferLine2_loc;
                    TransferLineTemp."trm Container No." := containerNo_par;
                    if TransferLineTemp.Insert then;
                end;
            until transferLine_loc.Next = 0;

        transferReceiptLine_loc.SetRange("trm Container No.", containerNo_par);
        transferReceiptLine_loc.SetFilter(Quantity, '>%1', 0);
        if transferReceiptLine_loc.FindFirst then
            repeat
                Clear(TransferReceiptLineTemp);
                TransferReceiptLineTemp := transferReceiptLine_loc;
                if not transferLine_loc.Get(transferReceiptLine_loc."Transfer Order No.", transferReceiptLine_loc."Line No.") then
                    TransferReceiptLineTemp.Insert;
            until transferReceiptLine_loc.Next = 0;
    end;

    local procedure Insert_PickLineTemp(containerNo_par: Code[20])
    var
        pickLine_loc: Record "trm Pick Document Line";
        postedPickLine_loc: Record "trm Posted Pick Document Line";
    begin
        pickLine_loc.SetRange("Container No.", containerNo_par);
        pickLine_loc.SetRange(Posted, false);
        if pickLine_loc.FindFirst then
            repeat
                Clear(PickLineTemp);
                PickLineTemp := pickLine_loc;
                PickLineTemp.Insert;
            until pickLine_loc.Next = 0;

        postedPickLine_loc.SetRange("Container No.", containerNo_par);
        if postedPickLine_loc.FindFirst then
            repeat
                Clear(PostedPickLineTemp);
                PostedPickLineTemp := postedPickLine_loc;
                PostedPickLineTemp.Insert;
            until postedPickLine_loc.Next = 0;
    end;

}
