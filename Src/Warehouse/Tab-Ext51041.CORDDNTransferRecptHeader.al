tableextension 51041 "COR-DDN Transfer Recpt. Header" extends "Transfer Receipt Header"
{
    fields
    {        /// <summary>
             /// <see cref="#G46K"/>
             /// </summary>
        field(51000; "COR-DDN Comment"; Text[80])
        {
            Caption = 'Comment';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup("Inventory Comment Line".Comment where("Document Type" = const("Posted Transfer Receipt"), "No." = field("No.")));
        }
    }
}
