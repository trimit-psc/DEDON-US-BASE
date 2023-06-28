/// <summary>
/// <see cref="#WF2E"/>
/// </summary>
page 51017 "DDN Item Detail Sales Factbox"
{
    PageType = CardPart;
    SourceTable = "Sales Line";
    caption = 'DEDON Item Details';

    layout
    {
        area(content)
        {
            group(ItemDataGroup)
            {
                caption = 'Item Info';
                field("No. 2"; Item_gRec."No. 2")
                {
                    CaptionClass = 'DDN27,2';
                    ApplicationArea = All;
                }
                field("DDN Item Planning Status"; Rec."DDN Item Planning Status Code")
                {
                    ApplicationArea = All;
                }
                field("Desginer"; Desginer_gText)
                {
                    Caption = 'Designer';
                    ApplicationArea = All;
                }
                field("Country of Origin"; Item_gRec."Country/Region of Origin Code")
                {
                    CaptionClass = 'DDN27,95';
                    ApplicationArea = All;
                }
                field("SalesColor"; Color_gText)
                {
                    Caption = 'Sales Color';
                    ApplicationArea = All;
                }

            }
            group(FabricConsumptionGroup)
            {
                caption = 'Fabric consumption';
                Visible = fabricsEnabled_gBool;
                /// <summary>
                /// <see cref="#1QA2"/>
                /// </summary>
                field("Fabric Consumption"; FabricConsumption_gText)
                {
                    CaptionClass = 'DDN27,51004';
                    ApplicationArea = All;
                }
                field("Fabric Consumption Total"; FabricConsumptionTotal_gText)
                {
                    Caption = 'Total consumption';
                    ApplicationArea = All;
                }
            }
        }
    }
    var
        [InDataSet]
        fabricsEnabled_gBool: Boolean;
        Item_gRec: Record Item;
        "FabricConsumption_gText": Text;
        FabricConsumptionNotApplicableLabel_g: Label 'not applicable';
        FabricConsumptionUndefinedLabel_g: Label 'undefined';
        FabricConsumptionTotal_gText: Text;
        Desginer_gText: Text;
        Color_gText: Text;

    trigger OnAfterGetRecord()
    var
        DDNItemAndMasterDetails: Codeunit "DDN Item and Master Details";
    begin
        DDNItemAndMasterDetails.getItemDetails(Rec, FabricConsumption_gText, FabricConsumptionTotal_gText, fabricsEnabled_gBool, Desginer_gText, Color_gText, true)
    end;
}