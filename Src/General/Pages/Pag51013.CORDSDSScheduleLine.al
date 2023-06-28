page 51013 "COR DSDS Schedule Line"
{
    Caption = 'COR DSDS Schedule Line';
    PageType = Worksheet;
    SourceTable = "COR DSDS Schedule Line";
    SourceTableTemporary = true;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {

            field(activePriorityModel; activePriorityModel)
            {
                ApplicationArea = All;
                Caption = 'Active Model';
                Editable = false;
            }
            repeater(General)
            {
                ShowAsTree = true;
                IndentationColumn = Rec.Indentation;
                IndentationControls = "Source No.";

                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    Editable = false;
                }
                field("assign to Entry No."; Rec."assigned to Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies to wich Entry a consumption is assigned.';
                    Visible = false;
                    Editable = false;
                }
                field(direction; Rec.direction)
                {
                    ApplicationArea = All;
                    ToolTip = 'Used to indicate if it is a line of consumption or a line increasing stock. Neutral lines are used for special purpose.';
                    Visible = false;
                    Editable = false;
                }
                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Type of the document';
                    Editable = false;
                }
                field("Focus Icon"; Rec."Focus Icon")
                {
                    ApplicationArea = All;
                    ToolTip = 'If you open the scheduler via sales line then the sales line you came from is highlighted with an arrow.';
                    width = 10;
                    Editable = false;
                }
                field("Source No."; Rec."Source No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Document No. of the purchase order or sales document';
                    Editable = false;
                    DrillDown = true;

                    trigger OnDrillDown()
                    var
                        SalesHeader: Record "Sales Header";
                        PurchaseHeader: Record "Purchase Header";
                    begin
                        case rec."Source Type" of
                            rec."Source Type"::"Sales Order":
                                begin
                                    SalesHeader.get(SalesHeader."Document Type"::Order, Rec."Source No.");
                                    Page.run(Page::"Sales Order", SalesHeader);
                                end;
                            rec."Source Type"::"Purchase Order":
                                begin
                                    PurchaseHeader.get(SalesHeader."Document Type"::Order, Rec."Source No.");
                                    Page.run(Page::"Purchase Order", PurchaseHeader);
                                end;
                        end;
                    end;
                }
                field("Customer / Vendor Name"; Rec."Customer / Vendor Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer / Vendor Name field.';
                    Editable = false;
                }

                field("Outgoing Priority"; Rec."Outgoing Priority")
                {
                    ApplicationArea = All;
                    ToolTip = 'This field is essential. It holds the priority that was either calculated by shipment date or by order date or by the priorities within the sales line itself.';
                    Editable = true;
                }
                field("Outstanding Quantity (Base)"; Rec."Outstanding Quantity (Base)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Quantitiy that has not yet been shipped or was not yet received';
                    Editable = false;
                }
                field("Unassigned Quantity (Base)"; Rec."Unassigned Quantity (Base)")
                {
                    ApplicationArea = All;
                    ToolTip = 'For Stock and purchase order you find the quantiy that has not been assigned by the scheduler. It is an aggregated view suming up all previous lines.';
                    BlankZero = true;
                    Editable = false;
                }
                field("Unassigned Qty. (Base) Entry"; Rec."Unassigned Qty. (Base) Entry")
                {
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'For Stock and purchase order you find the quantiy that has not been assigned by the scheduler. It might be occupied when new sales lines become created.';
                }
                field("aggregated balance"; Rec."aggregated balance")
                {
                    ApplicationArea = All;
                    ToolTip = 'Aggregates the quantity across all incoming Entries';
                    Editable = false;
                    visible = false;
                }

                field(Balance; Rec.Balance)
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the ongoing quantities.';
                    Editable = false;
                }
                field("Receipt/Shipment Date"; Rec."Receipt/Shipment Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Receipt date as it is within the purchase line or shipment date as it is in the sales line.';
                    StyleExpr = Rec."Shipment Date Conflict" = Rec."Shipment Date Conflict"::ShipmentDateTooEarly;
                    Style = Unfavorable;
                    Editable = false;
                }
                field("earliest shipment date"; Rec."earliest shipment date")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the calcualted date to wich you might ship. It highly depends on the priority and the quantites that might open gaps for smaller orders.';
                    Editable = false;
                }
                field("Shift-to Date"; Rec."Shift-to Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Within this date you suggest a shipment date to queue the sales document. It is not used as an earlies shipment date; though it might correlate!';
                    trigger OnValidate()
                    var
                    begin
                        SendShiftToDateToModel();
                    end;
                }

                field("calculated via Replenishment"; Rec."calculated via Replenishment")
                {
                    ApplicationArea = All;
                    ToolTip = 'if demand can''t be fullfilled anymore then the replenisment data is used as fallback.';
                }
            }
        }

        area(FactBoxes)
        {
            part(SalesLinePriorityFactBox; "COR DSDS SalesLines Prio")
            {
                Caption = 'Priority Queue';
                SubPageView = sorting("COR DSDS Priority");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(CalculationActions)
            {
                Caption = 'Data Calculation';
                Image = ChangeDates;

                action(ReconstrucWithPriorityByShipmentDate)
                {
                    ApplicationArea = All;
                    Caption = 'Priority by shipment date';
                    Promoted = true;
                    PromotedCategory = Process;
                    Image = Shipment;

                    trigger OnAction()
                    begin
                        ReconstrucWithPriorityByShipmentDate_lFunction();
                    end;
                }
                action(ReconstrucWithPriorityByShipmentDateRegardingShifts)
                {
                    ApplicationArea = All;
                    Caption = 'Priority by shipment date regarding shifts';
                    Promoted = true;
                    PromotedCategory = Process;
                    Image = Shipment;

                    trigger OnAction()
                    begin
                        ReconstrucWithPriorityByShipmentDateRegardingShifts_lFunction();
                    end;
                }
                action(ReconstrucWithPriorityOrderNo)
                {
                    ApplicationArea = All;
                    Caption = 'Priority by order number';
                    Promoted = true;
                    PromotedCategory = Process;
                    Image = OrderList;

                    trigger OnAction()
                    begin
                        ReconstrucWithPriorityByOrderNo_lFunction();
                    end;
                }
                action(ReconstrucWithPriorityIndividualiezd)
                {
                    ApplicationArea = All;
                    Caption = 'Priority according to sales line';
                    Image = ChangeDates;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        ConstrucWithPriorityByIndividualizedOrder_lFunction();
                    end;
                }
            }

            group(SalesLineActions)
            {
                Caption = 'Sales Line Interactions';

                action(TransferShiftToDateFromScheduleToSalesLineAction)
                {
                    ApplicationArea = All;
                    Caption = 'Transfer Shift-to Date to Sales Line';
                    Image = ChangeDates;

                    trigger OnAction()
                    begin
                        TransferShiftToDateFromScheduleToSalesLine_lFunction();
                    end;
                }
                action(TransferPriorityFromScheduleToSalesLine)
                {
                    ApplicationArea = All;
                    Caption = 'Transfer Priority to Sales lines';
                    Image = TransferToLines;

                    trigger OnAction()
                    begin
                        TransferPriorityFromScheduleToSalesLine_lFunction();
                    end;
                }

                action(UpdateSalesLinesWithKnowledeAboutShipmentAction)
                {
                    ApplicationArea = All;
                    Caption = 'Transfer Earliest Shipment date to Sales lines';
                    ToolTip = 'This function also creates processing hints for the CustomerService-Team to identify the lines that need to be reviewed.';
                    Image = TransferToLines;

                    trigger OnAction()
                    begin
                        UpdateSalesLinesWithKnowledeAboutShipment();
                    end;
                }

                action(VanishPriotiesInSalesLines)
                {
                    ApplicationArea = All;
                    Caption = 'Vanish Sales Line priority';
                    Image = Undo;

                    trigger OnAction()
                    begin
                        VanishPriotiesInSalesLines_lFunction();
                    end;
                }
                action(OpenCrossCheckPage)
                {
                    ApplicationArea = All;
                    Caption = 'Verfügbarkeitsprüfung Verkauf';
                    Ellipsis = true;
                    Image = Sales;

                    trigger OnAction()
                    begin
                        OpenAvailibilityCrosscheck();
                    end;
                }
            }
            group(SortingActions)
            {
                Caption = 'Sorting';
                Image = SortAscending;

                action(SortByEventAction)
                {
                    Caption = 'by Event';
                    Image = SortAscending;
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        SortByEvent();
                    end;
                }
                action(SortByDateAction)
                {
                    Caption = 'by Date';
                    Image = SortAscending;
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        SortByDate();
                    end;
                }
            }
        }
    }


    local procedure ReconstrucWithPriorityByShipmentDate_lFunction()
    var
    begin
        dsdsAvailibilityMgmt.createSchedule("COR DSDS Priority Model"::CalculatedByShipmentDate);
        refreshPage();
    end;

    local procedure ReconstrucWithPriorityByShipmentDateRegardingShifts_lFunction()
    var
    begin
        dsdsAvailibilityMgmt.createSchedule("COR DSDS Priority Model"::CalculatedByShipmentDateRegardingShifts);
        refreshPage();
    end;


    local procedure ReconstrucWithPriorityByOrderNo_lFunction()
    var
    begin
        dsdsAvailibilityMgmt.createSchedule("COR DSDS Priority Model"::CalculatedByOrderNo);
        refreshPage();
    end;

    /// <summary>
    /// Aufruf des Modells gem. Prioritäten im Auftrag
    /// </summary>
    local procedure ConstrucWithPriorityByIndividualizedOrder_lFunction()
    var
    begin
        dsdsAvailibilityMgmt.createSchedule("COR DSDS Priority Model"::fixedBySalesLinePriority);
        refreshPage();
    end;

    local procedure VanishPriotiesInSalesLines_lFunction()
    var
        ItemNo_lCod: Code[20];
        LocationCode_lCod: Code[20];
    begin
        ItemNo_lCod := Rec."Item No.";
        LocationCode_lCod := Rec."Location Code";
        dsdsAvailibilityMgmt.VanishPriority(ItemNo_lCod, LocationCode_lCod);
    end;

    local procedure TransferPriorityFromScheduleToSalesLine_lFunction()
    var
        NotifyModelChange_lNot: Notification;
        ModelChange_lLbl: Label 'The Model in your view changed from "%1" to "%2". "%1" ignores manual changes.';
        ModificationCount_lInt: Integer;
    begin
        if dsdsAvailibilityMgmt.TransferPriorityFromScheduleToSalesLine_lFunction(Rec, true) > 0 then begin
            if activePriorityModel <> activePriorityModel::fixedBySalesLinePriority then begin
                NotifyModelChange_lNot.Message := StrSubstNo(ModelChange_lLbl, activePriorityModel, activePriorityModel::fixedBySalesLinePriority);
                NotifyModelChange_lNot.Send();
            end;
            dsdsAvailibilityMgmt.createSchedule(activePriorityModel::fixedBySalesLinePriority);
            refreshPage();
        end;
    end;

    local procedure TransferShiftToDateFromScheduleToSalesLine_lFunction()
    var
        NotifyModelChange_lNot: Notification;
        ModelChange_lLbl: Label 'The Model in your view changed from "%1" to "%2". "%1" ignores manual changes.';
        NothingToChange_lLbl: Label 'Nothing had to be changed';
        ModificationCount_lInt: Integer;
        ConfirmTransferOfPriorityToSalesLine_lLbl: Label 'Do you also want to prpagate the priorities to the sales lines?';
        doPropagation_lBool: Boolean;
    begin
        doPropagation_lBool := confirm(ConfirmTransferOfPriorityToSalesLine_lLbl);
        if dsdsAvailibilityMgmt.TransferShiftToDateFromScheduleToSalesLine_lFunction(Rec, doPropagation_lBool = false) > 0 then begin
            if activePriorityModel <> activePriorityModel::CalculatedByShipmentDateRegardingShifts then begin
                NotifyModelChange_lNot.Message := StrSubstNo(ModelChange_lLbl, activePriorityModel, activePriorityModel::CalculatedByShipmentDateRegardingShifts);
                NotifyModelChange_lNot.Send();
            end;
            dsdsAvailibilityMgmt.createSchedule(activePriorityModel::CalculatedByShipmentDateRegardingShifts);

            if doPropagation_lBool then begin
                dsdsAvailibilityMgmt.TransferPriorityFromScheduleToSalesLine_lFunction(true);
            end;
            refreshPage();
        end
        else begin
            NotifyModelChange_lNot.Message := NothingToChange_lLbl;
            NotifyModelChange_lNot.Send();
        end;
    end;

    local procedure UpdateSalesLinesWithKnowledeAboutShipment()
    var
        myInt: Integer;
    begin
        dsdsAvailibilityMgmt.UpdateSalesLinesWithKnowledeAboutShipment();
    end;

    local procedure OpenAvailibilityCrosscheck()
    var
        SalesLine_lRec: Record "Sales Line";
    begin
        SalesLine_lRec.SetRange("Document Type", SalesLine_lRec."Document Type"::Order);
        SalesLine_lRec.setrange(Type, SalesLine_lRec.type::Item);
        SalesLine_lRec.setrange("No.", Rec."Item No.");
        SalesLine_lRec.SetFilter("Outstanding Qty. (Base)", '>0');
        Page.run(Page::"DDN Availibility Crosscheck", SalesLine_lRec);
    end;

    /// <summary>
    /// transportiert das Zieldatum in das Modell
    /// </summary>
    local procedure SendShiftToDateToModel()
    var
        myInt: Integer;
    begin
        dsdsAvailibilityMgmt.applyShiftToDate(Rec);
    end;

    local procedure refreshPage()
    var
        TempSalesLine_lRec: Record "Sales Line" temporary;
    begin
        dsdsAvailibilityMgmt.GetScheduleLines(Rec);
        dsdsAvailibilityMgmt.GetPriorityQueue(TempSalesLine_lRec);
        activePriorityModel := dsdsAvailibilityMgmt.GetActivePriorityModel();
        CurrPage.SalesLinePriorityFactBox.Page.setSourceTable(TempSalesLine_lRec);
    end;

    /// <summary>
    /// Wird aufgerufen um der Page mitzuteilen, auf welchem Artikel und welchem Lagerort der Scheduler aufzurfen ist
    /// Die Information wird an die führende CU weitergereicht.
    /// </summary>
    /// <param name="Item_iRec"></param>
    procedure SetContext(var Item_iRec: Record Item)
    var
    begin
        ItemNo_gCod := Item_iRec."No.";
        // Weitergabe von Artikelnummer und leerem Lagerort
        // lerrer Lagerort wird dazu führen, dass der Fokus auf Winsen gesetzt werden wird.
        dsdsAvailibilityMgmt.InitObject(ItemNo_gCod, '');
    end;

    procedure SetContext(var SalesLine_iRec: Record "Sales Line")
    var
    begin
        SalesLine_iRec.TestField(Type, SalesLine_iRec.type::Item);
        ItemNo_gCod := SalesLine_iRec."No.";
        LocationCode_gCod := SalesLine_iRec."Location Code";
        // Weitergabe von Artikelnummer und leerem Lagerort
        // lerrer Lagerort wird dazu führen, dass der Fokus auf Winsen gesetzt werden wird.
        dsdsAvailibilityMgmt.InitObject(ItemNo_gCod, LocationCode_gCod);
        dsdsAvailibilityMgmt.SetFocusOnSalesLine(SalesLine_iRec);
        // Es wird eine Priorität gesetzt falls die VK-Zeile noch keine Priorität besitzt
        // die Priorität ist     
    end;

    local procedure SortByEvent()
    var
    begin

        Rec.SetCurrentKey("Entry No.");
        dsdsAvailibilityMgmt.updateBalance(Rec);
        CurrPage.Update(false);
    end;

    local procedure SortByDate()
    var
    begin

        Rec.SetCurrentKey("Receipt/Shipment Date Sorting", "Source Type");
        dsdsAvailibilityMgmt.updateBalance(Rec);
        CurrPage.Update(false);
    end;

    var
        ResetPriorityConfirmationDialog_gLbl: Label 'This will reset all priorities in all sales line for this item. Manually adjusted priorities will be vanished. Do you know what you do?';
        dsdsAvailibilityMgmt: Codeunit "COR DSDS Availibility Mgmt.";
        ItemNo_gCod: Code[20];
        LocationCode_gCod: Code[20];

    trigger OnOpenPage()
    var
        item_lRec: Record Item;
    begin
        // Beim öffnen der Page wird standardmäßig die Sicht mit Priorisierung gem. VK-Zeilen geöffnet
        ConstrucWithPriorityByIndividualizedOrder_lFunction();
        item_lRec.get(Rec."Item No.");
        CurrPage.Caption := strsubstno('DSDS für %1 %2 %3', Rec."Item No.", item_lRec.Description, item_lRec."Description 2");
    end;

    var
        activePriorityModel: enum "COR DSDS Priority Model";
}
