
/// <summary>
/// <see cref="#Q84K"/>
/// </summary>
codeunit 51018 "COR-DDN availibility Batch"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'Replaced by DEDON DSDS';
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        CalcAvailibility();
    end;

    procedure CalcAvailibility()
    var
        availibilityTools: Codeunit "DDN Availibility Tools";
        SalesLine: Record "Sales Line";
        CountModifiedLines: Integer;
    begin
        SalesLine.SetRange(Type, SalesLine.Type::item);
        SalesLine.setrange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.setfilter("Outstanding Qty. (Base)", '>0');
        if SalesLine.findset then
            repeat
                if availibilityTools.CalcAvailibilityObsolete_gFnc(SalesLine, true) then
                    CountModifiedLines += 1;
            until SalesLine.Next() = 0;
        if GuiAllowed then
            message('%1 Verfügbarkeiten wurden aktualisiert.', CountModifiedLines);

    end;


}
