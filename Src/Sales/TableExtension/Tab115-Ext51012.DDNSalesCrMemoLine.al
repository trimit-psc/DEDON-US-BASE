tableextension 51012 "DDN Sales Cr.Memo Line" extends "Sales Cr.Memo Line" //115
{
    fields
    {
        /// <summary>
        /// <see cref="#3N8B"/>
        /// </summary>
        field(51000; "DDN lock Shiment Date"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Lock Shipment Date';
        }
        /// <summary>
        /// <see cref="#NFSX"/>
        /// </summary>
        field(51005; "DDN Order Intake Date"; Date)
        {
            DataClassification = ToBeClassified;
            Caption = 'Order Intake Date';
            Editable = false;
        }
        /// <summary>
        /// <see cref="#DM4X"/>
        /// </summary>
        field(51008; "DDN Set Master No."; Code[20])
        {
            TableRelation = "trm Master";
            Caption = 'Set Master No.';
            DataClassification = ToBeClassified;
            Editable = false;
        }

        /// <summary>
        /// <see cref="#DM4X"/>
        /// </summary>
        field(51009; "DDN Set Item No."; Code[20])
        {
            TableRelation = "Item";
            Caption = 'Set Item No.';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        /// <summary>
        /// <see cref="M92Y"/>
        /// </summary>
        field(51010; "DDN Item Planning Status Code"; Code[20])
        {
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup(Item."DDN Item Planning Status Code" where("No." = field("No.")));
            Caption = 'Itme Planning Status Code';
        }
        /// <summary>
        /// <see cref="#9LUF Menge Set in Belegzeile und Posten"/>
        /// </summary>
        field(51011; "COR-DDN Set Quantity"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Set Quantity';
            Editable = false;
        }
        /// <summary>
        /// <see cref="#U29F"/>
        /// </summary>
        field(51012; "COR-DDN Respons. Person Code"; Code[20])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Sales Invoice Header"."COR-DDN Respons. Person Code" where("No." = field("Document No.")));
            TableRelation = "Salesperson/Purchaser";
            Editable = false;
            Caption = 'Responsible Person Code';
        }
        /// <summary>
        /// <see cref="#D5C7"/>
        /// </summary>        
        field(51013; "Sell-to Customer Name"; Text[100])
        {
            Caption = 'Sell-to Customer Name';
            FieldClass = FlowField;
            CalcFormula = lookup("Sales Header"."Sell-to Customer Name" where("No." = field("Document No.")));
            Editable = false;
        }
    }
}