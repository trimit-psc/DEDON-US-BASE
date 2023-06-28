page 51010 "COR-DDN Container History List"
{
    ApplicationArea = All;
    Caption = 'Container History List';
    PageType = List;
    SourceTable = "COR-DDN Container Hist. Header";
    UsageCategory = History;
    InsertAllowed = false;
    Editable = true;
    ModifyAllowed = false;
    DeleteAllowed = true;
    SourceTableView = sorting(id) order(descending);

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(id; Rec.id)
                {
                    ApplicationArea = All;
                    visible = false;
                }
                field("crated at date"; Rec."crated at date")
                {
                    ApplicationArea = All;
                }

                field("crated at time"; Rec."crated at time")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(refresh)
            {
                Caption = 'recalculate';
                ApplicationArea = All;
                Image = Recalculate;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                ToolTip = 'Runs through all lines for each incoming container and logs it''s content. This grants a historical view on the values of the goods in transit.';


                trigger OnAction()
                var
                    logContainer: Codeunit "COR-DDN Log Container";
                begin
                    logContainer.logPurchaseContainerLines(true);
                end;
            }
            action(ExportToExcel)
            {
                Caption = 'Export To Excel';
                ApplicationArea = All;
                Image = Excel;

                trigger OnAction();
                var
                    containerHistoryHeader_lRec: Record "COR-DDN Container Hist. Header";
                begin
                    containerHistoryHeader_lRec.setrange("Id", Rec."Id");
                    Report.Run(Report::"COR-DDN Container History", true, false, containerHistoryHeader_lRec);
                end;
            }

        }
        area(Navigation)
        {
            action(Lines)
            {
                Caption = 'loged Container Lines';
                ApplicationArea = All;
                Image = ItemLines;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                RunObject = Page "COR-DDN Container Hist. Entr.";
                RunPageLink = "Container History Id" = field(id);
                ToolTip = 'open a page with all associated lines that were logged at a specific moment in time.';
            }
        }
    }
}
