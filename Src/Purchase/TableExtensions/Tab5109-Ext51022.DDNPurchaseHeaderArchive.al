tableextension 51022 "DDN Purchase Header Archive" extends "Purchase Header Archive" //5109
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
        /// <see cref="#VCWD"/>
        /// </summary>                
        field(51005; "Commission"; Text[100])
        {
            Caption = 'Commission';
        }
    }
}
