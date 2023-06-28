page 51011 "COR-DDN Container Hist. Entr."
{
    Caption = 'COR-DDN Container Hist. Entries';
    PageType = List;
    SourceTable = "COR-DDN Container Hist. Line";
    UsageCategory = None;
    InsertAllowed = false;
    Editable = false;
    ModifyAllowed = false;
    DeleteAllowed = false;


    layout
    {
        area(content)
        {
            repeater(General)
            {

                field("Container History Id"; Rec."Container History Id")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Container No."; Rec."Container No.")
                {
                    ApplicationArea = All;
                }
                field("Container ID"; Rec."Container ID")
                {
                    ApplicationArea = All;
                }

                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                }

                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                }
                field("Estimated time of arrival"; Rec."Estimated time of arrival")
                {
                    ApplicationArea = All;
                }
                field("Estimated time of departure"; Rec."Estimated time of departure")
                {
                    ApplicationArea = All;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                }

                field("Master No."; Rec."Master No.")
                {
                    ApplicationArea = All;
                }
                field("Item Description"; Rec."Item Description")
                {
                    ApplicationArea = All;
                }
                field("Item Description 2"; Rec."Item Description 2")
                {
                    ApplicationArea = All;
                }

                field("Quantity (Base)"; Rec."Quantity (Base)")
                {
                    ApplicationArea = All;
                }
                field("Shipment Method"; Rec."Shipment Method")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("VAT Product Posting Group"; Rec."VAT Product Posting Group")
                {
                    ApplicationArea = All;
                }
                field("Gen. Product Posting Group"; Rec."Gen. Product Posting Group")
                {
                    ApplicationArea = All;
                }
                field("Vendor Posting Group"; Rec."Vendor Posting Group")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
