/// <summary>
/// DEDT-329 Vorfiltern auf 1_WMS
/// </summary>
pageextension 51060 "COR-DDN Item Av. by Event" extends "Item Availability by Event"
{
    trigger OnOpenPage()
    var
        ddnSetup: Record "DDN Setup";
    begin
        ddnSetup.get();
        LocationFilter := ddnSetup."Location Code 1_WMS";
        // an dieser Stelle greift ein Workaround zur Filterung
        //ValidateItemNo();
        InitAndCalculatePeriodEntries();
    end;
}
