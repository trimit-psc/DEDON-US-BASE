/// <summary>
/// Codunit  wird ausgeführt wenn die Extension installiert wird
/// <see cref="#D5C7"/>
/// </summary>
codeunit 51002 "DDN Init App"
{
    Subtype = Install;

    trigger OnRun()
    begin

    end;

    var

    trigger OnInstallAppPerCompany()
    var
        myAppInfo: ModuleInfo;
        DataVersion: Version;
    begin
        NavApp.GetCurrentModuleInfo(myAppInfo);
        // DEDON einrichtung
        InitDEDONSetup();
        DataVersion := myAppInfo.DataVersion;
        //<major>.<minor>.<build>.<revision>
        if (DataVersion.Major = 22) and (DataVersion.Minor = 1) and (DataVersion.build = 0) and (DataVersion.Revision <= 5) then
            InititemIndentation();
        if (DataVersion.Major = 22) and (DataVersion.Minor = 1) and (DataVersion.build = 0) and (DataVersion.Revision <= 6) then
            enableBomForBI();
        if (DataVersion.Major = 22) and (DataVersion.Minor = 1) and (DataVersion.build = 1) and (DataVersion.Revision <= 28) then
            movePipedriveId();
        if (DataVersion.Major = 22) and (DataVersion.Minor = 1) and (DataVersion.build = 1) and (DataVersion.Revision <= 41) then
            inheritDesignerFromMasterToItem();
        if (DataVersion.Major = 22) and (DataVersion.Minor = 1) and (DataVersion.build = 1) and (DataVersion.Revision <= 44) then
            moveSachbearbeiter();
    end;

    local procedure InitDEDONSetup()
    var
        DDNSetup_lRec: Record "DDN Setup";
    begin
        // DEDON einrichtung
        if DDNSetup_lRec.insert() then;
        DDNSetup_lRec.get();
        DDNSetup_lRec.InitIcons_gFnc();
    end;

    local procedure InititemIndentation()
    var
        Item_lRec: Record Item;
    begin
        Item_lRec.SetRange("trm Item Type", Item_lRec."trm Item Type"::"Master Item");
        Item_lRec.ModifyAll("DDN Indentation", 0);
        Item_lRec.SetFilter("trm Item Type", '<>%1', Item_lRec."trm Item Type"::"Master Item");
        Item_lRec.ModifyAll("DDN Indentation", 1);
    end;

    local procedure enableBomForBI()
    var
        DDNSetup_lRec: Record "DDN Setup";
        master_lRec: Record "trm Master";
    begin
        DDNSetup_lRec.get();
        DDNSetup_lRec."enable Bom Creation for BI" := true;
        DDNSetup_lRec.modify();

        // Artikel bei denen die Stückliste entfaltet werden soll werden i.d.R. auch die Artikelnummer des Möbels verteilen
        master_lRec.SetRange("DDN Auto Explode BOM");
        master_lRec.ModifyAll("DDN enable Bom Creation for BI", true, false);
    end;

    /// <summary>
    /// Sehr wichtiger Schalte rum Standard-Produktion einzusezten
    /// </summary>
    /// <param name="value_par"></param>
    /*
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"trm basic functions", 'Pf_SetStandardProductionInUse', '', false, false)]
    local procedure trmBasicFunctionSetStandardProductionInUse(var value_par: Boolean)
    begin
        value_par := true;
    end;
    */

    local procedure movePipedriveId()
    var
        contact: Record Contact;
    begin
        contact.setfilter("COR-DDN Pipedrive Org. ID 2", '>0');
        if contact.findset then begin
            contact."COR-DDN Pipedrive Org. ID 2" := contact."COR-DDN Pipedrive Org. ID";
            contact.modify(false);
        end;
    end;

    local procedure inheritDesignerFromMasterToItem()
    var
        master_lRec: Record "trm Master";
        item_lRec: Record Item;
    begin
        master_lRec.setfilter("DDN Designer Code", '<>''''');
        master_lRec.SetLoadFields("DDN Designer Code");
        item_lRec.SetLoadFields("DDN Designer Code");
        if master_lRec.findset then
            repeat
                item_lRec.SetRange("trm Master No.", master_lRec."No.");
                item_lRec.SetFilter("DDN Designer Code", '<>%1', master_lRec."DDN Designer Code");
                item_lRec.ModifyAll("DDN Designer Code", master_lRec."DDN Designer Code", false);
            until master_lRec.Next() = 0;
    end;

    local procedure moveSachbearbeiter()
    var
        Customer_lRec: Record Customer;
        Contact_lRec: Record Contact;
        ContBusRel_lRec: Record "Contact Business Relation";
    begin
        Customer_lRec.setfilter("COR-DDN Respons. Person Code", '<>''''');
        Customer_lRec.SetLoadFields("COR-DDN Respons. Person Code");
        if Customer_lRec.FindSet() then
            repeat
                Customer_lRec."COR-DDN Respons. Person Code 2" := Customer_lRec."COR-DDN Respons. Person Code";
                Customer_lRec.modify;
                ContBusRel_lRec.SetRange("Link to Table", ContBusRel_lRec."Link to Table"::Customer);
                ContBusRel_lRec.setrange("No.", Customer_lRec."No.");
                if ContBusRel_lRec.findset then
                    repeat
                        if Contact_lRec.get(ContBusRel_lRec."Contact No.") then begin
                            Contact_lRec."COR-DDN Respons. Person Code 2" := Customer_lRec."COR-DDN Respons. Person Code 2";
                            Contact_lRec.modify();
                        end
                    until ContBusRel_lRec.Next() = 0;
            until Customer_lRec.Next() = 0;
    end;
}