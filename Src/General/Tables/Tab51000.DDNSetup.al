table 51000 "DDN Setup"
{
    DataClassification = ToBeClassified;
    Caption = 'Table51000 DDN Setup Caption';
    LookupPageId = "DDN Setup";

    fields
    {
        /// <summary>
        /// Primary KEy for the setup table
        /// </summary>
        field(1; PK; Code[1])
        {
            DataClassification = ToBeClassified;
            Caption = 'Primary KEy';
        }

        /// <summary>
        /// UTF-Coded Character of the Icon that is defined as a warning. It is a ⚠ per default.
        /// Please use GetWarningIcon() in your AL-Code.
        /// <see cref="#D5C7"/>
        /// </summary>
        field(2; IconWarning; Text[1])
        {
            DataClassification = ToBeClassified;
            Caption = 'Icon Warning';
        }

        /// <summary>
        /// UTF-Coded Character of the icon that is defined as a warning. It is a ✓ per default
        /// Please use GetOkIcon() in your AL-Code.
        /// <see cref="#D5C7"/>
        /// </summary>
        field(3; IconOk; Text[1])
        {
            DataClassification = ToBeClassified;
            Caption = 'Icon OK';
        }

        /// <summary>
        /// UTF-Coded Character of the icon that is defined as an error. It is a ✕ per default
        /// Please use GetErrorIcon() in your AL-Code.
        /// <see cref="#D5C7"/>
        /// </summary>        
        field(4; IconError; Text[1])
        {
            DataClassification = ToBeClassified;
            Caption = 'Icon Error';
        }

        field(5; "Enable Price/Cost Determin."; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Enable Price / Cost Determination';
        }

        field(6; "Search Table Code ColorGroup"; code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Search Table Code ColorGroup';
            TableRelation = "trm Search Table Header";
        }

        /// <summary>
        /// <see cref="#DM4X"/>
        /// </summary>
        field(7; "enable Bom Creation for BI"; Boolean)
        {
            Caption = 'Enable BOM-Creation for BI';
            DataClassification = ToBeClassified;
        }

        /// <summary>
        /// Used to enable or show fields for fabric consumption
        /// <see cref="#1QA2"/>
        /// </summary>
        field(8; "Fabric Item Categories"; Code[60])
        {
            TableRelation = "Item Category";
            ValidateTableRelation = false;
            DataClassification = ToBeClassified;
        }

        /// <summary>
        /// Configure location code for Main
        /// <see cref="#MNVF"/>
        /// </summary>        
        field(10; "Location Code Main"; Code[20])
        {
            Caption = 'Location Code Main';
            TableRelation = Location;
        }

        /// <summary>
        /// Configure location code for Winsen
        /// <see cref="#MNVF"/>
        /// </summary>        
        field(11; "Location Code Winsen"; Code[20])
        {
            Caption = 'Location Code Winsen';
            TableRelation = Location;
        }

        /// <summary>
        /// <see cref="#MNVF"/>
        /// </summary>        
        field(12; "Location Code 1_WMS"; Code[20])
        {
            Caption = 'Location Code 1_WMS';
            TableRelation = Location;
        }

        /// <summary>
        /// Ermittlung der passendstend Version im Verkauf
        /// <see cref="#H42U"/>
        /// </summary>
        field(51009; "DDN VarDim VERSION"; Code[10])
        {
            TableRelation = "trm VarDim Type" where(Type = const("Variant"));
            Caption = 'VarDim Type Version';
            DataClassification = ToBeClassified;
        }

        /// <summary>
        /// Ermittlung der passendstend Version im Verkauf
        /// <see cref="#H42U"/>
        /// </summary>
        field(51010; "Inventory Profile best Version"; Code[10])
        {
            DataClassification = ToBeClassified;
            Caption = 'Inventory Profile best Version';
            TableRelation = "trm Inventory Profile Setup";
        }

        /// <summary>
        /// beschränkt die Artikelstatus, die zur Ermittlung der besten Version berücksichtigt werden dürfen
        /// Das Feld lautet ItemPlannungStatus. Jedoch ist das inkorrekt. Es geht um das Feld Artikel Status.
        /// <see cref="#H42U"/>
        /// </summary>
        field(51011; "ItemPlannungStatus best Vers."; Code[100])
        {
            TableRelation = "trm Status Code";
            Caption = 'Item Status Filer best Version Sales';
            ValidateTableRelation = false;
            DataClassification = ToBeClassified;
        }

        /// <summary>
        /// <see cref="#H42U"/>
        /// </summary>
        field(51012; "Show Version switched Message"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Show Version switched Message';
        }

        field(51013; "DDN VarDim COLOR Filter"; Code[50])
        {
            TableRelation = "trm VarDim Type" where(Type = const("Variant"));
            Caption = 'VarDim Type Color Filter';
            ValidateTableRelation = false;
            DataClassification = ToBeClassified;
        }
        /// <summary>
        /// <see cref="#H42U"/>
        /// </summary>
        field(51014; "Status best Vers. 2"; Code[100])
        {
            TableRelation = "trm Status Code";
            Caption = 'Item Status Filer best Version Purchase';
            ValidateTableRelation = false;
            DataClassification = ToBeClassified;
        }
        /// <summary>
        /// <see cref="#H42U"/>
        /// </summary>        
        field(51015; "enable Version Calc Item Card"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Enable Version Calculation on Item Card';

        }
        /// <summary>
        /// Suchtabelle mit der bestimmt wird, welche Vekraufsmenge für die Versionermittlung Verkauf
        /// auf der Artikelkarte genutzt werden. Die Suchtbaelle bezieht sich Stand 21.12.2022 auf
        /// Artikelkategorie 1 und 3
        /// <see cref="#H42U"/>
        /// </summary>        
        field(51016; "Search table Sales Qty. Filter"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Search table for Quantitty Filter at Item card';
            TableRelation = "trm Search Table Header";
        }

        field(51017; "Default Sales Qty. Filter 1"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Default Quantity for Sales Filter 1';
        }
        field(51018; "Default Sales Qty. Filter 2"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Default Quantity for Sales Filter 2';
        }
        field(51019; "Action no sales version found"; option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "show error","ignore";
            OptionCaption = 'show error,ignore';
            Caption = 'Action if no sales version found';
        }
        field(51020; "Action no purch version found"; option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "show error","ignore";
            OptionCaption = 'show error,ignore';
            Caption = 'Action if no purchase version found';
        }
        /// <summary>
        /// Ermittlung der passendstend Version im Verkauf
        /// <see cref="#H42U"/>
        /// </summary>
        field(51021; "DDN VarDim COUNTRY"; Code[10])
        {
            TableRelation = "trm VarDim Type" where(Type = const("Variant"));
            Caption = 'VarDim Type Country';
            DataClassification = ToBeClassified;
        }
        field(51022; "Availibility Check with past"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Verfügbarkeitsberechnung mit Vergangenheitswerten';
        }
        field(51023; "IC Currency Exch. Search Table"; code[20])
        {
            Caption = 'Searchtable for Intercompany Currency Exchange';
            DataClassification = ToBeClassified;
            TableRelation = "trm Search Table Header";
        }
        /// <summary>
        /// Bei nicht hinreichender Verfügbarkeit werden Wiederbeschaffungszeiten des Artikels als Basis herangezogen
        /// <see cref="3N8B"/>
        /// </summary>
        field(51024; "Leadtime on neg. availiblity"; boolean)
        {
            Caption = 'Leadtime on ngeative availibility';
            DataClassification = ToBeClassified;
        }
        /// <summary>
        /// VK-Zeilen auch dnan modifizieren wenn sich nichts an der Verfügbakreitberechnung geändert hat
        /// Dient eher Debug-Zwecken
        /// <see cref="3N8B"/>
        /// </summary>
        field(51025; "Force Avail. Sales Line Modify"; Boolean)
        {
            Caption = 'Force writing Availibility on Sales Line';
            DataClassification = ToBeClassified;
        }
        field(51026; "Reduce by JH assigned Invnet"; Boolean)
        {
            Caption = 'Reduce stock by JH assigned Invnetory';
            DataClassification = ToBeClassified;
        }
        field(51027; "Worst case replen. DateForm."; DateFormula)
        {
            Caption = 'Worst case dateformula for replenishment';
            DataClassification = ToBeClassified;
        }
        field(51028; "Worst case replen. rounding"; DateFormula)
        {
            Caption = 'Date Rounding buffer';
            DataClassification = ToBeClassified;
        }
        /// <summary>
        /// Status in Matrixzelle vorbelegen
        /// <see cref="PLD3"/>
        /// </summary>
        /// <param name="Rec"></param>
        field(51029; "Matrix Cell default Status"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Matrix Cell default Status Code';
            TableRelation = "trm Status Code";
        }
        field(51030; "DSDS Initial Priority Model"; enum "COR DSDS Priority Model")
        {
            DataClassification = ToBeClassified;
            Caption = 'Initial Priority Model';
        }
        field(51031; "DSDS Batch Priority Model"; enum "COR DSDS Priority Model")
        {
            DataClassification = ToBeClassified;
            Caption = 'Batch Priority Model';
        }
        field(51032; "Searchtable Buy from Country"; Code[20])
        {
            Caption = 'Buy from Country Searchtable';
            DataClassification = ToBeClassified;
            TableRelation = "trm Search Table Header";
        }
        field(51033; "Result Column Buy from Country"; Option)
        {
            Caption = 'Buy from Country Result Columns';
            DataClassification = CustomerContent;
            OptionCaption = 'Default,Decimal Figure 1,Decimal Figure 2,Decimal Figure 3,Decimal Figure 4,Decimal Figure 5,Decimal Figure 6,Decimal Figure 7,Decimal Figure 8,Decimal Figure 9,Decimal Figure 10,Decimal Figure 11,Decimal Figure 12,Decimal Figure 13,Decimal Figure 14,Decimal Figure 15,Decimal Figure 16,Decimal Figure 17,Decimal Figure 18,Decimal Figure 19,Decimal Figure 20,,,,,,,,,,,,,,,,,,,,Code 1,Code 2,Code 3,Code 4,Code 5,Code 6,Code 7,Code 8,Code 9,Code 10';
            OptionMembers = Default,"Decimal Figure 1","Decimal Figure 2","Decimal Figure 3","Decimal Figure 4","Decimal Figure 5","Decimal Figure 6","Decimal Figure 7","Decimal Figure 8","Decimal Figure 9","Decimal Figure 10","Decimal Figure 11","Decimal Figure 12","Decimal Figure 13","Decimal Figure 14","Decimal Figure 15","Decimal Figure 16","Decimal Figure 17","Decimal Figure 18","Decimal Figure 19","Decimal Figure 20",,,,,,,,,,,,,,,,,,,,"Code 1","Code 2","Code 3","Code 4","Code 5","Code 6","Code 7","Code 8","Code 9","Code 10";
        }
        field(51034; "enable DSDS Sales Line Split"; Boolean)
        {
            Caption = 'Enable DSDS Split Sales Line to multiple incoming lines';
        }
        /// <summary>
        /// <see cref="#C4JZ"/>
        /// </summary>
        field(51035; "enable Warehouse JH Status"; Boolean)
        {
            Caption = 'Enable Jungheinrich Status Change on Warehouse Shipment release.';
        }
        field(51036; "DSDS Batch commit per Item"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Send Commit after each item in DSDS Batch';
        }
        field(51037; "Default Account Cont. Prepay"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Default Account Container Content for Prepayment';
            TableRelation = "G/L Account";
        }
        field(51038; "Reason Code Cont. Prepay"; Code[10])
        {
            Caption = 'Reason Code Container Prepayment';
            DataClassification = ToBeClassified;
            TableRelation = "Reason Code";
        }
        field(51039; "Reason Code Cont. Final Inv."; Code[10])
        {
            Caption = 'Reason Code Container Final Invoice';
            DataClassification = ToBeClassified;
            TableRelation = "Reason Code";
        }
        field(51040; "Report ID Item Label A4"; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'Report Selection Item Label A5';
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Report));
        }
        field(51041; "Report ID Item Label A6"; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'Report Selection Item Label A6';
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Report));
        }
        field(51042; "Appendix Cont. Prepay"; Code[5])
        {
            Caption = 'Appendix Invocie Numner Container Prepayment';
            DataClassification = ToBeClassified;
        }
        field(51043; "Appendix Cont. Final Inv."; Code[5])
        {
            Caption = 'Appendix Invocie Numner Container Final Payment';
            DataClassification = ToBeClassified;
        }
        field(51044; "G/L Lines in Cont. item Inv."; option)
        {
            DataClassification = ToBeClassified;
            Caption = 'G/L Account Lines in Container Final Payment';
            OptionMembers = skip,viaPurchaseReceiptLine,viaPurchaseInvoiceLine;
            OptionCaption = 'skip,via Purchase Receipt Line,via posted Purchase Invoice Line';
        }
        field(51045; "transfer date spec. order"; boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'transfer earlies shipment date on special order lines';
        }

        field(51046; "GTIN Number Series"; code[20])
        {
            Caption = 'GTIN Number Series';
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(51047; "Check GTIN Duplicate"; Option)
        {
            Caption = 'Check GTIN Duplicate';
            OptionMembers = ignore,notify,error;
            OptionCaption = 'ignore,notify user,show error';
            DataClassification = ToBeClassified;
        }
        field(51048; "prevent rel. order posting"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Prevent related order posting';
        }
        field(51049; "disable prepaym. amount check"; Boolean)
        {
            Caption = 'disable prepayment amount check';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                ConfirmAction_lLbl: label 'Please do not forget to disable this switch after successfull posting of the warehouse shipment.';
            begin
                if "disable prepaym. amount check" then begin
                    if not confirm(ConfirmAction_lLbl, false) then
                        exit;
                end;
            end;
        }

        field(51050; "Listprice Customer"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Customer;
            Caption = 'customer No. for listprice calculation';
        }
        field(51051; "Intercompany Customer"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Customer;
            Caption = 'customer No. for intercompany calculation';
        }
    }

    keys
    {
        key(PK; PK)
        {
            Clustered = true;
        }
    }

    var

    trigger OnInsert()
    var

    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

    /// <summary>
    /// Get an Icon that can be used to give a user a hint that there is an issue wich needs to be inspected.
    /// <see cref="#D5C7"/>
    /// </summary>
    /// <returns>String with the Icon</returns>
    procedure GetWarningIcon(): Text[1]
    begin
        if rec.FindFirst() then
            exit(Rec.IconWarning);
    end;

    /// <summary>
    /// Get an Icon that can be used to show the user that there is a severe error wich needs to be solved.
    /// <see cref="#D5C7"/>
    /// </summary>
    /// <returns>String with the Icon</returns>
    procedure GetOkIcon(): Text
    begin
        if rec.FindFirst() then
            exit(Rec.IconOk);
    end;

    /// <summary>
    /// Get an Icon that can be used to tell the user that everything is allright
    /// <see cref="#D5C7"/>
    /// </summary>
    /// <returns>String with the Icon</returns>
    procedure GetErrorIcon(): Text
    begin
        if rec.FindFirst() then
            exit(Rec.IconError);
    end;

    /// <summary>
    /// get the default style that is relevant to highlight a warning
    /// <see cref="#D5C7"/>
    /// </summary>
    /// <returns>Ambiguous as a fixed string</returns>
    local procedure WarningStyle(): Text
    begin
        exit('Ambiguous');
    end;

    /// <summary>
    /// get the default style that is relevant to highlight an error
    /// <see cref="#D5C7"/>
    /// </summary>
    /// <returns>Unfavorable as a fixed string</returns>
    local procedure ErrorStyle(): Text
    begin
        exit('Unfavorable');
    end;

    /// <summary>
    /// get the default style that is relevant to highlight that everything is ok
    /// <see cref="#D5C7"/>
    /// </summary>
    /// <returns>UnfavFavorablerable as a fixed string</returns>
    local procedure OkStyle(): Text
    begin
        exit('Favorable');
    end;

    /// <summary>
    /// Errechnet die StyleExpression für einIcon basierend auf der aktuellen Einrichtung
    /// <see cref="#D5C7"/>
    /// </summary>
    /// <param name="Icon">Icon als einstelliger UTF-8 String</param>
    /// <returns>Style für  die StyleExpression einer Page</returns>
    procedure GetIconStyle(Icon: Text[1]) styleExpr: Text[20]
    begin
        case Icon of
            GetErrorIcon():
                styleExpr := ErrorStyle();
            GetWarningIcon():
                styleExpr := WarningStyle();
            GetOkIcon():
                styleExpr := OkStyle();
        end;
    end;
    /// <summary>
    /// Erzeugt Icons sofern diese noch nicht hinterlegt wurden.
    /// <see cref="#D5C7"/>
    /// </summary>
    procedure InitIcons_gFnc()

    begin
        Rec.Reset();
        if not Rec.get then begin
            Rec.Init();
            Rec.Insert();
        end;
        if Rec.IconWarning = '' then
            Rec.IconWarning := '⚠';
        if Rec.IconError = '' then
            Rec.IconError := '✕';
        if Rec.IconOk = '' then
            Rec.IconOk := '✓';
        if (xRec.IconWarning = '') or (xRec.IconError = '') or (xRec.IconOk = '') then
            Rec.Modify();
    end;

    var
        p: page "trm Matrix Orders Matrix Sheet";
        c: Codeunit "trm Availability Check";
}