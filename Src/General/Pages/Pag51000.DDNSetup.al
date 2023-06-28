/// <summary>
/// Page DDN Setup (ID 51000).
/// </summary>
page 51000 "DDN Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "DDN Setup";
    InsertAllowed = false;
    DeleteAllowed = false;
    Caption = 'DEDON Setup';

    layout
    {
        area(Content)
        {
            group(Icons)
            {
                Caption = 'Icons';
                /// <summary>
                /// <see cref="#D5C7"/>
                /// </summary>
                field(IconOk; Rec.IconOk)
                {
                    Style = Favorable;
                    StyleExpr = true;
                    ApplicationArea = All;
                    ToolTip = 'This symbol inidcates thet no conflict exists.';
                }
                /// <summary>
                /// <see cref="#D5C7"/>
                /// </summary>
                field(IconWarning; Rec.IconWarning)
                {
                    Style = Ambiguous;
                    StyleExpr = true;
                    ApplicationArea = All;
                    ToolTip = 'This Sympol informs the user that there is a minor issue that should be oserved.';
                }
                /// <summary>
                /// <see cref="#D5C7"/>
                /// </summary>
                field(IconError; Rec.IconError)
                {
                    Style = Attention;
                    StyleExpr = true;
                    ApplicationArea = All;
                    ToolTip = 'This symbol indicates a conflict wicht need to be solved';
                }
            }

            group(PriceAndCostGroup)
            {
                Caption = 'Prices and Costs';
                field("Enable Price/Cost Determin."; Rec."Enable Price/Cost Determin.")
                {
                    ApplicationArea = All;
                    ToolTip = 'When you mark this checkbox then default purchase prices and sales prices are calculated on the item card. If perfomance issues occure or errors occure please deactivate this to avoid downtime in daily work.';

                }
                field("IC Listprice Customer"; Rec."Intercompany Customer")
                {
                    ApplicationArea = All;
                    ToolTip = 'This customer is used as a template to calculate the intercompany price on the item card.';
                }
                field("Listprice Customer"; Rec."Listprice Customer")
                {
                    ApplicationArea = All;
                    ToolTip = 'This customer is used as a template to calculate the listprice on the item card.';
                }
                field("IC Currency Exch. Search Table"; Rec."IC Currency Exch. Search Table")
                {
                    ApplicationArea = All;
                    ToolTip = 'This table is used to do currency exchanges whenever a sales prices is calculated via purchase price.';
                }
            }

            group(VarDimAndMasterDataGroup)
            {
                Caption = 'VarDim and Master Data';
                field("Search Table Code ColorGroup"; Rec."Search Table Code ColorGroup")
                {
                    ApplicationArea = All;
                    ToolTip = 'Please put in a search table with one search-column for the color and up to 10 result Columns to determine in wich Color Group a color is included.';
                    //Hier ist eine Suchtabelle zu hinterlegen mit einer Suchspalte für die Farben und bis zu 10 Ergebnisspalten um festzugelgen, ob die Farbe in der Farbauswahlgruppe eingschlossen ist oder nicht.
                }
                /// <summary>
                /// <see cref="#DM4X"/>
                /// </summary>
                field("enable Bom Creation for BI"; Rec."enable Bom Creation for BI")
                {
                    ApplicationArea = All;
                    ToolTip = 'If this switch is enabled, a temporary bill of material will be created when entering a quantity in a config item in sales line. With the help of the temporary bom an item number of the furniture will be identified (formaly known as set). This number is used within BI analysis. Please don''t dectivate this switch unless operation process is endangerd due to system errors.';
                    //Wenn dieser Schalter eingeschaltet ist, wird beim Entfalten der Stückliste in der VK-Zeile zuvor eine temporäre Stückliste erzeugt. Mit Hilfe der temporären Stückliste kann die Artikelnummer des Möbels (früher als Set bezeichnet) ermittelt werden. Sie steht dann für BI-Analysen zur Verfügung. Er sollte nur dann dekativiert werden wenn es nachvollziehbar Probleme bei dem Vorgang gibt, die das operative Geschäft beeinträchtigen.
                }
                /// <summary>
                /// <see cref="#1QA2"/>
                /// </summary>
                field("Fabric Item Categories"; Rec."Fabric Item Categories")
                {
                    ApplicationArea = All;
                    ToolTip = 'You can use "|" and other BC filter expressions to define a filter. Items fitting to these categories will have additional inforamtion attached in an infobox within sales lines.';
                }
                /// <summary>
                /// Status in Matrixzelle vorbelegen
                /// <see cref="PLD3"/>
                /// </summary>
                /// <param name="Rec"></param>                
                field("Matrix Cell default Status"; Rec."Matrix Cell default Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Matrix Cell default Status Code field.';
                }
                field("GTIN Number Series"; Rec."GTIN Number Series")
                {
                    ApplicationArea = All;
                }
                field("Check GTIN Duplicate"; Rec."Check GTIN Duplicate")
                {
                    ApplicationArea = All;
                    ToolTip = 'Tell the system what to do if dublicate GTINs are detected.';
                }
            }

            group(bestVersion)
            {
                Caption = 'Best Version Calculation Sales';
                /// <summary>
                /// <see cref="#H42U"/>
                /// </summary>
                field("DDN VarDim VERSION"; Rec."DDN VarDim VERSION")
                {
                    ApplicationArea = All;
                    ToolTip = 'This VarDim is used to reveal the version out of an item number. This field is essential in the process of finding the best fitting Version in Sales process depending on availibility of old versions of an item on Stock';
                    ShowMandatory = true;
                }
                field("DDN VarDim COUNTRY"; Rec."DDN VarDim COUNTRY")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the VarDim Type Country field.';
                    Visible = true;
                }
                field("Buy from Country Searchtable"; Rec."Searchtable Buy from Country")
                {
                    ApplicationArea = All;
                    ToolTip = 'If you enter a searchtable here then BEST_COUNTRY_SALES will try to find a country within this search table. This country will be used to explode the bom within item or purchase context. BEST_COUNTRY_SALES might also use this table as a fallback.';
                }
                field("Result Column Buy from Country"; Rec."Result Column Buy from Country")
                {
                    ApplicationArea = All;
                    ToolTip = 'Declare in wich column a country code is positioned.';
                }
                field("Inventory Profile best Version"; Rec."Inventory Profile best Version")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Inventory Profile best Version field in sales context.';
                }
                field("ItemPlannungStatus best Vers."; Rec."ItemPlannungStatus best Vers.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Define the item planning status wich are allowed to be considered when investiagting the optimal version of an item during sales process.';
                }
                field("Status best Vers. 2"; Rec."Status best Vers. 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Define the item planning status wich are allowed to be considered when investiagting the optimal version when purchasing an item.';
                }
                field("Show Version switched Message"; Rec."Show Version switched Message")
                {
                    ApplicationArea = All;
                }
                field("DDN VarDim COLOR Filter"; Rec."DDN VarDim COLOR Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the VarDim Type Color Filter field.';
                }
                field("enable Version Calc Item Card"; Rec."enable Version Calc Item Card")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enable Version Calculation on Item Card field.';
                }

                field("Default Sales Qty. Filter 1"; Rec."Default Sales Qty. Filter 1")
                {
                    ApplicationArea = All;
                    ToolTip = 'Define the first Quantity you want to use to simulate the best version calculation in Sales. It is uses as a flowFilter on the item Card.';
                }
                field("Default Sales Qty. Filter 2"; Rec."Default Sales Qty. Filter 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Define the second Quantity you want to use to simulate the best version calculation in Sales. It is uses as a flowFilter on the item Card.';
                }
                field("Search table Sales Qty. Filter"; Rec."Search table Sales Qty. Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Define the first and second quantity that should be used to calculate the best version in Sales. The search table considers item category 1 + 3.';
                }
                field("Action no purch version found"; Rec."Action no purch version found")
                {
                    ApplicationArea = All;
                    ToolTip = 'if you select "show error" then trimit formula will stop with an error. The user will be unable to continue unless product management reworks status in matrix cells. If you select "ignore" then your formulas have to scope with the way, a default version is determined.';
                }
                field("Action no sales version found"; Rec."Action no sales version found")
                {
                    ApplicationArea = All;
                    ToolTip = 'if you select "show error" then trimit formula will stop with an error. The user will be unable to continue unless product management reworks status in matrix cells. If you select "ignore" then your formulas have to scope with the way, a default version is determined.';
                }
            }
            group(RoleCenterSetups)
            {
                Caption = 'Role Center Setup';

                /// <summary>
                /// <see cref="#MNVF"/>
                /// </summary>   
                field("Location Code Main"; Rec."Location Code Main")
                {
                    ApplicationArea = All;
                }
                /// <summary>
                /// <see cref="#MNVF"/>
                /// </summary>   
                field("Location Code Winsen"; Rec."Location Code Winsen")
                {
                    ApplicationArea = All;
                }
                /// <summary>
                /// <see cref="#MNVF"/>
                /// </summary>   
                field("Location Code 1_WMS"; Rec."Location Code 1_WMS")
                {
                    ApplicationArea = All;
                }
            }

            group(AvailibilityMangement)
            {
                Caption = 'Availibility Management / Dedon Shipment Date Scheduler (DSDS)';

                field("Availibility Check with past"; Rec."Availibility Check with past")
                {
                    ApplicationArea = All;
                    ToolTip = 'Accepts the possibility of setting that the earliest shipment date might be in the past if theis switch is enabled.';
                }
                field("Leadtime on neg. availiblity"; Rec."Leadtime on neg. availiblity")
                {
                    ApplicationArea = All;
                    ToolTip = 'if purchase order quantity decreses the demand then the reordering time will be used to calculate the next earliest shipment date.';
                }
                field("Force Avail. Sales Line Modify"; Rec."Force Avail. Sales Line Modify")
                {
                    ApplicationArea = All;
                    ToolTip = 'When no modification within earliest shipemnt date has been made then sales lines don''t get modified. For some reasons it might be nescessarry to force it anyway. Usually beacause of debugging.';
                }
                field("Reduce by JH assigned Invnet"; Rec."Reduce by JH assigned Invnet")
                {
                    ApplicationArea = All;
                    ToolTip = 'Reduces the quantity on stock by the quantity in teh field Assigned Inventory in sales lines. This is a replacement for reservation mechanism build by ISystems.';
                }
                field("Worst case replen. DateForm."; Rec."Worst case replen. DateForm.")
                {
                    ApplicationArea = All;
                    ToolTip = 'if no replenishment time is available on the item then this value is considered as worst case.';
                }
                field("Worst case replen. rounding"; Rec."Worst case replen. rounding")
                {
                    ApplicationArea = All;
                    ToolTip = 'It is a good idea to round upward to the next Monday of a week or to the first of the next month to avoid that a recalculation of availibility increases day by day.';
                }
                field("DSDS Initial Priority Model"; Rec."DSDS Initial Priority Model")
                {
                    ApplicationArea = All;
                    ToolTip = 'When Sales Lines are unterminated they need to get a priority. Here you devcide on wich Model the priority get''s calculated. The models "By Order Date" and "By Shipment Date" base on an optimized world. It might happen that your order line gets priorised somwhere before existing orders.';
                }
                field("DSDS Batch Priority Model"; Rec."DSDS Batch Priority Model")
                {
                    ApplicationArea = All;
                    ToolTip = 'This Model is used to calculate priorities. In a nightly run the model matches sales orders to stock and purchase orders. This Batch modiefies the priority within the sales line accoring to the chosen model.';
                }
                field("enable DSDS Sales Line Split"; Rec."enable DSDS Sales Line Split")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enable DSDS Split Sales Line to multiple incoming lines field.';
                }
                field("DSDS Batch commit per Item"; Rec."DSDS Batch commit per Item")
                {
                    ApplicationArea = All;
                    ToolTip = 'Activate this switch if locking on sales lines occures due to long running batch calculation.';
                }
                field("transfer date spec. order"; Rec."transfer date spec. order")
                {
                    ApplicationArea = All;
                    ToolTip = 'If you enable this switch then teh Shipment date will be overwritten by the DSDS earliest shipment date for lines that are special order lines. This might be useful in constellation with cushions.';
                }
            }
            group(Jungheinrich)
            {
                Caption = 'Jungheinrich';

                field("enable Warehouse JH Status"; Rec."enable Warehouse JH Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enable Jungheinrich Status Change on Warehouse Shipment release. field.';
                }
            }
            group(Container)
            {
                Caption = 'Container';
                field("Default Account Cont. Prepay"; Rec."Default Account Cont. Prepay")
                {
                    ApplicationArea = All;
                    visible = false;
                    Description = 'Is not longer used because aacounts bevome calculated via posting groups.';
                }
                field("Reason Code Cont. Final Inv."; Rec."Reason Code Cont. Final Inv.")
                {
                    ApplicationArea = All;
                }
                field("Reason Code Cont. Prepy"; Rec."Reason Code Cont. Prepay")
                {
                    ApplicationArea = All;
                }
                field("Appendix Cont. Prepay"; Rec."Appendix Cont. Prepay")
                {
                    ApplicationArea = All;
                    ToolTip = 'Will be appended to the Vendor invoice number when creating invoices for account posting via Containers';
                }
                field("Appendix Cont. Final Inv."; Rec."Appendix Cont. Final Inv.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Will be appended to the Vendor invoice number when creating invoices for item posting via Containers';
                }
                field("G/L Lines in Cont. item Inv."; Rec."G/L Lines in Cont. item Inv.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the G/L Account Lines in Container Final Payment field.';
                }
            }
            group(Printing)
            {
                Caption = 'Printing';

                field("Report ID Item Label A5"; Rec."Report ID Item Label A4")
                {
                    ApplicationArea = All;
                }
                field("Report ID Item Label A6"; Rec."Report ID Item Label A6")
                {
                    ApplicationArea = All;
                }
            }
            group(Production)
            {
                Caption = 'Prodcution';

                field("prevent rel. order posting"; Rec."prevent rel. order posting")
                {
                    ApplicationArea = All;
                    ToolTip = 'If you activate this trigger then all sales lines will be handled as if there is no related trimit order. This is a workaround to prevent posting of production headers indirectly via sales line.';
                }
            }
            group(Logistic)
            {
                Caption = 'Logistic';


                field("disable prepayment check"; Rec."disable prepaym. amount check")
                {
                    ApplicationArea = All;
                    ToolTip = 'If you set this field then the method CheckPrepmtAmounts() in sales line will be scipped. This is an emergency exit when running into trouble with warehous posting.';
                }
            }
        }
    }
}


