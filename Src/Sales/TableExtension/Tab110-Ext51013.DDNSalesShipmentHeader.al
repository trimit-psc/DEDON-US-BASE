tableextension 51013 "DDN Sales Shipment Header" extends "Sales Shipment Header" //110
{
    fields
    {
        /// <summary>
        /// <see cref="#NFSX"/>
        /// </summary>        
        field(51000; "DDN Order Intake Date"; Date)
        {
            DataClassification = ToBeClassified;
            Caption = 'Order Intake Date';
            Editable = false;
        }
        /// <summary>
        /// <see cref="#B9KS"/>
        /// </summary>  
        field(51010; "Export certificate received"; Boolean)
        {
            Caption = 'Export certificate received';
        }
        /// <summary>
        /// <see cref="#U29F"/>
        /// </summary>
        field(51011; "COR-DDN Respons. Person Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Salesperson/Purchaser";
            Caption = 'Responsible Person Code';
        }
    }

}