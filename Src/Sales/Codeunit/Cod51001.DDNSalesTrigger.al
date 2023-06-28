codeunit 51001 "DDN Sales Trigger"
{

    /// <summary>
    /// Damit Designer gem. Trimit-Provisionierung vergütet werden, kopiert <c>SalesLineOnValidateNoOnAfterUpdateUnitPrice()</c> den Verkäufercode auf
    /// dem Master in die Verkaufszeile.
    /// Anforderung [B-066]
    /// </summary>
    /// <remarks>Greift nach der Preisberechnung in der SalesLine</remarks>
    /// <see cref="#W3MP"/>
    /// <param name="SalesLine">Verkaufszeile</param>
    /// <param name="xSalesLine">ursprünglcihe Verkaufszeile</param>
    /// <param name="TempSalesLine"></param>
    [EventSubscriber(ObjectType::Table, 37, 'OnValidateNoOnAfterUpdateUnitPrice', '', false, false)]
    local procedure SalesLineOnValidateNoOnAfterUpdateUnitPriceSubScr(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; var TempSalesLine: Record "Sales Line" temporary)

    var
        Master_lRec: Record "trm Master";
        Item_lrec: Record Item;
        designer_lCod: Code[20];
    begin
        // Designer aus dem Master in die VK-Zeile übertragen
        clear(SalesLine."trm Salesperson 3");
        if SalesLine.Type = SalesLine.Type::Item then begin
            Master_lRec.SetLoadFields("DDN Designer Code", "DDN enable Bom Creation for BI");
            item_lrec.setLoadFields("DDN Designer Code", "trm Master No.");
            //suche zuerst über den Artikel
            if Item_lrec.get(SalesLine."No.") then begin
                if item_lrec."DDN Designer Code" <> '' then begin
                    designer_lCod := Item_lrec."DDN Designer Code";
                end else begin
                    // falls im Artikel kein Designer hinterlegt ist nehme diesen aus dem Master
                    if Item_lrec."trm Master No." <> '' then begin
                        if Master_lRec.Get(item_lrec."trm Master No.") then begin
                            designer_lCod := Master_lRec."DDN Designer Code";
                        end;
                    end;
                end;
                if designer_lCod <> SalesLine."trm Salesperson 3" then
                    SalesLine.validate("trm Salesperson 3", designer_lCod);

                if SalesLine."trm Master No." <> '' then begin
                    if Master_lRec.Get(SalesLine."trm Master No.") then begin
                        // bei Mastern / Artikeln ohne Stückliste, die aber ein Möbel sind ohne Stückliste soll diese Artikelnummer übernommen werden
                        Master_lRec.CalcFields(BOM);
                        if (not Master_lRec.BOM) and (Master_lRec."DDN enable Bom Creation for BI") then begin
                            // Achtung: Falls der Artikel Teil eines Sets ist wird die Nummer ggf. nach Auflösung der Stückliste überschrieben
                            // SalesLine.Description := strsubstno('DEBUG: %1', SalesLine."DDN Set Item No.");
                            SalesLine."DDN Set Item No." := SalesLine."No.";
                            SalesLine."DDN Set Master No." := SalesLine."trm Master No.";
                        end;
                    end;
                end;
            end;
        end;


        //InitIntakeDate(SalesLine);

        // wenn sich die Artikelnummer ändert soll trotzdem der Bezug zum Set-Artikel bestehen bleiben
        // das ist insbesondere dann der Fall wenn die Artikelnummer auf Grund eines Wechsels zu einem
        // anderen Land oder einer anderen Version kommt
        if (xSalesLine."Attached to Line No." > 0) and (xSalesLine."DDN Set Master No." <> '') then begin
            transfertAttachedToLineAndSetInfo(SalesLine, xSalesLine);
        end;

    end;



    /// <summary>
    /// Mit Auflösung der Stückliste wird die Masternummer an die Komponenten vererbt
    /// Event wird laut Martine Schleef zum 10.08.2022 durch Trimit Solutions A/S veröffentlicht.
    /// Siehe TrimitKB-Artikel 161536
    /// <see cref="#DM4X"/>
    /// </summary>
    /// <param name="toSalesLine_par">VK-Zeile mit Stücklistenartikel</param>
    /// <param name="fromsalesLine_par">VK-Zeile mit Komponenten</param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"trm Generate BOM Structure", 'Pf_OnAfterInsertSalesLineAtExplodeBOMtoFrom', '', false, false)]
    local procedure Pf_OnAfterInsertSalesLineAtExplodeBOMToFromSubScr(var toSalesLine_par: Record "Sales Line"; fromsalesLine_par: Record "Sales Line")
    var
        SalesLine2: Record "Sales Line";
    begin
        // mehrfaches Entfalten der Stückliste verhindern um Performance zu optimieren
        if fromsalesLine_par."DDN Set Item No." = '' then begin
            fromsalesLine_par.trmSet_SkipMessages(true);
        end;
        transfertAttachedToLineAndSetInfo(toSalesLine_par, fromsalesLine_par);
    end;


    /// <summary>
    /// Aufslösung der Stückliste mit Eingabe der Menge auslösen.
    /// BC gibt von sich aus anschließend einen Confirmation-Dialog zur Zustimmung aus. Daher erfolgt hier keine weitere Abfrage.
    /// <see cref="#DM4X"/> 
    /// <see cref="3N8B"/>
    /// </summary>
    /// <param name="Rec"></param>
    /// <param name="xRec"></param>
    [EventSubscriber(ObjectType::Table, 37, 'OnAfterValidateEvent', 'Quantity', false, false)]
    local procedure SalesLineOnAfterValidateQuantitySubScr(var Rec: Record "Sales Line"; var xRec: Record "Sales Line")
    var
        SalesLineComponent_lRec: Record "Sales Line";
    begin
        if not (rec."Document Type" in [rec."Document Type"::Quote, rec."Document Type"::Order]) then
            exit;
        ExpandBomInSalesLine(Rec, false);
    end;

    /// <summary>
    /// <see cref="#DM4X"/> 
    /// </summary>
    procedure ExpandBomInSalesLine(var Rec: Record "Sales Line"; deleteDescriptionLine: Boolean);
    var
        Master_lRec: Record "trm Master";
        SalesLine2_lRec: Record "Sales Line";
        SalesLine3_lRec: Record "Sales Line";
    begin
        if Rec.IsTemporary then
            exit;
        if Rec.Quantity = 0 then
            exit;
        if Rec."trm Master No." = '' then
            exit;
        if not Master_lRec.get(Rec."trm Master No.") then
            exit;
        Master_lRec.CalcFields(BOM);
        if not Master_lRec.BOM then
            exit;
        if not Master_lRec."DDN Auto Explode BOM" then
            exit;

        // Via Subscriber überschriebt Trimit die Logik von BC
        CODEUNIT.Run(CODEUNIT::"Sales-Explode BOM", Rec);
    end;


    /// <summary>
    /// <see cref="#DM4X"/>
    /// </summary>
    /// <param name="salesLine_par">VAR Record "Sales Line".</param>
    /// <param name="dialogIsHandled_par">VAR Boolean.</param>
    [EventSubscriber(ObjectType::Codeunit, CodeUnit::"trm Codeunit Event", 'OnBeforeShowBomExplodeConfirmationDialog', '', false, false)]
    local procedure trmCodeunitEventOnBeforeShowBomExplodeConfirmationDialogSubScr(var salesLine_par: Record "Sales Line"; var dialogIsHandled_par: Boolean)
    var

        Master_lRec: Record "trm Master";
    begin
        // TODO Ist am 24.02.2023 dekativiert worden weil ggf. Nebenwirkungen möglich. Das könnte in höheren Releases von Trimit krachen.
        // clear(salesLine_par."trm Type");

        if salesLine_par."trm Master No." = '' then
            exit;
        if Master_lRec.Get(salesLine_par."trm Master No.") then begin
            dialogIsHandled_par := Master_lRec."DDN Auto Explode BOM";
            // 19.01.2023. Stückliste Belmonde ließ sich nicht entfalten
            // Aber auch das Löschen der trm No führte zu einem Folgefehler
            //salesLine_par."trm No." := '';
            // Aufruf um die Stückliste erstmalig zu generieren.
            GenerateTempBOMStructure(salesLine_par);
        end;
    end;

    /// <summary>
    /// Die BOM-Struktur wird temporär aufgelöst und der auslösenden verkaufszeile wird
    /// Artikelnummer und Masternummer des Möbels mitgeteilt.
    /// Die Funktion steht in engem Zusammenspiel mit explodeBom auf der VK-Zeile
    /// <see cref="#DM4X"/>
    /// </summary>
    /// <param name="Rec">VAR Record "Sales Header".</param>

    procedure GenerateTempBOMStructure(var SourceSalesLine: Record "Sales Line")
    var
        item_lRec: Record Item;
        varDimProdPurchLine_lRec: Record "trm VarDim Prod./Purchase Line";
        prodLineBufferPage_lPag: Page "trm Production Line Buffer";
        TempProdLineBuffer_lRec: Record "trm Production Line Buffer" temporary;
        callGenerateBOMStructure_lRec: Record "trm Call Gen BOM Structure";
        genBOMStructure_lCodeUnit: Codeunit "trm Generate BOM Structure";
        ddnSetup_lRec: Record "DDN Setup";
        master_lRec: Record "trm Master";
        IsInitiatedBConfigItem_lBool: Boolean;
    begin
        // Pf_OnAfterInsertSalesLineAtExplodeBOMToFromSubScr verbindet die Verkaufszeilen
        // hierdurch wird eine mögliche Rekursion beim Auflösen von Stücklisten verhindert
        if SourceSalesLine."Attached to Line No." <> 0 then
            exit;
        if not item_lRec.Get(SourceSalesLine."No.") then
            exit;
        // ggf. global deaktiviert.
        ddnSetup_lRec.get();
        if not ddnSetup_lRec."enable Bom Creation for BI" then
            exit;
        if SourceSalesLine."trm Master No." <> '' then begin
            if master_lRec.get(SourceSalesLine."trm Master No.") then begin
                if not master_lRec."DDN enable Bom Creation for BI" then
                    exit;
            end
        end;


        // #9LUF Menge Set in Belegzeile und Posten
        SourceSalesLine."COR-DDN Set Quantity" := SourceSalesLine.Quantity;

        callGenerateBOMStructure_lRec."Use Temporary Buffer" := true;
        callGenerateBOMStructure_lRec.InitOrderTypeStartLevel := callGenerateBOMStructure_lRec.InitOrderTypeStartLevel::"Sales Line";
        callGenerateBOMStructure_lRec.InitDocumentTypeStartLevel := SourceSalesLine."Document Type";
        callGenerateBOMStructure_lRec.InitOrderNoStartLevel := SourceSalesLine."Document No.";
        callGenerateBOMStructure_lRec.InitOrderLineNoStartLevel := SourceSalesLine."Line No.";
        callGenerateBOMStructure_lRec."Use Temporary Buffer" := true;

        callGenerateBOMStructure_lRec."Assign Type" := 1155;

        varDimProdPurchLine_lRec.LockTable;
        TempProdLineBuffer_lRec.DeleteAll;

        varDimProdPurchLine_lRec.Reset;
        varDimProdPurchLine_lRec.SetRange("Order Type", varDimProdPurchLine_lRec."order type"::"MRP Buffer");
        varDimProdPurchLine_lRec.SetRange("User ID", UserId);
        varDimProdPurchLine_lRec.SetRange("Document Type", callGenerateBOMStructure_lRec."Assign Type");
        if varDimProdPurchLine_lRec.FindFirst then
            varDimProdPurchLine_lRec.DeleteAll;

        callGenerateBOMStructure_lRec.BreakDownItemNo := item_lRec."No.";
        callGenerateBOMStructure_lRec.CalledConcerning := callGenerateBOMStructure_lRec.Calledconcerning::"Generate Temp. Buffer";
        callGenerateBOMStructure_lRec.LineNumbering := true;
        callGenerateBOMStructure_lRec."Break Down From LLC Level" := 1;
        if (callGenerateBOMStructure_lRec."Order Volume" = 0) then
            callGenerateBOMStructure_lRec."Order Volume" := 1;
        if (callGenerateBOMStructure_lRec."Break Down to Management Level" = 0) then
            callGenerateBOMStructure_lRec."Break Down to Management Level" := 999999999;

        genBOMStructure_lCodeUnit.Set_SkipMessages(true);
        genBOMStructure_lCodeUnit.TransferCalcBufferTemp(TempProdLineBuffer_lRec);
        genBOMStructure_lCodeUnit.OnRunCode(callGenerateBOMStructure_lRec);

        // In der ersten Zeile ermittlen, ob es ein Config-Artikel ist
        TempProdLineBuffer_lRec.setrange("Low-Level Code", 1);
        if TempProdLineBuffer_lRec.findfirst then begin
            // Beim Config-Artikel ist die Masternummer in der VK-Zeile gleich der Artikelnummer
            // Bei den Möbeln und den Sets hingegen gibt es immer konkrete Artikelnummern.
            IsInitiatedBConfigItem_lBool := SourceSalesLine."trm Master No." = TempProdLineBuffer_lRec."Where-Used Item No.";
        end;

        // Das Möbel identifizieren
        TempProdLineBuffer_lRec.setrange("Low-Level Code", 2);
        TempProdLineBuffer_lRec.SetRange("Is Leaf", false);
        TempProdLineBuffer_lRec.SetRange(Type, TempProdLineBuffer_lRec.Type::Item);
        // dreistufige Artikelstuktur liegt vor
        // Normalfall: Dreistufige Stückliste ausgelöst über Config
        if TempProdLineBuffer_lRec.findfirst then begin
            SourceSalesLine."DDN Set Item No." := TempProdLineBuffer_lRec."No.";
            SourceSalesLine."DDN Set Master No." := TempProdLineBuffer_lRec."Master No.";
        end else begin
            // zweistufige struktur liegt vor
            // Die Zweistufigkeiten wird in der Regel dann vorliegen wenn das Möbel anstelle des Configs in die Stückliste überführt wird.
            // Die Set-Artikelnummer wird dann vom Möbel gezogen. Dieses befindet sich auf Level 1
            // es kann aber auch eine Ausnahmesituation geben: Hat das Möbel selbst keine Stückliste dann ist die Stückliste zweistufig. Das Möbel selbst ist dann jedoch kein Config-Artikel
            // Erkennbar ist ein Config-Artikel in der Stückliste daran, dass seine Artikelnummer gleich der Masternummer lautet


            TempProdLineBuffer_lRec.SetCurrentKey("Buffer Type", "User ID", "Line No.");
            // hier: 2-stufig und ausgelöst über Config
            // Der Config-Artikel enthält ein Möbel, das seinerseits keine Komponenten hat
            if IsInitiatedBConfigItem_lBool then begin
                TempProdLineBuffer_lRec.setrange("Low-Level Code", 2);
                TempProdLineBuffer_lRec.SetRange("Is Leaf", true);
                // wir gehen daovn aus, dass das Möbel an erster Stelle steht
                if TempProdLineBuffer_lRec.findfirst then begin
                    SourceSalesLine."DDN Set Item No." := TempProdLineBuffer_lRec."No.";
                    SourceSalesLine."DDN Set Master No." := TempProdLineBuffer_lRec."Master No.";
                end
            end else begin
                // hier: 2-stufig und ausgelöst über das Möbel selbst
                // hier besteht das Dilemma, dass Kissen und Möbel in der Stückliste generell gleichwertig sind
                // Workaround: Annahme, dass die erste Komponente das Möbel identifiziert weil Artikelstamm entsprechend aufgebaut wurde
                SourceSalesLine."DDN Set Item No." := SourceSalesLine."No.";
                SourceSalesLine."DDN Set Master No." := SourceSalesLine."trm Master No.";
            end;
        end;
        // Jetzt kann es Sonderfälle geben bei denen die gesamte, oben entwickelte Logik nicht greift weil der ermittlente Master
        // kein Möbel ist. Beispiel AVS MBARQUE 3  Seater incl. Ausstattung mit Kissensets, die aufgelöst werden.
        if not ItemIsFurniture(SourceSalesLine."DDN Set Item No.") then begin
            clear(SourceSalesLine."DDN Set Item No.");
            clear(SourceSalesLine."DDN Set Master No.");

            TempProdLineBuffer_lRec.reset;
            TempProdLineBuffer_lRec.setrange("Low-Level Code", 2);
            // im ersten Schritt versuchen wir es über ein Möbel, das Komponenten enthalten kann
            // also "is Leaf" = false
            TempProdLineBuffer_lRec.SetRange("Is Leaf", false);
            TempProdLineBuffer_lRec.SetRange(Type, TempProdLineBuffer_lRec.Type::Item);
            if TempProdLineBuffer_lRec.FindSet() then
                repeat
                    if ItemIsFurniture(TempProdLineBuffer_lRec."No.") then begin
                        SourceSalesLine."DDN Set Item No." := TempProdLineBuffer_lRec."No.";
                        SourceSalesLine."DDN Set Master No." := TempProdLineBuffer_lRec."Master No.";
                    end;
                until (TempProdLineBuffer_lRec.next() = 0) or (SourceSalesLine."DDN Set Item No." <> '');

            // im zweiten Versuch versuchen wir es über ein Möbel, das keine Komponenten enthält
            if SourceSalesLine."DDN Set Item No." = '' then begin
                TempProdLineBuffer_lRec.SetRange("Is Leaf", true);
                if TempProdLineBuffer_lRec.FindSet() then
                    repeat
                        if ItemIsFurniture(TempProdLineBuffer_lRec."No.") then begin
                            SourceSalesLine."DDN Set Item No." := TempProdLineBuffer_lRec."No.";
                            SourceSalesLine."DDN Set Master No." := TempProdLineBuffer_lRec."Master No.";
                        end;
                    until (TempProdLineBuffer_lRec.next() = 0) or (SourceSalesLine."DDN Set Item No." <> '');
            end
        end;
        //error('CU51001 Abbruch wegen Testphase. Ermittelt wurde %1', SourceSalesLine."DDN Set Item No.");
    end;

    local procedure ItemIsFurniture(itemNo_lCode: Code[20]) ret: Boolean
    var
        item_lRec: Record Item;
    begin
        item_lRec.SetLoadFields("trm Item Statistics Group", "trm Item Statistics Group 5");
        item_lRec.get(itemNo_lCode);
        if (item_lRec."trm Item Statistics Group" = 100) and (item_lRec."trm Item Statistics Group 5" = 100) then
            exit(true);
    end;

    /// <summary>
    /// Beleget u.a. das Intake-Date vor. Der Trigger greift auch beim Vorgang "Angebot in Auftrag wandeln". Das ergaben Tests.
    /// <see cref="#NFSX"/>
    /// </summary>
    /// <param name="Rec">VAR Record "Sales Header".</param>
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SalesHeaderOnBeforeInsertEventSubScr(var Rec: Record "Sales Header")
    begin
        InitIntakeDate(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SalesLineOnBeforeInsertEventSubScr(var Rec: Record "Sales Line")
    begin
        // Workaround wegen "Lieferzeilen holen". In dem Fall darf das Lieferdatum, dass durch
        // SalesShipmentLine_OnBeforeInsertInvLineFromShptLine_lFnc gesetzt wird nicht überschrieben werden.
        if rec.IsTemporary then
            exit;
        if (Rec."Document Type" <> Rec."Document Type"::Order) and (Rec."DDN Order Intake Date" <> 0D) then
            exit;
        InitIntakeDate(Rec);
    end;
    /// <summary>
    /// procedureCopyDocumentMgtOnAfterCopyFieldsFromOldSalesHeader.
    /// <see cref="#NFSX"/>
    /// </summary>
    /// <param name="ToSalesHeader">VAR Record "Sales Header".</param>
    /// <param name="OldSalesHeader">Record "Sales Header".</param>
    /// <param name="MoveNegLines">Boolean.</param>
    /// <param name="IncludeHeader">Boolean.</param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnAfterCopyFieldsFromOldSalesHeader', '', false, false)]
    local procedure procedureCopyDocumentMgtOnAfterCopyFieldsFromOldSalesHeaderSubScr(var ToSalesHeader: Record "Sales Header"; OldSalesHeader: Record "Sales Header"; MoveNegLines: Boolean; IncludeHeader: Boolean)
    begin
        InitIntakeDate(ToSalesHeader);
    end;

    /// <summary>
    /// Nach dem Kopieren aus dem Archiv muss das Intakte Date auf das Tagesdatum gesetzt werden
    /// <see cref="#NFSX"/>
    /// </summary>
    /// <param name="ToSalesHeader">VAR Record "Sales Header".</param>
    /// <param name="OldSalesHeader">Record "Sales Header".</param>
    /// <param name="FromSalesHeaderArchive">Record "Sales Header Archive".</param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnAfterCopySalesHeaderArchive', '', false, false)]
    local procedure OnAfterCopySalesHeaderArchive(var ToSalesHeader: Record "Sales Header"; OldSalesHeader: Record "Sales Header"; FromSalesHeaderArchive: Record "Sales Header Archive")
    begin
        InitIntakeDate(ToSalesHeader);
    end;

    /// <summary>
    /// <see cref="#NFSX"/>
    /// </summary>
    /// <param name="SalesHeader_viRec">VAR Record "Sales Header".</param>
    local procedure InitIntakeDate(var SalesHeader_viRec: Record "Sales Header")
    begin
        SalesHeader_viRec."DDN Order Intake Date" := WorkDate();
    end;

    /// <summary>
    /// <see cref="#NFSX"/>
    /// </summary>
    /// <param name="SalesLine_viRec"></param>
    /// <returns></returns>
    local procedure InitIntakeDate(var SalesLine_viRec: Record "Sales Line")
    SalesHeader_lRec: Record "Sales Header";
    begin
        SalesHeader_lRec.get(SalesLine_viRec."Document Type", SalesLine_viRec."Document No.");
        SalesLine_viRec."DDN Order Intake Date" := SalesHeader_lRec."DDN Order Intake Date";
    end;
    /// <summary>
    /// Ermittelt die Überschrift für dei Artikelfactbox
    /// <see cref="#WF2E"/>
    /// </summary>
    /// <param name="CaptionArea">Text.</param>
    /// <param name="CaptionExpr">Text.</param>
    /// <param name="Language">Integer.</param>
    /// <param name="Caption">VAR Text.</param>
    /// <param name="Resolved">VAR Boolean.</param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Caption Class", 'OnResolveCaptionClass', '', true, true)]
    local procedure CaptionClassOnResolveCaptionClass(CaptionArea: Text; CaptionExpr: Text; Language: Integer; var Caption: Text; var Resolved: Boolean)
    var
        item_lRec: Record item;
        fieldRef_lFldRef: FieldRef;
        recRef_lRecRef: RecordRef;
        fieldNo_lInt: Integer;
    begin
        case CaptionArea of
            'DDN27':
                begin
                    evaluate(fieldNo_lInt, CaptionExpr);
                    recRef_lRecRef.Open(27);
                    fieldRef_lFldRef := recRef_lRecRef.field(fieldNo_lInt);
                    Caption := fieldRef_lFldRef.Caption;
                    Resolved := true;
                end;
        end;
    end;


    /// <summary>
    /// <see cref="#NFSX"/>
    /// </summary>
    [EventSubscriber(ObjectType::Table, Database::"Sales Shipment Line", 'OnBeforeInsertInvLineFromShptLine', '', false, false)]
    local procedure SalesShipmentLine_OnBeforeInsertInvLineFromShptLine_lFnc(var SalesShptLine: Record "Sales Shipment Line"; var SalesLine: Record "Sales Line"; SalesOrderLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
        SalesLine."DDN Order Intake Date" := SalesShptLine."DDN Order Intake Date";
    end;

    /// <summary>
    /// Sachbearbeiter auf den VK-Beleg übernehmen
    /// <see cref="#U29F"/>
    /// </summary>
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnValidateSellToCustomerNoOnBeforeRecallModifyAddressNotification', '', false, false)]
    local procedure SalesHeaderOnValidateSellToCustomerNoOnBeforeRecallModifyAddressNotification_Subscr(var SalesHeader: Record "Sales Header"; xSalesHeader: Record "Sales Header")
    var
    begin
        AssignRepsonsiblePersonToSalesHeader(SalesHeader);
        checkShipmentAddress(SalesHeader);
    end;

    /// <summary>
    /// 
    /// </summary>
    /// <param name="SalesHeader"></param>
    /// <param name="xSalesHeader"></param>
    /// <see cref="https://dedongroup.atlassian.net/browse/DEDT-562"/>
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Sell-to Contact No.', false, false)]
    local procedure SalesHeaderOnAfterValidateSSellToContactNo(var Rec: Record "Sales Header"; var xRec: Record "Sales Header")
    begin
        AssignRepsonsiblePersonToSalesHeader(Rec);
    end;

    /// <summary>
    /// Sachbearbeiter auf den VK-Beleg übernehmen
    /// <see cref="#U29F"/>
    /// </summary>
    local procedure AssignRepsonsiblePersonToSalesHeader(var SalesHeader_vRec: Record "Sales Header")
    var
        Customer_lRec: Record Customer;
        Contact_lRec: Record Contact;
    begin
        if SalesHeader_vRec."Sell-to Customer No." = '' then begin
            // ggf aus den Kontakten holen
            if SalesHeader_vRec."Sell-to Contact No." <> '' then begin
                if Contact_lRec.get(SalesHeader_vRec."Sell-to Contact No.") then begin
                    SalesHeader_vRec."COR-DDN Respons. Person Code" := Contact_lRec."COR-DDN Respons. Person Code 2";
                end
            end;
            exit;
        end;
        if not Customer_lRec.get(SalesHeader_vRec."Sell-to Customer No.") then
            exit;
        SalesHeader_vRec."COR-DDN Respons. Person Code" := Customer_lRec."COR-DDN Respons. Person Code 2";
    end;

    // Es kann vorkommen, das sbei Dedon keine abweichende Lieferanschrift gezogen wird.
    local procedure checkShipmentAddress(var SalesHeader_vRec: Record "Sales Header")
    var
        shipToAddress_lRec: record "Ship-to Address";
        ChangeShipToCodeDialog_lLbl: label 'It seems like Business Central did not fill in the expected shipment address. Actually we try it with a workaround. Do you want to apply %1? Please check the shipment address afterwards anyway.';
        c: Codeunit 6036636;
    begin
        if SalesHeader_vRec."Sell-to Customer No." = '' then
            exit;
        if SalesHeader_vRec."Ship-to Code" = '' then begin
            shipToAddress_lRec.SetRange("Customer No.", SalesHeader_vRec."Sell-to Customer No.");
            shipToAddress_lRec.setrange("trm Default Ship-to Code", true);
            if shipToAddress_lRec.FindFirst() then begin
                if confirm(ChangeShipToCodeDialog_lLbl, true, shipToAddress_lRec.Code) then begin
                    SalesHeader_vRec.validate("Ship-to Code", shipToAddress_lRec.Code);
                end
            end;
        end;
    end;

    /// <summary>
    /// Berichtsauswahl erweiternt
    /// <see cref="MCAP"/>
    /// </summary>
    /// <param name="Rec"></param>
    /// <param name="ReportUsage2"></param>
    [EventSubscriber(ObjectType::Page, Page::"Report Selection - Sales", 'OnSetUsageFilterOnAfterSetFiltersByReportUsage', '', false, false)]
    local procedure OnSetUsageFilterOnAfterSetFiltersByReportUsage(var Rec: Record "Report Selections"; ReportUsage2: Option)
    var

    begin
        case ReportUsage2 of
            "Report Selection Usage Sales"::"COR-DDN ShipmentNoteSummaryInvoice".AsInteger():
                Rec.SetRange(Usage, "Report Selection Usage"::"COR-DDN ShipmentNoteSummaryInvoice");
        end;
    end;

    /// <summary>
    /// Verkaufsrechnung: Lieferzeilen holen mit zusätzlichen Informationen Auftragsnummer und Ihre Referenz
    /// <see cref="#R48T"/>
    /// </summary>
    /// <param name="SalesLine"></param>
    /// <param name="SalesShipmentLine"></param>
    /// <param name="NextLineNo"></param>
    [EventSubscriber(ObjectType::Table, Database::"Sales Shipment Line", 'OnAfterDescriptionSalesLineInsert', '', false, false)]
    local procedure SalesShipmentLineOnAfterDescriptionSalesLineInsert(var SalesLine: Record "Sales Line"; SalesShipmentLine: Record "Sales Shipment Line"; var NextLineNo: Integer)
    var
        SalesLineForExtraText_lRec: Record "Sales Line";
        OrderNo_lLbl: Label 'Order No. %1:';
        OrderNoText_lTxt: Text;
        salesShipmentHeader_lRec: Record "Sales Shipment Header";
        TranslationHelper: Codeunit "Translation Helper";
    begin
        salesShipmentHeader_lRec.get(SalesShipmentLine."Document No.");
        if SalesShipmentLine."Order No." <> '' then begin
            NextLineNo += 10000;
            SalesLineForExtraText_lRec."Document Type" := SalesLine."Document Type";
            SalesLineForExtraText_lRec."Document No." := SalesLine."Document No.";
            SalesLineForExtraText_lRec."Line No." := NextLineNo;
            TranslationHelper.SetGlobalLanguageByCode(salesShipmentHeader_lRec."Language Code");
            // Fallback falls keine Übersetzung ermittlet wurde;
            OrderNoText_lTxt := OrderNo_lLbl;
            if OrderNoText_lTxt = '' then
                OrderNoText_lTxt := 'Auftrag Nr. %1:';
            SalesLineForExtraText_lRec.Description := StrSubstNo(OrderNoText_lTxt, SalesShipmentLine."Order No.");
            TranslationHelper.RestoreGlobalLanguage;
            SalesLineForExtraText_lRec.insert;
        end;

        if salesShipmentHeader_lRec."Your Reference" <> '' then begin
            NextLineNo += 10000;
            SalesLineForExtraText_lRec."Document Type" := SalesLine."Document Type";
            SalesLineForExtraText_lRec."Document No." := SalesLine."Document No.";
            SalesLineForExtraText_lRec."Line No." := NextLineNo;
            SalesLineForExtraText_lRec.Description := salesShipmentHeader_lRec."Your Reference";
            SalesLineForExtraText_lRec.insert;
        end
    end;

    /// <summary>
    /// Status in Matrixzelle vorbelegen
    /// <see cref="PLD3"/>
    /// </summary>
    /// <param name="Rec"></param>
    [EventSubscriber(ObjectType::Table, Database::"trm matrix cell", 'OnBeforeInsertEvent', '', false, false)]
    local procedure MatrixCellOnBeforeInsertEvent(var Rec: Record "trm Matrix Cell")
    var
        ddnSetup: Record "DDN Setup";
    begin
        ddnSetup.get();
        if ddnSetup."Matrix Cell default Status" <> '' then
            Rec.Validate("Status Code", ddnSetup."Matrix Cell default Status");
    end;

    /// <summary>
    /// manuelle Änderungen des WA-Datums führen dazu, dass das shift-Datum geleert wird weil es obsolete wurde
    /// <see cref="#DSDS"/>
    /// </summary>
    [EventSubscriber(ObjectType::table, Database::"Sales Line", 'OnValidateShipmentDateOnAfterSalesLineVerifyChange', '', false, false)]
    local procedure SalesLineOnValidateShipmentDateOnAfterSalesLineVerifyChange(var SalesLine: Record "Sales Line"; CurrentFieldNo: Integer)
    var
        dsdsMgmt: Codeunit "COR DSDS Availibility Mgmt.";
    begin
        dsdsMgmt.SalesLineOnValidateShipmentDateOnAfterSalesLineVerifyChange(SalesLine, CurrentFieldNo);
    end;

    /// <summary>
    /// Bei Eingabe einer neuen Zeile prüfen, ob die Zeile ggf. einem vorigen Config-Artikel zuzuordnen ist
    /// </summary>
    /// <see cref="#9LUF"/>
    /// <param name="SalesLine"></param>
    /// <param name="xSalesLine"></param>
    [EventSubscriber(ObjectType::Page, Page::"Sales Order Subform", 'OnAfterNoOnAfterValidate', '', false, false)]
    local procedure SalesOrderSubformOnAfterNoOnAfterValidate(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line")
    begin
        LinkSalesLineToConfig(SalesLine, xSalesLine);
    end;

    /// <summary>
    /// Bei Eingabe einer neuen Zeile prüfen, ob die Zeile ggf. einem vorigen Config-Artikel zuzuordnen ist
    /// </summary>
    /// <see cref="#9LUF"/>
    /// <param name="SalesLine"></param>
    /// <param name="xSalesLine"></param>
    [EventSubscriber(ObjectType::Page, Page::"Sales Quote Subform", 'OnAfterNoOnAfterValidate', '', false, false)]
    local procedure SalesQuoteSubformOnAfterNoOnAfterValidate(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line")
    begin
        LinkSalesLineToConfig(SalesLine, xSalesLine);
    end;

    /// <summary>
    /// <see cref="#9LUF"/>
    /// </summary>
    /// <param name="SalesLine"></param>
    local procedure LinkSalesLineToConfig(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line")
    var
        prevSalesLines_lRec, nextSalesLines_lRec : Record "Sales Line";
        ItemAssigned_lNot: Notification;
        ItemAssigned_lLbl: Label 'The Item %1 has been assigned to %2.';
        item: Record item;
        IsItemAttachedToPreviousLine_lLbl: Label 'Do you want to attach %1 the item to %2?';
    begin
        if SalesLine.Type <> SalesLine.Type::item then
            exit;
        if SalesLine."Attached to Line No." > 0 then
            exit;

        // Vorgänger ermitteln
        // es wird sich am Vorgänger orientiert
        prevSalesLines_lRec.SetLoadFields("Attached to Line No.", "DDN Set Master No.", "DDN Set Master No.", "COR-DDN Set Quantity");
        prevSalesLines_lRec.setrange("Document Type", SalesLine."Document Type");
        prevSalesLines_lRec.setrange("Document No.", SalesLine."Document No.");
        prevSalesLines_lRec.SetFilter("Line No.", '<%1', SalesLine."Line No.");

        // Nachfolger ermitteln (erster Teil des Filters)
        nextSalesLines_lRec.SetLoadFields("Attached to Line No.", "DDN Set Master No.", "DDN Set Master No.", "COR-DDN Set Quantity");
        nextSalesLines_lRec.setrange("Document Type", SalesLine."Document Type");
        nextSalesLines_lRec.setrange("Document No.", SalesLine."Document No.");

        if prevSalesLines_lRec.findlast then begin
            // Nachfolger ermitteln
            // das ist ausschließlich hilfreich um zu erkennen, ob
            // die Zeile eindeutig als Zwischenzeile inordenbar ist
            nextSalesLines_lRec.SetRange("Attached to Line No.", prevSalesLines_lRec."Attached to Line No.");
            nextSalesLines_lRec.SetFilter("Line No.", '>%1', SalesLine."Line No.");
            // wir sind eindeutig zwischen zwei Zeilen
            if nextSalesLines_lRec.findfirst then begin
                transfertAttachedToLineAndSetInfo(SalesLine, prevSalesLines_lRec);
            end
            else begin
                nextSalesLines_lRec.SetRange("Attached to Line No.");
                // wir befinden uns eindeutig am Ende des Belegs
                if not nextSalesLines_lRec.FindFirst() then begin
                    // Wir wissen nicht, ob der Anwender am Ende des Belegs eine Komponente zu dem darüber liegenden Artikel erzeugen will oder
                    // ob es eine neue Zeile ist
                    // Bei Mastern gehen wir davon aus, dass er nicht der vorhergenden Zeile zuzuordnen ist
                    if SalesLine."trm Master No." = '' then begin
                        if prevSalesLines_lRec."DDN Set Item No." <> '' then begin
                            if confirm(IsItemAttachedToPreviousLine_lLbl, true, salesLine."No.", prevSalesLines_lRec."DDN Set Item No.") then begin
                                transfertAttachedToLineAndSetInfo(SalesLine, prevSalesLines_lRec);
                            end;
                        end;
                    end;
                end
                // es gibt weitere Zeilen. Sie gehören aber zu einem andern Config-Artikel
                else begin
                    transfertAttachedToLineAndSetInfo(SalesLine, prevSalesLines_lRec);
                end;
            end;
        end
        else begin
            // es gibt keinen Vorgänger
            // Das kann der Fall sein wenn wir direkt unterhalb der Config-Zeile eine neue Zeile anlegen
            nextSalesLines_lRec.SetFilter("Line No.", '>%1', SalesLine."Line No.");
            if nextSalesLines_lRec.FindFirst() then begin
                // die nächste Zeile ist ggf zugehörig
                if nextSalesLines_lRec."Attached to Line No." > 0 then begin
                    transfertAttachedToLineAndSetInfo(SalesLine, nextSalesLines_lRec);
                end
                else begin
                    // hier gibt es weder Vorgänger noch Nachfolger. Also nichts weiter machen
                end;
            end
            else begin
                // Die nächste Zeile ist nicht zugehörig zu einem Config-Artikel. Also ist auch hier nichts zu tun
            end;
        end;

        if SalesLine."DDN Set Item No." <> xSalesLine."DDN Set Item No." then begin
            ItemAssigned_lNot.Message := StrSubstNo(ItemAssigned_lLbl, SalesLine."No.", SalesLine."DDN Set Item No.");
            ItemAssigned_lNot.Send();
        end
    end;

    /// <summary>
    /// Wird sowohl auf Artikeleben
    /// </summary>
    /// <param name="DestSalesLine_vRec"></param>
    /// <param name="SrcSalesLine_vRec"></param>
    local procedure transfertAttachedToLineAndSetInfo(var DestSalesLine_vRec: Record "Sales Line"; var SrcSalesLine_vRec: Record "Sales Line")
    var
        myInt: Integer;
    begin
        DestSalesLine_vRec."Attached to Line No." := SrcSalesLine_vRec."Attached to Line No.";
        DestSalesLine_vRec."DDN Set Master No." := SrcSalesLine_vRec."DDN Set Master No.";
        DestSalesLine_vRec."DDN Set Item No." := SrcSalesLine_vRec."DDN Set Item No.";
        // #9LUF Menge Set in Belegzeile und Posten
        DestSalesLine_vRec."COR-DDN Set Quantity" := SrcSalesLine_vRec."COR-DDN Set Quantity";
        initIntakeDate(DestSalesLine_vRec);
    end;

    /// <summary>
    /// <see cref="#C4JZ"/>
    /// </summary>
    /// <param name="WarehouseShipmentHeader"></param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Shipment Release", 'OnBeforeRelease', '', false, false)]
    local procedure SalesTriggerPoolOnBeforeRelease(var WarehouseShipmentHeader: Record "Warehouse Shipment Header")
    var
        ddnSetup: Record "DDN Setup";
    begin
        ddnSetup.get();
        if not ddnSetup."enable Warehouse JH Status" then
            exit;

        // TODO ReactivateJungheinrichCode reactivate 1 Line below
        WarehouseShipmentHeader.validate("Status JH", WarehouseShipmentHeader."Status JH"::"Released to WMS");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post Prepayments", 'OnCodeOnBeforeWindowOpen', '', false, false)]
    local procedure OnCodeOnBeforeWindowOpen(var SalesHeader: Record "Sales Header"; DocumentType: Option Invoice,"Credit Memo")
    var
        p: page "Sales Order";
        sh: Record "Sales Header";
        text_loc: Text;
        postingDescriptionHeader_loc: Record "trm Posting Description Header";
    begin
        case DocumentType of
            Documenttype::Invoice:
                begin
                    text_loc := postingDescriptionHeader_loc.GetPostText(10, SalesHeader."Language Code");
                end;
            Documenttype::"Credit Memo":
                begin
                    text_loc := postingDescriptionHeader_loc.GetPostText(11, SalesHeader."Language Code");
                end;
            else
                exit;
        end;
        text_loc := StrSubstNo(Text_loc, salesheader."No.");
        salesHeader."Prepmt. Posting Description" := CopyStr(text_loc, 1, MaxStrLen(SalesHeader."Prepmt. Posting Description"));
    end;

    /// <summary>
    /// Für den Belegdruck soll der Auftragswert mitgenommen werden.
    /// <see cref="#GLR1"/>
    /// </summary>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post Prepayments", 'OnBeforeSalesInvHeaderInsert', '', false, false)]
    local procedure SalesPostPrepaymenOnBeforeSalesInvHeaderInsert(var SalesInvHeader: Record "Sales Invoice Header"; SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; GenJnlDocNo: Code[20])
    begin
        SalesHeader.calcfields(amount);
        SalesInvHeader."COR-DDN Order Amount Prepay" := SalesHeader.Amount;
    end;

    /// <summary>
    /// Bug in Trimit weil Vorauszahlung nicht berücksichtigt wird
    /// Stand 22.03.2023 zeigt, dass der Workaround nicht greift. Es muss ein Trimit-Update abgewartet werden.
    /// <see cref="https://dedongroup.atlassian.net/browse/DEDT-341"/>
    /// </summary>
    /// <param name="salesLine_par"></param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"trm Sales-Quote to Order Event", 'Pf_OnAfterInsertSalesLine', '', false, false)]
    local procedure trmSalesQuoteToOrderEventPf_OnAfterInsertSalesLine(var salesLine_par: Record "Sales Line")
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        PrepmtMgt: Codeunit "Prepayment Mgt.";
    begin
        // bewusst deaktiviert weil nicht funktionisfähig mit Trimit
        exit;
    end;

    /// <summary>
    /// Patch weil Trimit nicht sauber mit Vorkasse umgehen kann.
    /// <see cref="https://dedongroup.atlassian.net/browse/DEDT-341"/>
    /// </summary>
    /// <param name="SalesOrderLine">VAR Record "Sales Line".</param>
    /// <param name="SalesQuoteHeader">Record "Sales Header".</param>
    /// <param name="SalesOrderHeader">VAR Record "Sales Header".</param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Quote to Order", 'OnAfterInsertAllSalesOrderLines', '', false, false)]
    local procedure SalesQuoteToOrderOnAfterInsertAllSalesOrderLines(var SalesOrderLine: Record "Sales Line"; SalesQuoteHeader: Record "Sales Header"; var SalesOrderHeader: Record "Sales Header")
    begin
        if SalesOrderHeader."Prepayment %" = 0 then
            exit;
        SalesOrderLine.setrange("Document Type", SalesOrderHeader."Document Type");
        SalesOrderLine.setrange("Document No.", SalesOrderHeader."No.");
        //if confirm('Sollen %1 Auftragszeilen auf Vorkasse gesetzt werden?', true, SalesOrderLine.count) then begin
        SalesOrderLine.ModifyAll("Prepayment %", SalesOrderHeader."Prepayment %", true);
        //end;
    end;

    /// <summary>
    /// Beim Erzeugen von Verkaufsbelegen grätscht das Feld "Order Type" dazwischen
    /// </summary>
    /// <param name="tRIMITServiceSalesHeaderTemp_par">Temporary VAR Record "trm API Sales Header".</param>
    /// <param name="complaintLine_par">Record "trm Complaint Line".</param>
    /// <param name="calledConcerning_par">Option "Credit Memo","Order",Invoice,"Return Order".</param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"trm Complaint Handling", 'Pf_OnBeforeInsertTsSalesHeaderTemp', '', false, false)]
    local procedure TrmComplaintHandlingPf_OnBeforeInsertTsSalesHeaderTemp(var tRIMITServiceSalesHeaderTemp_par: Record "trm API Sales Header" temporary; complaintLine_par: Record "trm Complaint Line"; calledConcerning_par: Option "Credit Memo","Order",Invoice,"Return Order")
    var

    begin
        // Zeile deatkiviert wegen Vorgang DEDT-542
        // dort war eine Rechnungsnummer vorhanden; Trotzdem wurden bei Rücklieferungen mehrere Dokumente erstellt
        if complaintLine_par."Concerning Invoice" = '' then
            TRIMITServiceSalesHeaderTemp_par."Order Type" := '';
    end;

    /// <summary>
    /// Bei Reklamationen kann es vorkommen, dass der Order Type bei Anlage eines Auftrags vorbelegt wird
    /// 
    /// </summary>
    /// <param name="Rec"></param>
    /// <param name="xRec"></param>
    /// <param name="RunTrigger"></param>
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeModifyEvent', '', false, false)]
    local procedure OnAfterSalesHeaderModify(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; RunTrigger: Boolean)
    begin
        AdjustSalesHeaderForComplaintCompatibility(Rec);
    end;

    local procedure AdjustSalesHeaderForComplaintCompatibility(var salesHeader_vRec: Record "Sales Header")
    var
        ComplaintHeader_lRec: Record "trm Complaint Header";
        ComplaintLine_lRec: Record "trm Complaint Line";
        SalesInvoiceHeader_lRec: Record "Sales Invoice Header";
    begin
        if salesHeader_vRec."Document Type" in [salesHeader_vRec."Document Type"::Quote, salesHeader_vRec."Document Type"::"Blanket Order", salesHeader_vRec."Document Type"::Invoice] then
            exit;
        if not salesHeader_vRec."trm Complaint" then
            exit;
        if salesHeader_vRec."trm Document Reference" = '' then
            exit;
        ComplaintHeader_lRec.SetLoadFields("Order Type");
        if not ComplaintHeader_lRec.get(salesHeader_vRec."trm Document Reference") then
            exit;

        if ComplaintHeader_lRec."Order Type" <> '' then begin
            salesHeader_vRec."trm Order Type" := ComplaintHeader_lRec."Order Type";
        end;
        // Plan B über die Rechnungsnummer 
        ComplaintLine_lRec.SetRange("Document No.", salesHeader_vRec."trm Document Reference");
        ComplaintLine_lRec.setfilter("Concerning Invoice", '<>''''');
        ComplaintLine_lRec.SetLoadFields("Concerning Invoice Line No.");
        if not ComplaintLine_lRec.FindFirst() then
            exit;
        SalesInvoiceHeader_lRec.SetLoadFields("trm order type");
        if not SalesInvoiceHeader_lRec.get(ComplaintLine_lRec."Concerning Invoice") then
            exit;

        salesHeader_vRec."trm Order Type" := SalesInvoiceHeader_lRec."trm Order Type";
    end;

    /// <summary>
    /// Dem Ticket DEDT-401 konnte es dazukommen, dass Bei Vorauszahlugnsrechnungne eine Nummernserie der Vorauszahlungsgutschriften gezogen wurde.
    /// Ursache ist ein gefülltes Fels "Prepayment No." im Verkaufsauftrag.
    /// Es ist nicht nachvollziehbar, durhc welchen Vorgang das Feld "Pepament No." gefüllt wurde.
    /// Daher der Workaround an dieser Stelle
    /// </summary>
    /// <param name="SalesHeader"></param>
    /// <param name="DocumentType"></param>
    /// <param name="DocNo"></param>
    /// <param name="NoSeriesCode"></param>
    /// <param name="ModifyHeader"></param>
    /// <param name="IsPreviewMode"></param>
    /// <param name="IsHandled"></param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post Prepayments", 'OnBeforeUpdateDocNos', '', false, false)]
    local procedure SalesPostPepaymentsOnBeforeUpdateDocNos(var SalesHeader: Record "Sales Header"; DocumentType: Option Invoice,"Credit Memo"; var DocNo: Code[20]; var NoSeriesCode: Code[20]; var ModifyHeader: Boolean; IsPreviewMode: Boolean; var IsHandled: Boolean)
    begin
        if DocumentType = DocumentType::Invoice then begin

            if SalesHeader."Prepayment No." <> '' then begin
                clear(SalesHeader."Prepayment No.");
            end;

            if SalesHeader."Prepayment No. Series" <> '' then begin
                clear(SalesHeader."Prepayment No. Series");
            end;
        end;
    end;


    /// <summary>
    /// Vorberelgung des LAgerortcodes gem. DEDT-329
    /// Siiehe auch pageextension 51060
    /// </summary>
    /// <param name="Item"></param>
    /// <param name="ForecastName"></param>
    /// <param name="IncludeBlanketOrders"></param>
    /// <param name="ExcludeForecastBefore"></param>
    /// <param name="IncludePlan"></param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calc. Inventory Page Data", 'OnAfterInitialize', '', false, false)]
    local procedure CalcInventoryPageDataOnAfterInitialize(var Item: Record Item; var ForecastName: Code[10]; var IncludeBlanketOrders: Boolean; var ExcludeForecastBefore: Date; var IncludePlan: Boolean)
    var
        ddnSetup: Record "DDN Setup";
    begin
        if item.GetFilter("Location Filter") <> '' then
            exit;
        ddnSetup.get();
        item.setrange("Location Filter", ddnSetup."Location Code 1_WMS");
    end;

    /// <summary>
    /// Das WA-Datum darf trotz Freigabe verändert werden
    /// </summary>
    /// <param name="SalesLine"></param>
    /// <param name="SalesHeader"></param>
    /// <param name="IsHandled"></param>
    /// <param name="xSalesLine"></param>
    /// <param name="CallingFieldNo"></param>
    /// <param name="StatusCheckSuspended"></param>
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeTestStatusOpen', '', false, false)]
    local procedure SalesLineOnBeforeTestStatusOpen(var SalesLine: Record "Sales Line"; var SalesHeader: Record "Sales Header"; var IsHandled: Boolean; xSalesLine: Record "Sales Line"; CallingFieldNo: Integer; var StatusCheckSuspended: Boolean)
    begin
        if SalesLine."Document Type" <> SalesLine."Document Type"::Order then
            exit;
        if CallingFieldNo = SalesLine.FieldNo("Shipment Date") then begin
            StatusCheckSuspended := true;
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnBeforeReleaseSalesDoc', '', false, false)]
    local procedure ReleaseSalesDocOnBeforeReleaseSalesDoc(VAR SalesHeader: Record "Sales Header"; PreviewMode: Boolean)
    var
    begin
        SalesHeader.CalculateApprovalDelta();
        SalesHeader.modify();
    end;

    /// <summary>
    /// Berechnung eines Deltas bei Freigabe durch Genehmigungsprozesse
    /// DEDT-471
    /// <see cref="#K1MF"/>
    /// </summary>   
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnBeforeApproveApprovalRequests', '', false, false)]
    local procedure OnBeforeApproveApprovalRequests(var ApprovalEntry: Record "Approval Entry"; var IsHandled: Boolean)
    var
        SalesHeader: Record "Sales Header";
    begin
        if ApprovalEntry."Table ID" <> Database::"Sales Header" then
            exit;
        if ApprovalEntry."Document Type" <> ApprovalEntry."Document Type"::Order then
            exit;
        if not SalesHeader.get(SalesHeader."Document Type"::Order, ApprovalEntry."Document No.") then
            exit;
        SalesHeader."COR-DDN Approval Entry No." := ApprovalEntry."Entry No.";
        SalesHeader.CalculateApprovalDelta();

        SalesHeader.modify();
    end;

    /// <summary>
    /// Berechnung eines Deltas vor Weitergabe eines Auftrags in den Genehmigungsprozess
    /// DEDT-471
    /// <see cref="#K1MF"/>
    /// </summary>   
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnAfterCheckSalesApprovalPossible', '', false, false)]
    local procedure OnAfterCheckSalesApprovalPossible(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader.CalculateApprovalDelta();
        SalesHeader.modify();
    end;

    /// <summary>
    /// Im Zuge von DSDS soll es möglich sein, das WA-Datum auch bei freigegebenen Aufträgen zu ändern
    /// </summary>
    /// <param name="salesLine_par">VAR Record "Sales Line".</param>
    /// <param name="xSalesLine_par">Record "Sales Line".</param>
    /// <param name="calledByFieldNo_par">Integer.</param>
    /// <param name="isHandled_par">VAR Boolean.</param>
    [EventSubscriber(ObjectType::Table, Database::"Sales line", 'trmPf_OnBeforeUpDateUnitPrice', '', false, false)]
    local procedure SalesLinetrmPf_OnBeforeUpDateUnitPrice(var salesLine_par: Record "Sales Line"; xSalesLine_par: Record "Sales Line"; calledByFieldNo_par: Integer; var isHandled_par: Boolean)
    begin
        if calledByFieldNo_par <> salesLine_par.FieldNo("Shipment Date") then
            exit;
        salesLine_par.trmSet_SkipCalcUnitPrice(true);
        salesLine_par.trmSet_SkipCalcLineDisc(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnValidateShipmentDateOnAfterSalesLineVerifyChange', '', false, false)]
    local procedure OnValidateShipmentDateOnAfterSalesLineVerifyChange(var SalesLine: Record "Sales Line"; CurrentFieldNo: Integer)
    var
        AvailibilityMgmt: Codeunit "COR DSDS Availibility Mgmt.";
    begin
        if CurrentFieldNo <> SalesLine.FieldNo("Shipment Date") then
            exit;
        AvailibilityMgmt.CalcDelayedFlag_lFnc(SalesLine);
    end;

    /// <summary>
    /// Verhinderung von Buchungen bei Make-to-Order-Fertigung
    /// Als Workaround wird die Replenishment Policy einfach auf Inventory gesetzt
    /// </summary>
    /// <param name="TempSalesLine">Temporary VAR Record "Sales Line".</param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterCopyToTempLines', '', false, false)]
    local procedure OnAfterCopyToTempLines(var TempSalesLine: Record "Sales Line" temporary)
    var
        inventorySetup_lRec: Record "Inventory Setup";
        ddnSetup: Record "DDN Setup";
    begin
        inventorySetup_lRec.get();
        if inventorySetup_lRec."trm Time for RelatOrd Posting" <> inventorySetup_lRec."trm Time for RelatOrd Posting"::"On Demand" then
            exit;
        ddnSetup.get();
        if not ddnSetup."prevent rel. order posting" then
            exit;
        //TempSalesLine.SetRange("trm Replenishment System", TempSalesLine."trm Replenishment System"::"Prod. Order");
        TempSalesLine.setrange("trm Replenishment Policy", TempSalesLine."trm Replenishment Policy"::Order);
        if not TempSalesLine.IsEmpty then
            TempSalesLine.modifyall("trm Replenishment Policy", TempSalesLine."trm Replenishment Policy"::Inventory, false);
        TempSalesLine.setrange("trm Replenishment Policy");
        //TempSalesLine.SetRange("trm Replenishment System");
    end;

    /// <summary>
    /// Da es bei Buchung von Warenausgängen mit Teillieferungen und Vorkasse zu Fehlermeldungen kam
    /// wurde dieser Event-Subscriber erstellt. Die Betragsprüfung wird dadurch quasi deaktiviert.
    /// </summary>
    /// <see cref="https://dedongroup.atlassian.net/browse/DEDT-549"/>
    /// <param name="SalesLine">VAR Record "Sales Line".</param>
    /// <param name="IsHandled">VAR Boolean.</param>
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeCheckPrepmtAmounts', '', false, false)]
    local procedure SalesLineOnBeforeCheckPrepmtAmounts(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    var
        ddnSetup_lRec: Record "DDN Setup";
    begin
        if SalesLine."Prepayment Amount" = 0 then
            exit;
        ddnSetup_lRec.get();
        if ddnSetup_lRec."disable prepaym. amount check" then
            IsHandled := true;
    end;

    /// <summary>
    /// Belegnummer in die Mail Log Entries schrieben
    /// </summary>
    /// <see cref="https://dedongroup.atlassian.net/browse/DEDT-554"/>
    /// <param name="logEntry_par">VAR Record "trm E-Mail Log Entry".</param>
    /// <param name="template_par">Record "trm E-Mail Template".</param>
    /// <param name="templateRecient_par">Record "trm E-Mail Recipient".</param>
    /// <param name="printRecRef_par">RecordRef.</param>
    /// <param name="recipientRecRef_par">RecordRef.</param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"trm E-Mail Handling", 'Pf_OnCreateMailLast', '', false, false)]
    local procedure trmEmailHandlingPf_OnCreateMailLast(var logEntry_par: Record "trm E-Mail Log Entry"; template_par: Record "trm E-Mail Template"; templateRecient_par: Record "trm E-Mail Recipient"; printRecRef_par: RecordRef; recipientRecRef_par: RecordRef)
    var
        SalesInvoiceHeader_lRec: Record "Sales Invoice Header";
        SalesCrMemoHeader_lRec: Record "Sales Cr.Memo Header";
        SalesHeader_lRec: Record "Sales Header";
    begin

        logEntry_par."COR-DDN Source Table Id" := printRecRef_par.Number;

        case logEntry_par."COR-DDN Source Table Id" of
            Database::"Sales Header":
                begin
                    printRecRef_par.SetTable(SalesHeader_lRec);
                    logEntry_par."COR-DDN Source Doc. Type" := salesHeader_lRec."Document Type";
                    logEntry_par."COR-DDN Source Doc. No." := SalesHeader_lRec."No.";
                end;
            Database::"Sales Invoice Header":
                begin
                    printRecRef_par.SetTable(SalesInvoiceHeader_lRec);
                    logEntry_par."COR-DDN Source Doc. No." := SalesInvoiceHeader_lRec."No.";
                end;
            Database::"Sales Cr.Memo Header":
                begin
                    printRecRef_par.SetTable(SalesCrMemoHeader_lRec);
                    logEntry_par."COR-DDN Source Doc. No." := SalesCrMemoHeader_lRec."No.";
                end;
        end;
    end;

    /// <summary>
    /// OnAfterValidateShippingOptions.
    /// </summary>
    /// <param name="SalesHeader">VAR Record "Sales Header".</param>
    /// <param name="ShipToOptions">Option "Default (Sell-to Address)","Alternate Shipping Address","Custom Address".</param>
    /// <see cref="https://dedongroup.atlassian.net/browse/DEDT-358"/>
    [EventSubscriber(ObjectType::Page, Page::"Sales Order", 'OnAfterValidateShippingOptions', '', false, false)]
    local procedure OnAfterValidateShippingOptions(var SalesHeader: Record "Sales Header"; ShipToOptions: Option "Default (Sell-to Address)","Alternate Shipping Address","Custom Address")
    var
        NoCustomShippingAddressAllowedError_lLbl: Label 'It is only allowed to ship to addresses that have been apporved by the finance team.';
    begin
        if ShipToOptions = ShipToOptions::"Custom Address" then begin
            error(NoCustomShippingAddressAllowedError_lLbl);
        end;
    end;

    /// <summary>
    /// Bei Anlage eines Artikels via Master wird der Stoffbedarf nicht automatisch vererbt
    /// </summary>
    /// <param name="item_par"></param>
    /// <see cref="https://dedongroup.atlassian.net/browse/DEDT-555"/>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"trm Generate BOM Structure", 'Pf_OnAfterInsertNewItem', '', false, false)]
    local procedure TrmGenerateBomStructurePf_OnAfterInsertNewItem(var item_par: Record Item)
    var
        Master_lRec: Record "trm Master";
        doModify_lBool: Boolean;
    begin
        if item_par."trm Master No." = '' then
            exit;
        if not Master_lRec.get(item_par."trm Master No.") then
            exit;
        if Master_lRec."DDN Fabric Consumption" <> 0 then begin
            item_par."DDN Fabric Consumption" := Master_lRec."DDN Fabric Consumption";
            doModify_lBool := true;
        end;
        if Master_lRec."DDN Designer Code" <> '' then begin
            item_par."DDN Designer Code" := Master_lRec."DDN Designer Code";
            doModify_lBool := true;
        end;

        if doModify_lBool then
            item_par.modify(false);
    end;
}