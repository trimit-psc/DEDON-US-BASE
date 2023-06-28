tableextension 51025 "DDN Purch. Rcpt. Line" extends "Purch. Rcpt. Line" //121
{
    fields
    {
        /// <summary>
        /// Gewünschtes Versanddatum
        /// <see cref="#7JRN"/>
        /// </summary>
        field(51000; "DDN Requested Shipment Date"; Date)
        {
            Caption = 'Requested Shipment Date';
            DataClassification = ToBeClassified;
        }
        /// <summary>
        /// Zugesagtes Versanddatum
        /// <see cref="#7JRN"/>
        /// </summary>        
        field(51001; "DDN Estimated Date Ready"; Date)
        {
            Caption = 'Estimated Date Ready';
            DataClassification = ToBeClassified;
        }
        /// <summary>
        /// Tatsächliches Versanddatum
        /// <see cref="#7JRN"/>
        /// </summary>        
        field(51002; "DDN Effective Shipment Date"; Date)
        {
            Caption = 'Effective Shipment Date';
            DataClassification = ToBeClassified;
        }
        /// <summary>
        /// Originalmenge nachhalten
        /// <see cref="#6SWK"/>
        /// </summary>
        field(51003; "DDN Original Qty."; Decimal)
        {
            Caption = 'Original Qty.';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        /// <summary>
        /// <see cref="#1Z54"/>
        /// </summary>              
        field(51005; "Item No. 2"; Code[20])
        {
            Caption = 'Item No. 2';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(Item."No. 2" where("No." = field("No.")));
        }
        field(51012; "COR-DDN Legacy System Item No."; Code[20])
        {
            Caption = 'Legacy System Item No.';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(Item."DDM Legacy System Item No." where("No." = field("No.")));
        }
    }
}
