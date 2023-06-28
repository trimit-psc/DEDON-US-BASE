/// <summary>
/// TableExtension DDN Item Ledger Entry (ID 51015) extends Record Item Ledger Entry.
/// </summary>
tableextension 51015 "DDN Item Ledger Entry" extends "Item Ledger Entry"
{
    fields
    {
        /// <summary>
        /// Speichert den Master aus dem heraus eine Komponente im Verkauf
        /// durch das Entfalten einer Stückliste generiert wurde.
        /// <see cref="#DM4X"/>
        /// </summary>
        field(51000; "DDN Set Master No."; Code[20])
        {
            TableRelation = "trm Master";
            Caption = 'Set Master No.';
            DataClassification = ToBeClassified;
            Editable = false;
        }

        /// <summary>
        /// <see cref="#DM4X"/>
        /// </summary>
        field(51001; "DDN Set Item No."; Code[20])
        {
            TableRelation = "Item";
            Caption = 'Item Master No.';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        /// <summary>
        /// <see cref="7JRN"/>
        /// </summary>
        field(51002; "DDN Container No."; Code[20])
        {
            Caption = 'Container No.';
            DataClassification = ToBeClassified;
            TableRelation = "trm Container";
            Editable = false;
        }
        /// <summary>
        /// <see cref="7JRN"/>
        /// </summary>        
        field(51003; "DDN Container ID"; Code[20])
        {
            Caption = 'Container ID';
            DataClassification = ToBeClassified;
            TableRelation = "trm Container"."Container ID";
            Editable = false;
        }

        /// <summary>
        /// <see cref="#9LUF Menge Set in Belegzeile und Posten"/>
        /// </summary>
        field(51004; "COR-DDN Set Quantity"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Set Quantity';
            Editable = false;
        }
    }
}