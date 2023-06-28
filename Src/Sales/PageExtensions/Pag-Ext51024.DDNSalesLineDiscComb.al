pageextension 51024 "DDN Sales Line Disc Comb" extends "trm Sales Line Disc Comb"
{
    trigger OnModifyRecord(): boolean
    var
        DiscountDistribution_lCod: Codeunit "DDN Discount Distribution";
    begin
        DiscountDistribution_lCod.DistributeDiscountToOtherSalesLines_lFunc(Rec);
    end;

    trigger OnInsertRecord(belowRec: Boolean): boolean
    var
        DiscountDistribution_lCod: Codeunit "DDN Discount Distribution";
    begin
        DiscountDistribution_lCod.DistributeDiscountToOtherSalesLines_lFunc(Rec);
    end;
}

