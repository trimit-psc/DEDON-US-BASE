pageextension 51038 "trm Cust. Serv. Act. (DDN)" extends "trm Cust. Service Activities" //6036331
{
    layout
    {
        addlast("Open Sales Orders")
        {
            field("Open Sales Ord. (Resp. Pers.)"; Rec."Open Sales Ord. (Resp. Pers.)")
            {
                ApplicationArea = All;
                DrillDownPageID = "Sales Order List";
            }
        }
        addlast("Sales Orders in Process")
        {
            field("Back Order (Resp. Pers.)"; Rec."Back Order (Resp. Pers.)")
            {
                ApplicationArea = All;
                DrillDownPageID = "Sales Lines";
            }
            /// <summary>
            /// <see cref="#D5C7"/>
            /// </summary>
            field("COR-DDN ShipmentDate Issue"; Rec."COR-DDN ShipmentDate Issue")
            {
                ApplicationArea = All;
                DrillDownPageID = "DDN Availibility Crosscheck";
            }
        }
    }

    trigger OnOpenPage()
    var
        UserSetup_lRec: Record "User Setup";
    begin
        if UserSetup_lRec.Get(UserId) then begin
            if UserSetup_lRec."Salespers./Purch. Code" <> '' then begin
                Rec.SetRange("Responsible Person Filter", UserSetup_lRec."Salespers./Purch. Code");
            end;
        end;
        Rec.SetFilter("Until Yesterday Filter", '<%1', WorkDate());
    end;
}