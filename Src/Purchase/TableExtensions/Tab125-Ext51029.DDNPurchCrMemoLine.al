tableextension 51029 "DDN Purch. Cr. Memo Line" extends "Purch. Cr. Memo Line" //125
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
    }
}
