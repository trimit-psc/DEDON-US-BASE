tableextension 51020 "DDN Purchase Header" extends "Purchase Header" //38
{
    /// <summary>
    /// <see cref="#MNVF"/>
    /// </summary>    
    DrillDownPageId = "Purchase List";
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
            trigger OnValidate()
            begin
                Rec.UpdatePurchLinesByFieldNo(Rec.FieldNo("DDN Requested Shipment Date"), true);
            end;
        }
        /// <summary>
        /// Zugesagtes Versanddatum
        /// <see cref="#7JRN"/>
        /// </summary>        
        field(51001; "DDN Estimated Date Ready"; Date)
        {
            Caption = 'Estimated Date Ready';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                Rec.UpdatePurchLinesByFieldNo(Rec.FieldNo("DDN Estimated Date Ready"), true);
            end;
        }
        /// <summary>
        /// Tatsächliches Versanddatum
        /// <see cref="#7JRN"/>
        /// </summary>        
        field(51002; "DDN Effective Shipment Date"; Date)
        {
            Caption = 'Effective Shipment Date';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                Rec.UpdatePurchLinesByFieldNo(Rec.FieldNo("DDN Effective Shipment Date"), true);
            end;
        }
        /// <summary>
        /// <see cref="#VCWD"/>
        /// </summary>                
        field(51005; "Commission"; Text[100])
        {
            Caption = 'Commission';
        }
    }
}
