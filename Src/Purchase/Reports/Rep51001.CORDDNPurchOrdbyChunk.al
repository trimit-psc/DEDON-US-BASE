/// <summary>
/// Kopie von report 493 "Carry Out Action Msg. - Req."
/// Trennt die Bestell-Generierung auf indem UseOneJnl() mit wöchentlich gefitlerten Datensätzen aufgerufen wird
/// <see cref="#ULMA"/>
/// </summary>
report 51001 "COR-DDN Purch. Ord. by Chunk"
{
    Caption = 'Carry Out Action Msg. - Req.';
    ProcessingOnly = true;

    dataset
    {
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(PrintOrders; PrintOrders)
                    {
                        ApplicationArea = Planning;
                        Caption = 'Print Orders';
                        ToolTip = 'Specifies whether to print the purchase orders after they are created.';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            PurchOrderHeader."Order Date" := WorkDate;
            PurchOrderHeader."Posting Date" := WorkDate;
            if ReqWkshTmpl.Recurring then
                EndOrderDate := WorkDate
            else
                EndOrderDate := 0D;
        end;
    }

    labels
    {
    }

    trigger OnPreReport()
    var
        minDate_lDate, maxDate_lDate : Date;
        fromDate_lDate, toDate_lDate : Date;
    begin
        OnBeforePreReport(PrintOrders);
        minDate_lDate := 20991231D;

        if ReqLine.FindSet() then
            repeat
                if ReqLine."Due Date" <= minDate_lDate then
                    minDate_lDate := ReqLine."Due Date";
                if ReqLine."Due Date" > maxDate_lDate then
                    maxDate_lDate := ReqLine."Due Date";
            until ReqLine.Next() = 0;

        // Montag ermitteln
        minDate_lDate := calcdate('<-WD1>', minDate_lDate);
        maxDate_lDate := CalcDate('<+WD7>', maxDate_lDate);


        fromDate_lDate := minDate_lDate;
        toDate_lDate := calcdate('<+WD7>', fromDate_lDate);

        while toDate_lDate <= maxDate_lDate do begin
            fromDate_lDate := calcdate('<+1W>', fromDate_lDate);
            toDate_lDate := calcdate('<+WD7>', fromDate_lDate);
            ReqLine.SetRange("Due Date", fromDate_lDate, toDate_lDate);
            if not ReqLine.IsEmpty then
                UseOneJnl(ReqLine);
        end;
        ReqLine.SetRange("Due Date");

    end;

    trigger OnPostReport()
    begin
        OnBeforePostReport(ReqWkshMakeOrders);
    end;

    var
        Text000: Label 'cannot be filtered when you create orders';
        Text001: Label 'There is nothing to create.';
        Text003: Label 'You are now in worksheet %1.';
        ReqWkshTmpl: Record "Req. Wksh. Template";
        ReqWkshName: Record "Requisition Wksh. Name";
        ReqLine: Record "Requisition Line";
        PurchOrderHeader: Record "Purchase Header";
        ReqWkshMakeOrders: Codeunit "Req. Wksh.-Make Order";
        EndOrderDate: Date;
        PrintOrders: Boolean;
        TempJnlBatchName: Code[10];

    protected var
        HideDialog: Boolean;
        SuppressCommit: Boolean;

    procedure SetReqWkshLine(var NewReqLine: Record "Requisition Line")
    begin
        ReqLine.Copy(NewReqLine);
        ReqWkshTmpl.Get(NewReqLine."Worksheet Template Name");

        OnAfterSetReqWkshLine(NewReqLine);
    end;

    procedure GetReqWkshLine(var NewReqLine: Record "Requisition Line")
    begin
        NewReqLine.Copy(ReqLine);
    end;

    procedure SetReqWkshName(var NewReqWkshName: Record "Requisition Wksh. Name")
    begin
        ReqWkshName.Copy(NewReqWkshName);
        ReqWkshTmpl.Get(NewReqWkshName."Worksheet Template Name");
    end;

    local procedure UseOneJnl(var ReqLine: Record "Requisition Line")
    var
        IsHandled: Boolean;
    begin
        with ReqLine do begin
            ReqWkshTmpl.Get("Worksheet Template Name");
            if ReqWkshTmpl.Recurring and (GetFilter("Order Date") <> '') then
                FieldError("Order Date", Text000);
            TempJnlBatchName := "Journal Batch Name";
            IsHandled := false;
            OnUseOneJnlOnBeforeSetReqWkshMakeOrdersParameters(ReqLine, ReqWkshMakeOrders, PurchOrderHeader, EndOrderDate, PrintOrders, SuppressCommit, IsHandled);
            if not IsHandled then begin
                ReqWkshMakeOrders.Set(PurchOrderHeader, EndOrderDate, PrintOrders);
                ReqWkshMakeOrders.SetSuppressCommit(SuppressCommit);
                ReqWkshMakeOrders.CarryOutBatchAction(ReqLine);
            end;

            if "Line No." = 0 then
                Message(Text001)
            else
                if not HideDialog then
                    if TempJnlBatchName <> "Journal Batch Name" then
                        Message(
                          Text003,
                          "Journal Batch Name");

            if not Find('=><') or (TempJnlBatchName <> "Journal Batch Name") then begin
                Reset;
                FilterGroup := 2;
                SetRange("Worksheet Template Name", "Worksheet Template Name");
                SetRange("Journal Batch Name", "Journal Batch Name");
                FilterGroup := 0;
                "Line No." := 1;
            end;
        end;
    end;

    procedure InitializeRequest(ExpirationDate: Date; OrderDate: Date; PostingDate: Date; ExpectedReceiptDate: Date; YourRef: Text[50])
    begin
        EndOrderDate := ExpirationDate;
        PurchOrderHeader."Order Date" := OrderDate;
        PurchOrderHeader."Posting Date" := PostingDate;
        PurchOrderHeader."Expected Receipt Date" := ExpectedReceiptDate;
        PurchOrderHeader."Your Reference" := YourRef;
    end;

    procedure SetHideDialog(NewHideDialog: Boolean)
    begin
        HideDialog := NewHideDialog;
    end;

    procedure SetSupressCommit(NewSupressCommit: Boolean)
    begin
        SuppressCommit := NewSupressCommit;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetReqWkshLine(var RequisitionLine: Record "Requisition Line")
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnBeforePreReport(var PrintOrders: Boolean)
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnBeforePostReport(var ReqWkshMakeOrders: Codeunit "Req. Wksh.-Make Order")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUseOneJnlOnBeforeSetReqWkshMakeOrdersParameters(var ReqLine: Record "Requisition Line"; var ReqWkshMakeOrders: Codeunit "Req. Wksh.-Make Order"; PurchOrderHeader: Record "Purchase Header"; EndOrderDate: Date; PrintOrders: Boolean; var SuppressCommit: Boolean; var IsHandled: Boolean)
    begin
    end;
}

