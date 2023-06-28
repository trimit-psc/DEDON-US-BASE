/// <summary>
/// <see cref="#B9KS"/>
/// </summary>  
page 51009 "Received Export Certificates"
{
    Caption = 'Received Export Certificates';
    Editable = true;
    PageType = List;
    CardPageId = "Posted Sales Shipment";
    UsageCategory = Documents;
    ApplicationArea = All;
    SourceTable = "Sales Shipment Header";
    SourceTableView = sorting("Posting Date") order(descending);
    Permissions = tabledata "Sales Shipment Header" = m;
    ModifyAllowed = true;
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                field("No."; Rec."No.")
                {
                    Editable = false;
                    ApplicationArea = All;
                }
                field("Ship-to Code"; Rec."Ship-to Code")
                {
                    Visible = false;
                    Editable = false;
                    ApplicationArea = All;
                }
                field("Ship-to Name"; Rec."Ship-to Name")
                {
                    Visible = false;
                    Editable = false;
                    ApplicationArea = All;
                }
                field("Ship-to Post Code"; Rec."Ship-to Post Code")
                {
                    Visible = false;
                    Editable = false;
                    ApplicationArea = All;
                }
                field("Ship-to Country/Region Code"; Rec."Ship-to Country/Region Code")
                {
                    Visible = false;
                    Editable = false;
                    ApplicationArea = All;
                }
                field("Ship-to Contact"; Rec."Ship-to Contact")
                {
                    Visible = false;
                    Editable = false;
                    ApplicationArea = All;
                }
                field("Shipment Date"; Rec."Shipment Date")
                {
                    Visible = false;
                    Editable = false;
                    ApplicationArea = All;
                }
                field("Export certificate received"; Rec."Export certificate received")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnModifyRecord(): Boolean
    begin
        Codeunit.Run(Codeunit::"Sales Shipment Header-Edit", Rec);
        exit(false);
    end;
}