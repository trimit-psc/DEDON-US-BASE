/// <summary>
/// PageExtension DDN Item Card (ID 51006) extends Record Item Card.
/// <see cref="#HR3T"/>
/// <see cref="#6M4D"/>
/// </summary>
pageextension 51006 "DDN Item Card" extends "Item Card"
{
    layout
    {

        addafter("Tariff No.")
        {

            // <see cref="#6M4D"/>
            field("DDN US Tariff No."; Rec."DDN US Tariff No.")
            {
                ApplicationArea = All;
                ToolTip = 'Used for US customs.';
            }
        }
        addafter("No.")
        {
            // <see cref="#HR3T"/>
            field("No. 2"; Rec."No. 2")
            {
                ApplicationArea = All;
            }
            // <see cref="#HR3T"/>
            field("DDM Legacy System Item No."; Rec."DDM Legacy System Item No.")
            {
                ApplicationArea = All;
            }
            // <see cref="#7YAB"/>
            field("DDN Item Planning Status Code"; Rec."DDN Item Planning Status Code")
            {
                ApplicationArea = All;
            }
        }
        modify("trm ReorderPoint")
        {
            Enabled = true;
        }
        modify("trm MaximumInventory")
        {
            Enabled = true;
        }
        modify("trm ReorderQuantity")
        {
            Enabled = true;
        }

        addafter("Unit Price")
        {
            /// <summary>
            /// akutell gültigen Listenpreis anzeigen
            /// <see cref="#K2RD"/>
            /// </summary>
            field("DDN List Price"; DefaultUnitPrice_gDec)
            {
                Caption = 'todays listprice';
                ToolTip = 'This price is calculated based on all salesprice rules in the system. To assume the "right" price the prices for all customers at the current workdate are considered. Discounts and customer specific agreements are out of scope.';
                ApplicationArea = All;
                DecimalPlaces = 2 : 2;
                Editable = false;
                BlankNumbers = BlankNeg;
            }
            field("DDN Intercompany Price"; DefaultIntercompanyPrice_gDec)
            {
                Caption = 'todays Intercompany price';
                ToolTip = 'This price is calculated based on a custoemr that is setup as an intercompany customer';
                ApplicationArea = All;
                DecimalPlaces = 2 : 2;
                Editable = false;
                BlankNumbers = BlankNeg;
            }
        }
        addlast(content)
        {
            group(DDNGroup)
            {
                Caption = 'DEDON';


                // field("is active Version"; Rec."is active Version")
                // {
                //     ApplicationArea = All;
                //     ToolTip = 'Das Setzen eines Hakens bewirkt, dass einem anderen Artikel, bei dem alle VarDims gleich sind und sich nur die Version unterscheidet der Haken ActiveVersion entzogen wird.';
                // }
                group("COR-DDN Version and Country")
                {

                    Caption = 'Version and Country';
                    group(DDNSalesVersion1)
                    {
                        Caption = 'Best Version Sales 1';

                        field("COR-DDN Sales Qty. Filter 1"; referencQty_lDec[1])
                        {
                            ApplicationArea = All;
                            Caption = 'Quantity you want to sell';
                            ToolTip = 'Quantity either defined via DEDON-Setup or special searchtable base on item statistic groups.';
                            DecimalPlaces = 2 : 0;

                            trigger OnValidate()
                            var
                            begin
                                Rec.setrange("COR-DDN Sales Qty. Filter 1", referencQty_lDec[1]);
                                CalcBestVersionAndCountrySales(false);
                            end;

                        }
                        field("COR-DDN BestVersion Sales 1"; BestVersionSales_gCod[1])
                        {
                            ApplicationArea = All;
                            Editable = false;
                            Caption = 'Best Version';
                            ToolTip = 'Indicate wich Version of this item fits best for the Quantity.';
                        }
                        field("COR-DDN BestCountry Sales 1"; BestCountrySales_gCod[1])
                        {
                            ApplicationArea = All;
                            Editable = false;
                            Caption = 'Best Country';
                        }
                        field("COR-DDN thisItemIsBestVersion Sales 1"; thisItemIsBestVersionSales_gBool[1])
                        {
                            ApplicationArea = All;
                            Editable = false;
                            Caption = 'This item fits best';
                            ToolTip = 'Indicates if this item is the best version for the selected Quantity';
                        }
                    }

                    group(DDNSalesVersion2)
                    {
                        Caption = 'Best Version Sales 2';

                        field("COR-DDN Sales Qty. Filter 2"; referencQty_lDec[2])
                        {
                            ApplicationArea = All;
                            Caption = 'Quantity you want to sell';
                            ToolTip = 'Quantity either defined via DEDON-Setup or special searchtable base on item statistic groups.';
                            DecimalPlaces = 2 : 0;

                            trigger OnValidate()
                            var
                            begin
                                Rec.setrange("COR-DDN Sales Qty. Filter 2", referencQty_lDec[2]);
                                CalcBestVersionAndCountrySales(false);
                            end;

                        }
                        field("COR-DDN BestVersion Sales 2"; BestVersionSales_gCod[2])
                        {
                            ApplicationArea = All;
                            Editable = false;
                            Caption = 'Best Version';
                            ToolTip = 'Indicate wich Version of this item fits best for the Quantity.';
                        }
                        field("COR-DDN BestCountry Sales 2"; BestCountrySales_gCod[2])
                        {
                            ApplicationArea = All;
                            Editable = false;
                            Caption = 'Best Country';
                        }
                        field("COR-DDN thisItemIsBestVersion Sales 2"; thisItemIsBestVersionSales_gBool[2])
                        {
                            ApplicationArea = All;
                            Editable = false;
                            Caption = 'This item fits best';
                            ToolTip = 'Indicates if this item is the best version for the selected Quantity';
                        }
                    }

                    group(DDNPurchaseVersion)
                    {
                        Caption = 'Best Version Purchase';

                        field("COR-DDN BestVersion Purchase"; BestVersionPurchase_gCod)
                        {
                            ApplicationArea = All;
                            Editable = false;
                            Caption = 'Best Version';
                            ToolTip = 'Indicate wich Version of this item fits best for next purchase order.';
                        }
                        field("COR-DDN BestCountry Purchase"; BestCountryPurchase_gCod)
                        {
                            ApplicationArea = All;
                            Editable = false;
                            Caption = 'Best Country';
                        }
                        field("COR-DDN thisItemIsBestVersion Purchase"; thisItemIsBestVersionPurchase_gBool)
                        {
                            ApplicationArea = All;
                            Editable = false;
                            Caption = 'This item fits best';
                            ToolTip = 'Indicates if this item is the best version';
                        }
                    }
                }

                group(DDNAdditionalInfo)
                {
                    Caption = 'Additional Info';

                    /// <summary>
                    /// <see cref="#1QA2"/>
                    /// </summary>
                    field("DDN Fabric Consumption"; Rec."DDN Fabric Consumption")
                    {
                        ToolTip = 'This information is considered by the purchaser who is reliable on cuchons. He fetches the fabric consumption for his analysis.';
                        ApplicationArea = All;
                        Editable = fabricsEnabled_gBool;
                    }
                    field("DDN Item Planning Status Code (Copy)"; Rec."DDN Item Planning Status Code")
                    {
                        ApplicationArea = All;
                    }
                    field("DDN Item Status Code"; Rec."DDN Item Status Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'This is a DEDON field that is stored in the table MatrixCell of the corresponding master.';
                    }
                    field("DDN Item Status Code 2"; Rec."DDN Item Status Code 2")
                    {
                        ApplicationArea = All;
                        ToolTip = 'This is a DEDON field that is uses as Fallback if an item has no relation to a master; but needs a status code anyway.';
                    }
                    field("DDN Designer Code"; Rec."DDN Designer Code")
                    {
                        ApplicationArea = All;
                    }
                }
            }
        }
        /// <summary>
        /// <see cref="#5GC8"/>
        /// </summary>        
        modify(Replenishment)
        {
            // Attention! This group is set to visible = false by Trimit
            // If the Trimit app is upgraded after DEDON app was compiled this setting will win again
            // Make sure to recompile DEDON app after implementing a Trimit hotfix
            Visible = true;
        }

        modify(GTIN)
        {
            Visible = false;
            Editable = false;
        }
        addAfter("GTIN")
        {
            field("GTIN (automatic)"; rec.GTIN)
            {
                ApplicationArea = All;
                //Editable = Rec."trm Item Type" <> Rec."trm Item Type"::"Master Item";
                Editable = true;
                Visible = true;
                AssistEdit = true;
                ToolTip = 'You can insert a new GTIN via Number Series. Behind this field there is some functionality to check if a GTIN is valid and maybe already assigned to another item.';

                trigger OnAssistEdit()
                var
                    GtinNotForMasterItemError_lLbl: Label 'It is not allowed to define a gtin for a Master Item. Please assign them directly to an item';
                    gtinFunctions: Codeunit "COR-DDN Gtin Functions";
                begin
                    if Rec."trm Item Type" = Rec."trm Item Type"::"Master Item" then
                        Error(GtinNotForMasterItemError_lLbl);
                    Rec.GTIN := gtinFunctions.getNextGtin();
                    Rec.Validate(GTIN);
                end;
            }
        }
    }
    actions
    {
        addlast(Availability)
        {
            action("COR open DSDS Schedule")
            {
                ApplicationArea = All;
                Image = ItemAvailability;
                Caption = 'DEDON Shipment Date Schedule (DSDS)';

                trigger OnAction()
                var
                    dsdsAvailitbilityMgmt_lCodeUnit: Codeunit "COR DSDS Availibility Mgmt.";
                    Schedule_lPage: Page "COR DSDS Schedule Line";
                begin
                    Schedule_lPage.SetContext(Rec);
                    Schedule_lPage.Run();
                end;
            }
        }
        addlast(Reporting)
        {
            group("COR-DDN Print Label Group")
            {
                Caption = 'Label';
                action("COR-DDN print A6 Label")
                {
                    ApplicationArea = All;
                    Caption = 'Print A6 label';
                    Image = PrintCover;
                    Ellipsis = true;

                    trigger OnAction()
                    var
                    begin
                        Rec.printLabel(1);
                    end;
                }
                action("COR-DDN print A5 Label")
                {
                    ApplicationArea = All;
                    Caption = 'Print A5 label';
                    Image = PrintCover;
                    Ellipsis = true;

                    trigger OnAction()
                    var
                    begin
                        Rec.printLabel(0);
                    end;
                }
            }
        }
    }


    var
        DefaultUnitPrice_gDec: Decimal;
        DefaultIntercompanyPrice_gDec: Decimal;
        fabricsEnabled_gBool: Boolean;

        thisItemIsBestVersionSales_gBool: array[2] of Boolean;
        referencQty_lDec: array[2] of Decimal;
        BestVersionSales_gCod: array[2] of Code[10];
        BestCountrySales_gCod: array[2] of Code[10];
        BestVersionPurchase_gCod: Code[10];
        BestCountryPurchase_gCod: Code[10];
        thisItemIsBestVersionPurchase_gBool: Boolean;
        [inDataSet]
        ItemUsesCountry: Boolean;
        [inDataSet]
        isVisible: Boolean;

    trigger OnAfterGetRecord()
    var
    begin
        // Die Page ist auf RefreshOnActivate eingestellt. Da sich schließende Fenster (z.B. VarDim Master)
        // zu einem refresh führen, kann es zu Fehlermeldungen bzgl. Schreibtransaktionen kommen
        // Diese werden durch nachfolgendne Code unterbunden.
        if xRec."No." = Rec."No." then
            exit;

        // #K2RD
        DefaultUnitPrice_gDec := Rec.getDefaultUnitPrice();
        DefaultIntercompanyPrice_gDec := Rec.getIntercompanyPrice();
        fabricsEnabled_gBool := Rec.fabricsEnabled();
        if not BestVersionAndCountryApplicable() then begin
            isVisible := false;
            BestCountrySales_gCod[1] := '-';
            BestCountrySales_gCod[2] := '-';
            BestCountryPurchase_gCod := '-';
            BestVersionSales_gCod[1] := '-';
            BestVersionSales_gCod[2] := '-';
            BestVersionPurchase_gCod := '-';
            exit;
        end;
        isVisible := false;
        CalcBestVersionAndCountrySales(true);
        CalcBestVersionAndCountryPurchase();

        if not itemUsesCountry then begin
            BestCountrySales_gCod[1] := '-';
            BestCountrySales_gCod[2] := '-';
            BestCountryPurchase_gCod := '-';
        end;
    end;

    local procedure CalcBestVersionAndCountrySales(doInitQuantityFilters: Boolean)
    var
    begin
        // Versionsermittlung ggf. dekativieren
        if Rec."trm Master No." = '' then
            exit;
        Rec.CalcBestVersionAndCountrySalesOnItemCard(BestVersionSales_gCod, BestCountrySales_gCod, thisItemIsBestVersionSales_gBool, doInitQuantityFilters);
        if Rec.getFilter("COR-DDN Sales Qty. Filter 1") <> '' then begin
            if evaluate(referencQty_lDec[1], Rec.getFilter("COR-DDN Sales Qty. Filter 1")) then;
        end;
        if Rec.getFilter("COR-DDN Sales Qty. Filter 2") <> '' then begin
            if evaluate(referencQty_lDec[2], Rec.getFilter("COR-DDN Sales Qty. Filter 2")) then;
        end;
    end;

    local procedure CalcBestVersionAndCountryPurchase()
    var

    begin
        if Rec."trm Master No." = '' then
            exit;
        Rec.CalcBestVersionAndCountryPurchaseOnItemCard(BestVersionPurchase_gCod, BestCountryPurchase_gCod, thisItemIsBestVersionPurchase_gBool, itemUsesCountry);
    end;

    local procedure BestVersionAndCountryApplicable(): Boolean
    var
        ActiveVerionMgmt: Codeunit "COR-DDN ActiveVersion Mgmt.";
    begin
        exit(ActiveVerionMgmt.BestVersionAndCountryApplicable(Rec));
    end;
}