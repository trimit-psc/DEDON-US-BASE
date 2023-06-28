tableextension 51009 "DDN Sales Invoice Header" extends "Sales Invoice Header" //112
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
        /// <summary>
        /// <see cref="#GLR1"/>
        /// </summary>
        field(51012; "COR-DDN Order Amount Prepay"; Decimal)
        {
            Caption = 'Order Amount for prepayment';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(51016; "COR-DDN Count Sent Mails"; Integer)
        {
            Caption = 'Count sent mails';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("trm E-Mail Log Entry" where(Status = filter('Sent|Error'), "COR-DDN Source Table Id" = const(112), "COR-DDN Source Doc. No." = field("No.")));
        }
    }
}

