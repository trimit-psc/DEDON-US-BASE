/// <summary>
/// <see cref="#WF2E"/>
/// </summary>

page 51007 "DDN Sales Order Lines"
{
    // based on standard page 48
    Caption = 'DEDON Sales Order Lines';
    DataCaptionFields = "Document Type", "Document No.";
    Editable = false;
    PageType = List;
    SourceTable = "Sales Line";
    SourceTableView = where("Document Type" = const(Order));
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;

                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Shipment Date"; Rec."Shipment Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Outstanding Quantity"; Rec."Outstanding Quantity")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Line Discount %"; Rec."Line Discount %")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(FabricConsumption_gTxt; FabricConsumption_gTxt)
                {
                    Caption = 'Fabric Consumption';
                    Editable = false;
                    ApplicationArea = All;
                }
                field(FabricConsumptionTotal_gTxt; FabricConsumptionTotal_gTxt)
                {
                    Caption = 'Fabric Consumption Total';
                    Editable = false;
                    ApplicationArea = All;
                }
                field(Designer_gTxt; Designer_gTxt)
                {
                    Caption = 'Designer';
                    Editable = false;
                    ApplicationArea = All;
                }
                field(Color_gTxt; Color_gTxt)
                {
                    Caption = 'Color';
                    Editable = false;
                    ApplicationArea = All;
                }
                /// <summary>
                /// <see cref="#U29F"/>
                /// </summary>
                field("COR-DDN Respons. Person Code"; Rec."COR-DDN Respons. Person Code")
                {
                    ApplicationArea = All;
                }

            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                action("Show Order")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Show Order';
                    Image = ViewOrder;
                    RunObject = Page "Sales Order";
                    RunPageLink = "Document Type" = field("Document Type"),
                                  "No." = field("Document No.");
                    ShortCutKey = 'Shift+F7';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        DDNItemAndMasterDetails_lCdu: Codeunit "DDN Item and Master Details";
        fabricsEnabledDummy_lBln: Boolean;
    begin
        DDNItemAndMasterDetails_lCdu.getItemDetails(Rec, FabricConsumption_gTxt, FabricConsumptionTotal_gTxt, fabricsEnabledDummy_lBln, Designer_gTxt, Color_gTxt, false)
    end;

    var
        FabricConsumption_gTxt: Text;
        FabricConsumptionTotal_gTxt: Text;
        Designer_gTxt: Text;
        Color_gTxt: Text;
}

