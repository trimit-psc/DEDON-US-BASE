page 51016 "COR-DDN Active Sessions"
{
    Editable = false;
    PageType = List;
    SourceTable = "Active Session";
    UsageCategory = Administration;
    InsertAllowed = false;
    ModifyAllowed = false;
    Caption = 'Active Sessions';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("User SID"; rec."User SID")
                {
                }
                field("Server Instance ID"; rec."Server Instance ID")
                {
                }
                field("Session ID"; rec."Session ID")
                {
                }
                field("Server Instance Name"; rec."Server Instance Name")
                {
                }
                field("Server Computer Name"; rec."Server Computer Name")
                {
                }
                field("User ID"; rec."User ID")
                {
                }
                field("Client Type"; rec."Client Type")
                {
                }
                field("Client Computer Name"; rec."Client Computer Name")
                {
                }
                field("Login Datetime"; rec."Login Datetime")
                {
                }
                field("Database Name"; rec."Database Name")
                {
                }
                field("Session Unique ID"; rec."Session Unique ID")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(KillSession)
            {
                Caption = 'Kill Session';
                Image = DeleteAllBreakpoints;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    STOPSESSION(rec."Session ID", STRSUBSTNO(HasBeenKilled_gCtx, USERID));
                end;
            }
            action(DelSession)
            {
                Caption = 'Delete Session';
                Image = Delete;

                trigger OnAction()
                begin
                    STOPSESSION(rec."Session ID", STRSUBSTNO(HasBeenKilled_gCtx, USERID));
                    rec.DELETE(TRUE);
                end;
            }
        }
    }

    var
        HasBeenKilled_gCtx: Label 'Your session has been stopped by user %1.';
}

