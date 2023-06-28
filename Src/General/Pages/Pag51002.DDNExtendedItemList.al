/// <summary>
/// Page DDN Extended Item List (ID 51002) listet einige Artikelstammdaten mit Fokus auf Verfügbarkeiten auf
/// <see cref="#8HRF"/>
/// </summary>
page 51002 "DDN Extended Item List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = Item;
    Caption = 'DEDON extended Item list';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(list)
            {
                IndentationColumn = Rec."DDN Indentation";
                ShowAsTree = true;
                IndentationControls = "No.", "No. 2", Description;
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleExpression_gTxt;
                }
                /// <see cref="#HR3T"/>
                field("No. 2"; Rec."No. 2")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleExpression_gTxt;
                }
                // <see cref="#HR3T"/>
                field("DDM Legacy System Item No."; Rec."DDM Legacy System Item No.")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleExpression_gTxt;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    StyleExpr = StyleExpression_gTxt;
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleExpression_gTxt;
                }
                field(Inventory; Rec.Inventory)
                {
                    ApplicationArea = All;
                    BlankZero = true;
                }
                field("Qty. on Sales Order"; Rec."Qty. on Sales Order")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                }
                field("Qty. on Purch. Order"; Rec."Qty. on Purch. Order")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                }
                /*
                field("Qty. on Prod. Order"; Rec."Qty. on Prod. Order")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                }
                field("Qty. on Component Lines"; Rec."Qty. on Component Lines")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                }
                */
                field("trm Increase Production (Base)"; Rec."trm Increase Production (Base)")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                }
                field("trm Decrease Production (Base)"; Rec."trm Decrease Production (Base)")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                }
                field("Qty. in Transit"; rec."Qty. in Transit")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                }
                field("Trans. Ord. Receipt (Qty.)"; Rec."Trans. Ord. Receipt (Qty.)")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                }

                field("Trans. Ord. Shipment (Qty.)"; Rec."Trans. Ord. Shipment (Qty.)")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                }

                // TODO ReactivateJungheinrichCode uncomment following two fields
                field("AssignedInventoryOnS.Ord JH"; Rec."AssignedInventoryOnS.Ord JH")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    DecimalPlaces = 0 : 5;
                    Caption = 'Assgined Quantity Jungheinrich Sales';
                }
                field("AssignedInventoryOnT.Ord JH"; Rec."AssignedInventoryOnT.Ord JH")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    DecimalPlaces = 0 : 5;
                    Caption = 'Assgined Quantity Jungheinrich Transit';
                }
                field(JHAssignableInventory; JHAssignableInventory)
                {
                    ApplicationArea = All;
                    Caption = 'Assignable Quantity Jungheinrich';
                    Editable = false;
                    DecimalPlaces = 0 : 5;
                    BlankZero = true;
                }

                field(AvailableQty; AvailableQty)
                {
                    Caption = 'Available Quantity';
                    ApplicationArea = All;
                    DecimalPlaces = 0 : 5;
                    BlankZero = true;
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                }
                field("Vendor Item No."; Rec."Vendor Item No.")
                {
                    ApplicationArea = All;
                }
                field("DDN Item Planning Status Code"; Rec."DDN Item Planning Status Code")
                {
                    ApplicationArea = All;
                }
                field("DDN Item Status Code"; Rec.getStatusCode())
                {
                    Caption = 'Status Code (Matrix/Item)';
                    ApplicationArea = All;
                    editable = false;
                }
                field("Country/Region of Origin Code"; Rec."Country/Region of Origin Code")
                {
                    ApplicationArea = All;
                }
                field("Lead Time Calculation"; Rec."Lead Time Calculation")
                {
                    ApplicationArea = All;
                }
                field("Safety Stock Quantity"; Rec."Safety Stock Quantity")
                {
                    ApplicationArea = All;
                }
                field("Safety Lead Time"; Rec."Safety Lead Time")
                {
                    ApplicationArea = All;
                }
                field("Purchasing Code"; Rec."Purchasing Code")
                {
                    ApplicationArea = All;
                }
                field("Statistics Group"; Rec."Statistics Group")
                {
                    ApplicationArea = All;
                }
                field("trm Item Statistics Group"; Rec."trm Item Statistics Group")
                {
                    ApplicationArea = All;
                }
                field("trm Item Statistics Group 2"; Rec."trm Item Statistics Group 2")
                {
                    ApplicationArea = All;
                }
                field("trm Item Statistics Group 3"; Rec."trm Item Statistics Group 3")
                {
                    ApplicationArea = All;
                }
                field("trm Item Statistics Group 4"; Rec."trm Item Statistics Group 4")
                {
                    ApplicationArea = All;
                }
                field("trm Item Statistics Group 5"; Rec."trm Item Statistics Group 5")
                {
                    ApplicationArea = All;
                }
                field("DDN Master Collection No."; Rec."DDN Master Collection No.")
                {
                    ApplicationArea = All;
                }
                field("Prod. Forecast Quantity (Base)"; Rec."Prod. Forecast Quantity (Base)")
                {
                    ApplicationArea = All;
                }
                field("Sales (Qty.)"; Rec."Sales (Qty.)")
                {
                    ApplicationArea = All;
                }
                field("Net Change"; Rec."Net Change")
                {
                    ApplicationArea = All;
                }
                field("trm Master BOM"; Rec."trm Master BOM")
                {
                    ApplicationArea = All;
                }
                field("trm Item BOM"; Rec."trm Item BOM")
                {
                    ApplicationArea = All;
                }
                field("Reorder Point"; Rec."Reorder Point")
                {
                    ApplicationArea = All;
                }

            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenItemCard)
            {
                Caption = 'Item Card';
                Image = Item;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                RunObject = Page "Item Card";
                RunPageOnRec = true;
            }
        }
    }

    var
        callInventoryProf: Codeunit "trm Call Inventory Profile";
        AvailableQty: Decimal;
        SalesLine: Record "Sales Line";
        TempInventoryProfileTemp: Record "trm Temp Inventory Profile" temporary;
        IntercompanySetup: Record "trm Intercompany Relations";
        InventoryProfileSetup: Record "trm Inventory Profile Setup";
        CallInventoryProfile: Codeunit "trm Call Inventory Profile";
        InventoryProfileHandling: Codeunit "trm Inventory Profile Handling";
        JHAssignableInventory: Decimal;


        StyleExpression_gTxt: Text[15];

    /// <summary>
    /// Berechnet die verfügbare Menge gem. Trimit-Logik
    /// Die Berechnung basiert auf dem Schema, das von Page "trm Inventory profile" verwendet wird.
    /// cref
    /// </summary>
    procedure CalculateForm()
    var
        ddnsetup: record "DDN Setup";
    begin
        Rec.calcfields(
            // TODO ReactivateJungheinrichCode 2 Lines below            
            "AssignedInventoryOnS.Ord JH",
            "AssignedInventoryOnT.Ord JH",

            Inventory,
            "Qty. on Sales Order",
            "Qty. on Purch. Order",
            "Qty. in Transit",
            "Trans. Ord. Receipt (Qty.)",
            "Trans. Ord. Shipment (Qty.)",
            "trm Decrease Production (Base)",
            "trm Increase Production (Base)"
        );
        AvailableQty := rec.Inventory
            - rec."Qty. on Sales Order"
            + rec."Qty. on Purch. Order"
            + rec."Trans. Ord. Receipt (Qty.)"
            - rec."Trans. Ord. Shipment (Qty.)"
            - rec."trm Decrease Production (Base)"
            + rec."trm Increase Production (Base)";

        Clear(InventoryProfileHandling);
        InventoryProfileHandling.TransferAvailableOverviewTemp(TempInventoryProfileTemp);
        InventoryProfileHandling.Set_SalesLine(SalesLine);
        InventoryProfileSetup."Include Sales Orders" := true;
        InventoryProfileSetup."include Purchase Orders" := true;

        /*
                AvailableQty := InventoryProfileHandling.CalculateItemTransaction(
                    InventoryProfileSetup,
                    Rec,
                    WorkDate(),
                    Rec."Location Filter",
                    Rec."Global Dimension 1 Filter",
                    Rec."Global Dimension 2 Filter");
                */
        clear(StyleExpression_gTxt);
        if (AvailableQty <= 0) and (Rec."trm Item Type" <> rec."trm Item Type"::"Master Item") then
            StyleExpression_gTxt := 'Attention';

        clear(JHAssignableInventory);
        // TODO ReactivateJungheinrichCode 1 Line            
        JHAssignableInventory := Rec.Inventory - Rec."AssignedInventoryOnS.Ord JH" - Rec."AssignedInventoryOnT.Ord JH"
    end;

    trigger OnAfterGetRecord()
    var
    begin
        //Rec.CalcFields("DDN Indentation");
        CalculateForm();
    end;

    trigger OnOpenPAge()
    var
        myInt: Integer;
    begin
        //setrange("No.", '10001011J');
    end;
}