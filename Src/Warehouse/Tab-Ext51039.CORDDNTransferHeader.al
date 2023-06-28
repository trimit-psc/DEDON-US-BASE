tableextension 51039 "COR-DDN Transfer Header" extends "Transfer Header"
{
    fields
    {
        /// <summary>
        /// <see cref="#G46K"/>
        /// </summary>
        field(51000; "COR-DDN Comment"; Text[80])
        {
            Caption = 'Comment';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup("Inventory Comment Line".Comment where("Document Type" = const("Transfer Order"), "No." = field("No.")));
        }
    }
}
