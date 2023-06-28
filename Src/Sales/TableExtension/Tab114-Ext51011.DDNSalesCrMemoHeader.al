tableextension 51011 "DDN Sales Cr.Memo Header" extends "Sales Cr.Memo Header" //114
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
        field(51016; "COR-DDN Count Sent Mails"; Integer)
        {
            Caption = 'Count sent mails';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("trm E-Mail Log Entry" where(Status = filter('Sent|Error'), "COR-DDN Source Table Id" = const(116), "COR-DDN Source Doc. No." = field("No.")));
        }
    }
}