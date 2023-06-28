/// <summary>
/// Komfortfunktion für das Bearbeiten von Verkaufsaufträgen bei Terminverschiebungen
/// Anforderung [B-080]
/// <see cref="#D5C7"/>
/// </summary>
page 51001 "DDN Availibility Crosscheck"
{
    Caption = 'DEDON Availibility Crosscheck';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Sales Line";
    SourceTableView = where("Document Type" = const(Order), Type = const(Item), "Outstanding Qty. (Base)" = filter('>0'), "No." = filter('<>UNKNOWN'));
    //Editable = false;
    InsertAllowed = false;
    ModifyAllowed = true;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(DocumentNo; Rec."Document No.")
                {
                    ApplicationArea = All;
                    DrillDown = true;
                    editable = false;


                    trigger OnDrillDown();
                    var
                        salesHeader_lRec: Record "Sales Header";
                    begin
                        salesHeader_lRec.get(Rec."Document Type", rec."Document No.");
                        Page.run(page::"Sales Order", salesHeader_lRec);
                    end;
                }
                field("Special Order"; Rec."Special Order")
                {
                    ApplicationArea = All;
                    editable = false;
                }

                field(OrderReleased; Rec."DDN Order Released")
                {
                    ApplicationArea = All;
                    width = 5;
                    editable = false;
                }
                field(Name; Rec."No.")
                {
                    ApplicationArea = All;
                    editable = false;
                }
                field("COR-DDN Respons. Person Code"; Rec."COR-DDN Respons. Person Code")
                {
                    ApplicationArea = All;
                    editable = false;
                }
                field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
                {
                    ApplicationArea = All;
                    editable = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    editable = false;
                }
                field(Description2; Rec."Description 2")
                {
                    ApplicationArea = All;
                    editable = false;
                }
                field(OutstandingQuantity; Rec."Outstanding Quantity")
                {
                    ApplicationArea = All;
                    editable = false;
                }
                field(ProcessingHintIcon; Rec."DDN Processing Hint Icon")
                {
                    ApplicationArea = All;
                    StyleExpr = ProcessingHintIconStyleExpr_gTxt;
                    width = 5;
                    editable = false;
                }
                field("DDN Processing Hint"; Rec."DDN Processing Hint")
                {
                    ApplicationArea = all;
                    width = 15;
                    StyleExpr = ProcessingHintIconStyleExpr_gTxt;
                    editable = false;
                }
                field(ErliestShipmentDate; Rec."trm Earliest Shipment Date")
                {
                    ApplicationArea = All;
                    Visible = false;
                    editable = false;
                }
                field(ErliestShipmentDateDedon; Rec."COR-DDN Earliest Shipment Date")
                {
                    ApplicationArea = All;
                    editable = false;
                }
                field(ShipmentDate; Rec."Shipment Date")
                {
                    ApplicationArea = All;
                    Style = Unfavorable;
                    StyleExpr = Rec."DDN Shipment Delayed";
                }
                field(ShipmentDelayed; Rec."DDN Shipment Delayed")
                {
                    ApplicationArea = all;
                    width = 5;
                    ToolTip = 'If the shipment date is before the calculated earliest dat then a sales line is marked as delayed.';
                    editable = false;
                }
                field("COR-DDN Availib. Modified Date"; Rec."COR-DDN Availib. Modified Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'If the earliest shipment date chages then you see the date on wich the latest change has been calculated.';
                    StyleExpr = modifiedToday_gBool;
                    Style = StandardAccent;
                    editable = false;
                }
                field("DDN-COR Date Conflict Action"; Rec."DDN-COR Date Conflict Action")
                {
                    ApplicationArea = All;
                    ToolTip = 'As soon as the system detects a conflict because the shipment date can''t be granted then the you get the information that you have to solve the conflict. Usually this is done by increasing shipment dates for the sales line and - maybe - also for other sales lines within the sales order to do a complete shipment.';
                    editable = false;
                }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action(CalculateAvailibility)
            {
                Caption = 'Calculate availibility';
                Image = RefreshLines;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                Visible = false;

                trigger OnAction();
                var
                    DDNAvailibilityTools_lCdu: Codeunit "DDN Availibility Tools";
                    countModifiedLines_lInt, countUnModifiedLines_lInt : Integer;
                    Act_lInt: Integer;
                    Ttl_lInt: Integer;
                    Status_gDlg: Dialog;
                    // %1 Vekraufszeilen wurden akutlaisiert
                    SummaryMessage_lLbl: Label 'New availabilities have been calculated for %1 sales lines. No changes have been calculated for %2 lines.';
                    //SalesLine: Record "Sales Line";
                    AvailibilityTool: Codeunit "DDN Availibility Tools";
                begin
                    Ttl_lInt := Rec.Count;
                    Status_gDlg.Open(Status_gLbl);

                    if Rec.findset() then begin
                        repeat
                            Act_lInt += 1;
                            Status_gDlg.Update(1, Rec."Document No.");

                            if DDNAvailibilityTools_lCdu.CalcAvailibilityObsolete_gFnc(Rec, true) then
                                countModifiedLines_lInt += 1
                            else
                                countUnModifiedLines_lInt += 1;
                        until Rec.Next() = 0;
                        Rec.FindFirst();
                    end;

                    Status_gDlg.Close();

                    message(SummaryMessage_lLbl, countModifiedLines_lInt, countUnModifiedLines_lInt);
                end;
            }

            action(CalculateAvailibilityViaDSDS)
            {
                Caption = 'Calculate availibility (DSDS)';
                Image = RefreshLines;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction();
                var
                    DSDSBatch: Codeunit "COR DSDS Batch";
                begin
                    DSDSBatch.CalcAvailibility();
                end;
            }

            action(UpdateShipmentDate)
            {
                Caption = 'Update Shipment Date';
                Image = CalendarChanged;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    SalesLineSelected_lRec: Record "Sales Line";
                    NoSelected_lInt: Integer;
                    Act_lInt: Integer;
                    AvailibilityTool: Codeunit "DDN Availibility Tools";
                begin
                    Clear(SalesLineSelected_lRec);
                    CurrPage.SetSelectionFilter(SalesLineSelected_lRec);
                    NoSelected_lInt := SalesLineSelected_lRec.Count;
                    if Confirm(UpdateShipmentDate_gLbl, true, Rec.FieldCaption("Shipment Date"), Rec.FieldCaption("trm Earliest Shipment Date"), NoSelected_lInt) then begin
                        AvailibilityTool.TransferEaliestShipmentDateToShipmentDate(SalesLineSelected_lRec);
                    end;
                end;
            }

            action("COR open DSDS Schedule")
            {
                ApplicationArea = All;
                Image = ItemAvailability;
                Caption = 'DSDS Schedule';

                trigger OnAction()
                var
                    dsdsAvailitbilityMgmt_lCodeUnit: Codeunit "COR DSDS Availibility Mgmt.";
                    Schedule_lPage: Page "COR DSDS Schedule Line";
                begin
                    Schedule_lPage.SetContext(Rec);
                    Schedule_lPage.Run();
                end;
            }

            action("COR calc earlises Shipment Date via DSDS Schedule")
            {
                ApplicationArea = All;
                Image = ChangeDate;
                Caption = 'Calculate earliest shipment date via DSDS';
                ToolTip = 'Calculates the earliest Shipment date based on the DSDS. If your sales line has not yet a priority then your priority is calculated before.';

                trigger OnAction()
                var
                    dsdsAvailitbilityMgmt_lCodeUnit: Codeunit "COR DSDS Availibility Mgmt.";
                    Schedule_lPage: Page "COR DSDS Schedule Line";
                begin
                    Rec.TestField(type, rec.type::item);
                    dsdsAvailitbilityMgmt_lCodeUnit.InitObject(Rec."No.", rec."Location Code");
                    dsdsAvailitbilityMgmt_lCodeUnit.SetFocusOnSalesLine(Rec);
                    dsdsAvailitbilityMgmt_lCodeUnit.QueueUnpriorisedSalesLine(Rec, true);
                    dsdsAvailitbilityMgmt_lCodeUnit.createSchedule();

                    Rec."COR-DDN earliest Shipment Date" := dsdsAvailitbilityMgmt_lCodeUnit.FindEarliestShipmentDateForSalesLine(Rec, true);
                    dsdsAvailitbilityMgmt_lCodeUnit.UpdateSalesLineWithKnowledeAboutShipment(rec);
                end;
            }
        }
    }



    var
        ProcessingHintIconStyleExpr_gTxt: Text[20];
        Status_gLbl: Label '#1#######################', Locked = true;
        UpdateShipmentDate_gLbl: Label 'Do you want to update the field %1 with %2 in %3 records?';
        modifiedToday_gBool: Boolean;

    trigger OnAfterGetRecord()
    var
        DDNSetup_lRec: Record "DDN Setup";
    begin
        ProcessingHintIconStyleExpr_gTxt := DDNSetup_lRec.GetIconStyle(Rec."DDN Processing Hint Icon");
        modifiedToday_gBool := WorkDate() = Rec."COR-DDN Availib. Modified Date";
    end;

    /// Filterung auf Lagerort
    /// <see cref="https://dedongroup.atlassian.net/browse/DEDT-571"/>
    trigger OnOpenPage()
    var
        ddnSetup_lRec: Record "DDN Setup";
    begin
        ddnSetup_lRec.get;
        Rec.SetRange("Location Code", ddnSetup_lRec."Location Code 1_WMS");
    end;
}