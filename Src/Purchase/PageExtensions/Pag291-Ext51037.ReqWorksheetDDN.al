pageextension 51037 "COR-DDN Req. Worksheet" extends "Req. Worksheet" //291
{
    layout
    {
        addlast(Control1)
        {
            field("COR-DDN Sales Order No."; Rec."Sales Order No.")
            {
                ApplicationArea = All;
            }
        }
        addafter("Vendor No.")
        {
            field("COR-DDN BuyFromVendorName"; Rec."COR-DDN Vendor Name")
            {
            }
        }
    }
    actions
    {
        addafter(CarryOutActionMessage)
        {
            // <see cref="#ULMA"/>
            action(CarryOutActionMessageByChunk)
            {
                ApplicationArea = Planning;
                Caption = 'Carry Out Action Message by Chunk';
                Ellipsis = true;
                Image = CarryOutActionMessage;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Create purchase orders week by week';

                trigger OnAction()
                begin
                    CarryOutActionMsgByChunk();
                    CurrentJnlBatchName := Rec.GetRangeMax("Journal Batch Name");
                    CurrPage.Update(false);
                end;
            }
        }
    }

    /// <summary>
    /// Wöchentlich getrennter Aufruf der EReignismeldung
    /// <see cref="#ULMA"/>
    /// </summary>
    local procedure CarryOutActionMsgBychunk()
    var
        CarryOutActionMsgReq: Report "COR-DDN Purch. Ord. by Chunk";
    begin
        CarryOutActionMsgReq.SetReqWkshLine(Rec);
        CarryOutActionMsgReq.RunModal();
        CarryOutActionMsgReq.GetReqWkshLine(Rec);
    end;
}