tableextension 51036 "trm Customer Service Cue (DDN)" extends "trm Customer Service Cue" //6036802
{
    fields
    {
        field(51000; "Responsible Person Filter"; Code[20])
        {
            Caption = 'Responsible Person Filter';
            FieldClass = FlowFilter;
            TableRelation = "Salesperson/Purchaser".Code;
        }
        field(51001; "Until Yesterday Filter"; Date)
        {
            Caption = 'Until Yesterday Filter';
            FieldClass = FlowFilter;
        }
        field(51005; "Open Sales Ord. (Resp. Pers.)"; Integer)
        {
            Caption = 'Open Sales Orders (Responsible Person)';
            FieldClass = FlowField;
            CalcFormula = count("Sales Header" where("Document Type" = const(Order), Status = const(Open), "COR-DDN Respons. Person Code" = field("Responsible Person Filter")));
        }
        field(51006; "Back Order (Resp. Pers.)"; Integer)
        {
            Caption = 'Back Order (Responsible Person)';
            FieldClass = FlowField;
            CalcFormula = count("Sales Line" where("Document Type" = const(Order), "Outstanding Quantity" = filter(> 0), "Shipment Date" = field("Until Yesterday Filter"), "COR-DDN Respons. Person Code" = field("Responsible Person Filter")));
        }
        /// <summary>
        /// <see cref="#D5C7"/>
        /// </summary>
        field(51007; "COR-DDN ShipmentDate Issue"; Integer)
        {
            Caption = 'Conflict Shipment Date (Responsible Person)';
            FieldClass = FlowField;
            CalcFormula = count("Sales Line" where("Document Type" = const(Order), "Outstanding Quantity" = filter(> 0), "COR-DDN Respons. Person Code" = field("Responsible Person Filter"), "DDN-COR Date Conflict Action" = const(DateConflictExists)));
            Editable = false;

        }
    }
}