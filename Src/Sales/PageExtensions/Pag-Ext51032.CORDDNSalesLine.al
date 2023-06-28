pageextension 51032 "COR-DDN Sales Line" extends "Sales Lines" // 516
{
    layout
    {
        /// <summary>
        /// <see cref="#U29F"/>
        /// </summary>
        addlast("Control1")
        {
            field("COR-DDN Respons. Person Code"; Rec."COR-DDN Respons. Person Code")
            {
                ApplicationArea = All;
            }
            field("trm Salesperson"; Rec."trm Salesperson")
            {
                ApplicationArea = All;
            }
            field("trm Salesperson 2"; Rec."trm Salesperson 2")
            {
                ApplicationArea = All;
            }

            field("Special Order"; Rec."Special Order")
            {
                ApplicationArea = All;
            }
            field("Special Order Purchase No."; Rec."Special Order Purchase No.")
            {
                ApplicationArea = All;
            }
            field("Special Order Purch. Line No."; Rec."Special Order Purch. Line No.")
            {
                ApplicationArea = All;
            }
            field("COR-DDN Warehouse Shipment No."; Rec."COR-DDN Warehouse Shipment No.")
            {
                ApplicationArea = All;
            }
            field("COR-DDN Your Referenc No."; Rec."COR-DDN Your Referenc No.")
            {
                ApplicationArea = All;
            }
            field("Purchasing Code"; Rec."Purchasing Code")
            {
                ApplicationArea = All;
            }
            field("Purchase Order No."; Rec."Purchase Order No.")
            {
                ApplicationArea = All;
            }
            field("Purch. Order Line No."; Rec."Purch. Order Line No.")
            {
                ApplicationArea = All;

            }
            field("COR-DDN Item No."; Rec."COR-DDN Item No.")
            {
                ApplicationArea = All;
            }
            field("COR-DDN Legacy System Item No."; Rec."COR-DDN Legacy System Item No.")
            {
                ApplicationArea = All;
            }
            field("DDN Sales Header Status"; Rec."DDN Sales Header Status")
            {
                ApplicationArea = All;
            }
            field("Planned Shipment Date"; Rec."Planned Shipment Date")
            {
                ApplicationArea = All;
            }



        }
        addafter("Description 2")
        {
            /// <summary>
            /// <see cref="#1QA2"/>
            /// </summary>
            field(FabricConsumption_gText; FabricConsumption_gText)
            {
                Caption = 'Fabric Consumption';
                ApplicationArea = all;
                Editable = false;
            }
            /// <summary>
            /// <see cref="#1QA2"/>
            /// </summary>            
            field(FabricConsumptionTotal_gText; FabricConsumptionTotal_gText)
            {
                Caption = 'Fabric Consumption Total';
                ApplicationArea = all;
                Editable = false;
            }
            /// <summary>
            /// <see cref="#M92Y"/>
            /// </summary>
            field("DDN Item Planning Status Code"; Rec."DDN Item Planning Status Code")
            {
                ApplicationArea = all;
            }
        }
        addafter("Sell-to Customer No.")
        {
            field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
            {
                ApplicationArea = All;

            }
        }

    }

    trigger OnAfterGetRecord()
    var
        DDNSetup_lRec: Record "DDN Setup";
        DDNItemAndMasterDetails_lCod: Codeunit "DDN Item and Master Details";
        fabricsEnabled_lBool: Boolean;
        Desginer_lText: Text;
        Color_gText: Text;
        p: page 55;
    begin
        // #1QA2
        DDNItemAndMasterDetails_lCod.getItemDetails(Rec, FabricConsumption_gText, FabricConsumptionTotal_gText, fabricsEnabled_lBool, Desginer_lText, Color_gText, false)
    end;

    var
        FabricConsumption_gText: Text;
        FabricConsumptionTotal_gText: Text;
}