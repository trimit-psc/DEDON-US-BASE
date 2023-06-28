tableextension 51007 "DDN Sales Line Archive" extends "Sales Line Archive" //5108
{
    fields
    {
        /// <summary>
        /// verhindert, dass das Warenausgangsdatum durch automatische Aktualisierungen verändert wird
        /// Anforderung [B-060]
        /// <see cref="#3N8B"/>
        /// </summary>
        field(51000; "DDN lock Shiment Date"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Lock shipment Date';
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
            CalcFormula = lookup("Sales Header Archive"."COR-DDN Respons. Person Code" where("Document Type" = Field("Document Type"), "No." = field("Document No."), "Doc. No. Occurrence" = field("Doc. No. Occurrence"), "Version No." = field("Version No.")));
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
            CalcFormula = lookup("Sales Header"."Sell-to Customer Name" where("Document Type" = field("Document Type"), "No." = field("Document No.")));
            Editable = false;
        }
    }
}