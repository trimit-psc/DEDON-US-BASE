tableextension 51038 "COR-DDN Requisition Line" extends "Requisition Line"
{
    fields
    {
        field(51000; "COR-DDN Vendor Name"; Text[100])
        {
            Caption = 'Vendor Name';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup(Vendor.Name where("No." = field("Vendor No.")));
        }
    }
}
