pageextension 51059 "COR-DDN Sales Order List" extends "Sales Order List"
{
    layout
    {


        modify("Your Reference")
        {
            visible = true;
        }

    }

    actions
    {
        addfirst("Request Approval")
        {
            action("COR-DDN Request Apporval")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Send A&pproval Request';
                Enabled = NOT OpenApprovalEntriesExist2 AND CanRequestApprovalForFlow2;
                Image = SendApprovalRequest;
                ToolTip = 'Request approval of the document. (DEDON)';

                trigger OnAction()
                var
                    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                begin
                    Rec.CalculateApprovalDelta();
                    Rec.Modify();
                    if ApprovalsMgmt.CheckSalesApprovalPossible(Rec) then
                        ApprovalsMgmt.OnSendSalesDocForApproval(Rec);
                end;
            }
        }
    }

    var
        OpenApprovalEntriesExist2: Boolean;
        CanRequestApprovalForFlow2: Boolean;

    local procedure CORDDNSetControlVisibility()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
        CanCancelApprovalForFlow: Boolean;

    begin
        OpenApprovalEntriesExist2 := ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
        WorkflowWebhookMgt.GetCanRequestAndCanCancel(Rec.RecordId, CanRequestApprovalForFlow2, CanCancelApprovalForFlow);
    end;

    trigger OnAfterGetRecord()
    begin
        CORDDNSetControlVisibility;
    end;
}
