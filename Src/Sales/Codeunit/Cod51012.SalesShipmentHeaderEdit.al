/// <summary>
/// <see cref="#B9KS"/>
/// </summary>  

// same logic as codeunit 103 "Cust. Entry-Edit"

codeunit 51012 "Sales Shipment Header-Edit"
{
    Permissions = TableData "Sales Shipment Header" = m;
    TableNo = "Sales Shipment Header";

    trigger OnRun()
    begin
        SalesShptHeader_gRec := Rec;
        SalesShptHeader_gRec.LockTable();
        SalesShptHeader_gRec.Find;
        SalesShptHeader_gRec."Export certificate received" := Rec."Export certificate received";
        SalesShptHeader_gRec.Modify();

        Rec := SalesShptHeader_gRec;
    end;

    var
        SalesShptHeader_gRec: Record "Sales Shipment Header";
}

