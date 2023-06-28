/// <summary>
/// TableExtension DDN Sales Header Archive (ID 51006) extends Record Sales Header Archive.
/// </summary>
tableextension 51006 "DDN Sales Header Archive" extends "Sales Header Archive" //5107
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