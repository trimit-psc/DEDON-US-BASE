/// <summary>
/// 
/// <see cref="#L2DS"/>
/// </summary>
pageextension 51016 "DDN Temp Vardim Variants" extends "trm Temp VarDim Variants"
{
    actions
    {
        addafter(ShowMarkedAll)
        {
            group(ColorSelectionGroups)
            {
                Caption = 'Color Selection Groups';
                Enabled = ColorSelectiongroupsEnabled;

                action("ColorSelectionGroup1")
                {
                    ApplicationArea = All;
                    Caption = 'Color Selection Group 1';
                    Image = FilterLines;
                    visible = ColorSelectiongroup1Visible;
                    enabled = ColorSelectiongroup1Visible;

                    trigger OnAction()
                    begin
                        applyColorSelectionGroup(1);
                    end;
                }
                action("ColorSelectionGroup2")
                {
                    ApplicationArea = All;
                    Caption = ' Selection Group 2';
                    Image = FilterLines;
                    visible = ColorSelectiongroup2Visible;
                    enabled = ColorSelectiongroup2Visible;

                    trigger OnAction()
                    begin
                        applyColorSelectionGroup(2);
                    end;
                }
                action("ColorSelectionGroup3")
                {
                    ApplicationArea = All;
                    Caption = ' Selection Group 3';
                    Image = FilterLines;
                    visible = ColorSelectiongroup3Visible;
                    enabled = ColorSelectiongroup3Visible;

                    trigger OnAction()
                    begin
                        applyColorSelectionGroup(3);
                    end;
                }
                action("ColorSelectionGroup4")
                {
                    ApplicationArea = All;
                    Caption = ' Selection Group 4';
                    Image = FilterLines;
                    visible = ColorSelectiongroup4Visible;
                    enabled = ColorSelectiongroup4Visible;

                    trigger OnAction()
                    begin
                        applyColorSelectionGroup(4);
                    end;
                }
                action("ColorSelectionGroup5")
                {
                    ApplicationArea = All;
                    Caption = ' Selection Group 5';
                    Image = FilterLines;
                    visible = ColorSelectiongroup5Visible;
                    enabled = ColorSelectiongroup5Visible;

                    trigger OnAction()
                    begin
                        applyColorSelectionGroup(5);
                    end;
                }
                action("ColorSelectionGroup6")
                {
                    ApplicationArea = All;
                    Caption = ' Selection Group 6';
                    Image = FilterLines;
                    visible = ColorSelectiongroup6Visible;
                    enabled = ColorSelectiongroup6Visible;

                    trigger OnAction()
                    begin
                        applyColorSelectionGroup(6);
                    end;
                }
                action("ColorSelectionGroup7")
                {
                    ApplicationArea = All;
                    Caption = ' Selection Group 7';
                    Image = FilterLines;
                    visible = ColorSelectiongroup7Visible;
                    enabled = ColorSelectiongroup7Visible;

                    trigger OnAction()
                    begin
                        applyColorSelectionGroup(7);
                    end;
                }
                action("ColorSelectionGroup8")
                {
                    ApplicationArea = All;
                    Caption = ' Selection Group 8';
                    Image = FilterLines;
                    visible = ColorSelectiongroup8Visible;
                    enabled = ColorSelectiongroup8Visible;

                    trigger OnAction()
                    begin
                        applyColorSelectionGroup(8);
                    end;
                }
                action("ColorSelectionGroup9")
                {
                    ApplicationArea = All;
                    Caption = ' Selection Group 9';
                    Image = FilterLines;
                    visible = ColorSelectiongroup9Visible;
                    enabled = ColorSelectiongroup9Visible;

                    trigger OnAction()
                    begin
                        applyColorSelectionGroup(9);
                    end;
                }
                action("ColorSelectionGroup10")
                {
                    ApplicationArea = All;
                    Caption = ' Selection Group 10';
                    Image = FilterLines;
                    visible = ColorSelectiongroup10Visible;
                    enabled = ColorSelectiongroup10Visible;

                    trigger OnAction()
                    begin
                        applyColorSelectionGroup(10);
                    end;
                }
            }
        }
    }

    var
        ColorSelectiongroupsEnabled: Boolean;
        ColorSelectiongroup1Visible, ColorSelectiongroup2Visible, ColorSelectiongroup3Visible, ColorSelectiongroup4Visible, ColorSelectiongroup5Visible : Boolean;
        ColorSelectiongroup6Visible, ColorSelectiongroup7Visible, ColorSelectiongroup8Visible, ColorSelectiongroup9Visible, ColorSelectiongroup10Visible : Boolean;

    trigger OnOpenPage()
    var
        ddnSetup_lRec: Record "DDN Setup";
        searchTableHeader_lRec: Record "trm Search Table Header";
    begin
        ddnSetup_lRec.get;
        if ddnSetup_lRec."Search Table Code ColorGroup" = '' then
            exit;
        if not searchTableHeader_lRec.get(ddnSetup_lRec."Search Table Code ColorGroup") then
            exit;
        //message('Pag51016 VarDim Variant=%1', Rec.GetFilter("VarDim Type (Internal)"));
        if searchTableHeader_lRec."Column 1 (Code) VarDim Type" <> Rec.GetFilter("VarDim Type (Internal)") then
            exit;
        ColorSelectiongroupsEnabled := true;
        if searchTableHeader_lRec."Result 1 (Code) Name" <> '' then
            ColorSelectiongroup1Visible := true;
        if searchTableHeader_lRec."Result 2 (Code) Name" <> '' then
            ColorSelectiongroup2Visible := true;
        if searchTableHeader_lRec."Result 3 (Code) Name" <> '' then
            ColorSelectiongroup3Visible := true;
        if searchTableHeader_lRec."Result 4 (Code) Name" <> '' then
            ColorSelectiongroup4Visible := true;
        if searchTableHeader_lRec."Result 5 (Code) Name" <> '' then
            ColorSelectiongroup5Visible := true;
        if searchTableHeader_lRec."Result 6 (Code) Name" <> '' then
            ColorSelectiongroup6Visible := true;
        if searchTableHeader_lRec."Result 7 (Code) Name" <> '' then
            ColorSelectiongroup7Visible := true;
        if searchTableHeader_lRec."Result 8 (Code) Name" <> '' then
            ColorSelectiongroup8Visible := true;
        if searchTableHeader_lRec."Result 9 (Code) Name" <> '' then
            ColorSelectiongroup9Visible := true;
        if searchTableHeader_lRec."Result 10 (Code) Name" <> '' then
            ColorSelectiongroup10Visible := true;
    end;

    local procedure applyColorSelectionGroup(ColorSelectionGroup: Integer)
    var
        ddnSetup_lRec: Record "DDN Setup";
        searchTableLine_lRec: Record "trm Search Table Line";
        colorIsValid_lBool: Boolean;
        t: record "trm Temp VarDim Variant";
        ConfirmDiffentNumberOfLinesDlg: Label 'The number of colors in this list varies from the number of colors in the selection group. Should the checkmary be removed for currently selected colors for security reasons?';
    //Die Anzahl der Farben in dieser Übersicht unterscheidet sich von der Anzahl der Farben in den Auswahlgruppen. Soll zur Sicherheit die Markierung von allen aktuell gewählten Farben entfernt werden?
    begin
        ddnSetup_lRec.get;
        if ddnSetup_lRec."Search Table Code ColorGroup" = '' then
            exit;
        searchTableLine_lRec.setrange("Table ID", ddnSetup_lRec."Search Table Code ColorGroup");
        //searchTableLine_lRec.setrange("Column 1 (Code)", Rec.GetFilter("VarDim Type (Internal)"));

        // alle Zeilen nicht markieren, die nicht in der Suchtabelle stehen
        if searchTableLine_lRec.findset then begin

            if searchTableLine_lRec.Count() <> Rec.Count() then begin
                if confirm(ConfirmDiffentNumberOfLinesDlg) then begin
                    removeMarks();
                end;
            end;
            repeat
                case ColorSelectionGroup of
                    1:
                        colorIsValid_lBool := ColorIsValid(searchTableLine_lRec."Result 1 (Code)");
                    2:
                        colorIsValid_lBool := ColorIsValid(searchTableLine_lRec."Result 2 (Code)");
                    3:
                        colorIsValid_lBool := ColorIsValid(searchTableLine_lRec."Result 3 (Code)");
                    4:
                        colorIsValid_lBool := ColorIsValid(searchTableLine_lRec."Result 4 (Code)");
                    5:
                        colorIsValid_lBool := ColorIsValid(searchTableLine_lRec."Result 5 (Code)");
                    6:
                        colorIsValid_lBool := ColorIsValid(searchTableLine_lRec."Result 6 (Code)");
                    7:
                        colorIsValid_lBool := ColorIsValid(searchTableLine_lRec."Result 7 (Code)");
                    8:
                        colorIsValid_lBool := ColorIsValid(searchTableLine_lRec."Result 8 (Code)");
                    9:
                        colorIsValid_lBool := ColorIsValid(searchTableLine_lRec."Result 9 (Code)");
                    10:
                        colorIsValid_lBool := ColorIsValid(searchTableLine_lRec."Result 10 (Code)");

                    else
                        exit;
                end;
                // "VarDim Type (Internal)", "VarDim Variant", Value
                if rec.get(Rec.GetFilter("VarDim Type (Internal)"), Rec.GetFilter("VarDim Variant"), searchTableLine_lRec."Column 1 (Code)") then begin
                    if rec.Mark <> colorIsValid_lBool then begin
                        rec.validate(Mark, colorIsValid_lBool);
                        Rec.modify(true);
                    end;
                end
            until searchTableLine_lRec.Next() = 0;
        end;
    end;

    local procedure ColorIsValid(ResultCode: Code[10]): Boolean
    var
    begin
        exit(not (ResultCode in ['', '0']));
    end;

    local procedure removeMarks()
    var
        xTempVarDimVariant_loc: Record "trm Temp VarDim Variant";
    begin
        Rec.SetRange(Mark);
        xTempVarDimVariant_loc := Rec;
        if Rec.FindSet then begin
            repeat
                xRec.Mark := Rec.Mark;
                Rec.Validate(Mark, false);
                Rec.Modify;
            until Rec.Next = 0;
            Rec := xTempVarDimVariant_loc;
            if (xTempVarDimVariant_loc.Value <> '') then
                Rec.Find;
        end;
    end;
}
