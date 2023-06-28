tableextension 51040 "COR-DDN Transfer Ship. Header" extends "Transfer Shipment Header"
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
            CalcFormula = lookup("Inventory Comment Line".Comment where("Document Type" = const("Posted Transfer Shipment"), "No." = field("No.")));
        }
    }
}
