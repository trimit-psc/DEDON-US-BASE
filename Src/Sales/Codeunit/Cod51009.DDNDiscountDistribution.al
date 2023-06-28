/// <summary>
/// <see cref="#LZ4G"/>
/// </summary>
codeunit 51009 "DDN Discount Distribution"
{
    procedure DistributeDiscountToOtherSalesLines_lFunc(var SalesLineDiscComOrder_vlRec: Record "trm Sales Line Disc Comb Order")
    var
        LineDiscCombinationHandling_lCod: Codeunit "trm Line Discount Combin Hand";
        SalesLine_lRec: Record "Sales Line";
        SourceSalesLine_lRec: Record "Sales Line";
        SalesLineDiscountType_lRec: Record "trm Sales Line Discount Type";
        DestinationSalesLineDiscComOrder_lRec: Record "trm Sales Line Disc Comb Order";
        ApplyDiscountToOtherLines_lLbl: Label 'Do you want to apply the discount to %1 other lines?';
        ToManyLinesError_lLbl: Label 'There are too many lines that will me modified. That looks like a bug. Please contact your IT-Department to help us solve that bug.';
        EntryNo_lInt: Integer;
    begin
        if not SalesLineDiscountType_lRec.get(SalesLineDiscComOrder_vlRec."Line Discount Type") then
            exit;
        // pro Auftragszeile
        SalesLine_lRec.SetRange("Document Type", SalesLineDiscComOrder_vlRec."Sales Document Type");
        SalesLine_lRec.setrange("Document No.", SalesLineDiscComOrder_vlRec."Sales Document No.");
        SalesLine_lRec.setfilter("Line No.", '<>%1', SalesLineDiscComOrder_vlRec."Sales Document Entry No.");
        SalesLine_lRec.SetRange(Type, SalesLine_lRec.Type::Item);
        if SalesLine_lRec.count > 500 then
            error(ToManyLinesError_lLbl);

        SourceSalesLine_lRec.Get(SalesLineDiscComOrder_vlRec."Sales Document Type", SalesLineDiscComOrder_vlRec."Sales Document No.", SalesLineDiscComOrder_vlRec."Sales Document Entry No.");
        case SalesLineDiscountType_lRec."DDN Discount Distrib. Filter" of
            SalesLineDiscountType_lRec."DDN Discount Distrib. Filter"::"Item No.":
                SalesLine_lRec.SetRange("No.", SourceSalesLine_lRec."No.");
            SalesLineDiscountType_lRec."DDN Discount Distrib. Filter"::"Master No.":
                SalesLine_lRec.SetRange("trm Master No.", SourceSalesLine_lRec."trm Master No.");
            SalesLineDiscountType_lRec."DDN Discount Distrib. Filter"::"Set Master No.":
                SalesLine_lRec.SetRange("DDN Set Master No.", SourceSalesLine_lRec."DDN Set Master No.");
            SalesLineDiscountType_lRec."DDN Discount Distrib. Filter"::" ":
                exit;
        end;

        if SalesLine_lRec.IsEmpty then
            exit;
        if not confirm(ApplyDiscountToOtherLines_lLbl, true, SalesLine_lRec.Count) then
            exit;

        if SalesLine_lRec.FindSet() then
            repeat
                // ggf Anlage einer Zeile
                DestinationSalesLineDiscComOrder_lRec.SetRange("Sales Document Type", SalesLine_lRec."Document Type");
                DestinationSalesLineDiscComOrder_lRec.SetRange("Sales Document No.", SalesLine_lRec."Document No.");
                DestinationSalesLineDiscComOrder_lRec.setrange("Sales Document Entry No.", SalesLine_lRec."Line No.");

                if DestinationSalesLineDiscComOrder_lRec.findlast then begin
                    EntryNo_lInt := DestinationSalesLineDiscComOrder_lRec."Entry No.";
                end;
                EntryNo_lInt += 10000;
                DestinationSalesLineDiscComOrder_lRec.setrange("Line Discount Type", SalesLineDiscComOrder_vlRec."Line Discount Type");
                if not DestinationSalesLineDiscComOrder_lRec.FindFirst() then begin
                    DestinationSalesLineDiscComOrder_lRec."Sales Document Type" := SalesLine_lRec."Document Type";
                    DestinationSalesLineDiscComOrder_lRec."Sales Document No." := SalesLine_lRec."Document No.";
                    DestinationSalesLineDiscComOrder_lRec."Sales Document Entry No." := SalesLine_lRec."Line No.";

                    DestinationSalesLineDiscComOrder_lRec."Entry No." := EntryNo_lInt;
                    DestinationSalesLineDiscComOrder_lRec.insert(true);
                end;
                DestinationSalesLineDiscComOrder_lRec.TransferFields(SalesLineDiscComOrder_vlRec, false);
                DestinationSalesLineDiscComOrder_lRec.modify();
                // Aufruf zur Berechnung wie beim Aufruf der Page
                LineDiscCombinationHandling_lCod.Set_SkipShowForm(true);
                LineDiscCombinationHandling_lCod.EditLineDiscounts(SalesLine_lRec);
            until SalesLine_lRec.Next() = 0;
    end;
}
