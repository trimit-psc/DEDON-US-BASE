table 51005 "COR-DDN Container Hist. Line"
{
    Caption = 'COR-DDN Container Hist. Line';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Container History Id"; Integer)
        {
            Caption = 'Container History Id';
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = "COR-DDN Container Hist. Header";
        }
        field(2; "Document Type"; Enum "Purchase Document Type")
        {
            Caption = 'Document Type';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(3; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = ToBeClassified;
            TableRelation = "Purchase Header" where("Document Type" = field("Document Type"));
            Editable = false;
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(5; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            Editable = false;
            TableRelation = Vendor;
        }
        field(6; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Ready,Transport,Posted,Partly Posted';
            OptionMembers = " ",Ready,Transport,Posted,"Partly Posted";
            editable = false;
        }
        field(7; "Container ID"; Code[20])
        {
            Caption = 'Container ID';
            DataClassification = ToBeClassified;
        }
        field(8; "Vendor Posting Group"; Code[20])
        {
            Caption = 'Vendor Posting Group';
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = "Vendor Posting Group";
        }
        field(9; "Quantity"; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(10; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(11; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = item;
        }
        field(12; "Master No."; Code[20])
        {
            Caption = 'Master No.';
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = "trm Master";
        }
        field(13; "Item Description"; Text[100])
        {
            Caption = 'Item Description';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(14; "Item Description 2"; Text[100])
        {
            Caption = 'Item Description 2';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(15; "Estimated time of arrival"; date)
        {
            Caption = 'Estimated time of arrival (ETA)';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(16; "Estimated time of departure"; date)
        {
            Caption = 'Estimated time of departure (ETD)';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(17; "Amount (LCY)"; decimal)
        {
            Caption = 'Amount (LCY)';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(18; "Container No."; Code[20])
        {
            Caption = 'Container No.';
            DataClassification = ToBeClassified;
            TableRelation = "trm Container";
            Editable = false;
        }
        field(19; "Gen. Product Posting Group"; Code[20])
        {
            Caption = 'Gen. Product Posting Group';
            DataClassification = ToBeClassified;
            TableRelation = "Gen. Product Posting Group";
            Editable = false;
        }
        field(20; "VAT Product Posting Group"; Code[20])
        {
            Caption = 'VAT Product Posting Group';
            DataClassification = ToBeClassified;
            TableRelation = "VAT Product Posting Group";
            Editable = false;
        }
        field(21; "Shipment Method"; Code[20])
        {
            Caption = 'Shipment Method';
            DataClassification = ToBeClassified;
            TableRelation = "Shipment Method";
            Editable = false;
        }
    }
    keys
    {
        key(PK; "Container History Id", "Document Type", "Document No.", "Line No.")
        {
            Clustered = true;
        }
    }
}
