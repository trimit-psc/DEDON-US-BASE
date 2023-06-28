tableextension 51043 "COR-DDN trm Container Select" extends "trm Temp Container Cont Select"
{
    fields
    {
        field(51000; "COR-DDN Legacy System Item No."; Code[20])
        {
            Caption = 'Legacy System Item No.';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(Item."DDM Legacy System Item No." where("No." = field("No.")));
        }
    }
}
