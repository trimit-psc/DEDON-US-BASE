table 51006 "COR DSDS Schedule Line"
{
    Caption = 'COR DSDS Schedule Line';
    DataClassification = ToBeClassified;
    LookupPageId = "COR DSDS Schedule Line";
    DrillDownPageId = "COR DSDS Schedule Line";

    fields
    {
        field(1; "Batch No."; Code[20])
        {
            Caption = 'Batch No.';
            DataClassification = ToBeClassified;
        }
        field(2; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = ToBeClassified;
        }
        field(3; Indentation; Integer)
        {
            Caption = 'Indentation';
            DataClassification = ToBeClassified;
        }
        field(4; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = ToBeClassified;
        }
        field(6; "Location Code"; Code[20])
        {
            Caption = 'Location Code';
            DataClassification = ToBeClassified;
        }
        field(7; "Source Type"; Enum "COR DSDS Document Type")
        {
            Caption = 'Source Type';
            DataClassification = ToBeClassified;
        }
        field(8; "Source Subtype"; Integer)
        {
            Caption = 'Source Subtype';
            DataClassification = ToBeClassified;
        }
        field(9; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            DataClassification = ToBeClassified;
        }
        field(10; "Source Line No."; Integer)
        {
            Caption = 'Source Line No.';
            DataClassification = ToBeClassified;
        }
        field(11; "assigned to Entry No."; Integer)
        {
            Caption = 'assigned to Entry No.';
            DataClassification = ToBeClassified;
            TableRelation = "COR DSDS Schedule Line"."Entry No." where("Batch No." = field("Batch No."));
        }
        field(12; "Receipt/Shipment Date"; date)
        {
            Caption = 'Receipt/Shipment Date';
            DataClassification = ToBeClassified;
        }
        field(13; "Outstanding Quantity (Base)"; Decimal)
        {
            Caption = 'Outstanding Quantity (Base)';
            DataClassification = ToBeClassified;
            DecimalPlaces = 2 : 0;
        }
        field(14; "Outgoing Priority"; Integer)
        {
            Caption = 'Priority';
            DataClassification = ToBeClassified;
            BlankZero = true;
        }
        /// <summary>
        /// Entwicklung der Mengen über die Zeit
        /// </summary>
        field(15; "Balance"; Decimal)
        {
            Caption = 'Balacne';
            DataClassification = ToBeClassified;
            DecimalPlaces = 2 : 0;
        }

        field(16; "Unassigned Quantity (Base)"; Decimal)
        {
            Caption = 'Unassigned Quantity (Base)';
            DataClassification = ToBeClassified;
            DecimalPlaces = 2 : 0;
        }

        field(17; "direction"; Option)
        {
            Caption = 'Direction';
            OptionMembers = neutral,positive,negative;
            DataClassification = ToBeClassified;
        }
        field(18; "earliest shipment date"; date)
        {
            Caption = 'Erlises shipment Date';
            DataClassification = ToBeClassified;
        }
        field(19; "Sales Line Creation Date"; Date)
        {
            Caption = 'Sales Line created at Date';
            DataClassification = ToBeClassified;
        }
        field(20; "Focus Icon"; Text[1])
        {
            Caption = 'Focus';
            DataClassification = ToBeClassified;
        }
        field(21; "Shipment Date Conflict"; enum "COR Shipment Date Conflict")
        {
            Caption = 'Shipment Date Conflict';
            DataClassification = ToBeClassified;
        }
        field(22; "calculated via Replenishment"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Calculated via Replenishment';
        }
        /// <summary>
        /// Für die Sortierung weil Stock und Jungheinrich auf dem Arbeitsdatum sitzen
        /// </summary>
        field(23; "Receipt/Shipment Date Sorting"; date)
        {
            Caption = 'Receipt/Shipment Date Sorting';
            DataClassification = ToBeClassified;
        }
        // Ein zieldatum, auf das geschoben werden soll
        field(24; "Shift-to Date"; date)
        {
            Caption = 'Shift-to date';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var

            begin
                Rec.TestField("Source Type", Rec."Source Type"::"Sales Order");
            end;
        }
        field(25; "Customer / Vendor Name"; Text[100])
        {
            Caption = 'Customer / Vendor Name';
            DataClassification = ToBeClassified;
        }
        field(26; "aggregated balance"; Decimal)
        {
            Caption = 'Aggregated balance';
            DataClassification = ToBeClassified;
        }
        /// <summary>
        /// Zeigt die zugewiesenen Menge mit Blick auf die aktuelle EK-bestellung bzw anderen Bedarfsdecker.
        /// </summary>
        field(27; "Unassigned Qty. (Base) Entry"; Decimal)
        {
            Caption = 'Unassigned Quantity (Base) this entry';
            DataClassification = ToBeClassified;
            DecimalPlaces = 2 : 0;
        }
    }
    keys
    {
        key(PK; "Batch No.", "Entry No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
    begin
        if "Source Type" in [Rec."Source Type"::Stock, Rec."Source Type"::Jungheinrich]
        then
            "Receipt/Shipment Date Sorting" := 0D
        else
            "Receipt/Shipment Date Sorting" := "Receipt/Shipment Date";
    end;
}
