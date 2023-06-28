tableextension 51021 "DDN Purchase Line" extends "Purchase Line" //39
{
    fields
    {
        /// <summary>
        /// Gewünschtes Versanddatum
        /// <see cref="#7JRN"/>
        /// </summary>
        field(51000; "DDN Requested Shipment Date"; Date)
        {
            Caption = 'Requested Shipment Date';
            DataClassification = ToBeClassified;
        }
        /// <summary>
        /// Zugesagtes Versanddatum
        /// <see cref="#7JRN"/>
        /// </summary>        
        field(51001; "DDN Estimated Date Ready"; Date)
        {
            Caption = 'Estimated Date Ready';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var

            begin
                ValidatePlannedReceiptDate("DDN Estimated Date Ready");
            end;
        }
        /// <summary>
        /// Tatsächliches Versanddatum
        /// <see cref="#7JRN"/>
        /// </summary>        
        field(51002; "DDN Effective Shipment Date"; Date)
        {
            Caption = 'Effective Shipment Date';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var

            begin
                ValidatePlannedReceiptDate("DDN Effective Shipment Date");
            end;
        }
        /// <summary>
        /// Originalmenge nachhalten
        /// <see cref="#6SWK"/>
        /// </summary>
        field(51003; "DDN Original Qty."; Decimal)
        {
            Caption = 'Original Qty.';
            DataClassification = ToBeClassified;
            Editable = false;
            DecimalPlaces = 0 : 4;
        }

        field(51004; "DDN Document Status"; Enum "Purchase Document Status")
        {
            Caption = 'Document Status';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Purchase Header".Status where("document Type" = field("Document Type"), "No." = Field("Document No.")));
        }
        /// <summary>
        /// <see cref="#1Z54"/>
        /// </summary>              
        field(51005; "Item No. 2"; Code[20])
        {
            Caption = 'Item No. 2';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(Item."No. 2" where("No." = field("No.")));
        }
        /// <summary>
        /// <see cref="#1Z54"/>
        /// </summary>              
        field(51006; "Item Search Description"; Code[100])
        {
            Caption = 'Item Search Description';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(Item."Search Description" where("No." = field("No.")));
        }
        /// <summary>
        /// <see cref="#V5MQ"/>
        /// </summary>            
        field(51007; "DDN Item Planning Status Code"; Code[20])
        {
            Caption = 'Planning Status';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(Item."DDN Item Planning Status Code" where("No." = field("No.")));
        }
        /// <summary>
        /// <see cref="#MNVF"/>
        /// </summary>             
        field(51008; "Container Status"; Code[20])
        {
            Caption = 'Container Status';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("trm Container"."Status Code" where("Container ID" = field("trm Container No.")));
        }
        /// <summary>
        /// <see cref="#MNVF"/>
        /// </summary>             
        field(51009; "Container Estimated Date Ready"; Date)
        {
            Caption = 'Container Estimated Date Ready';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("trm Container"."DDN Estimated Date Ready" where("Container ID" = field("trm Container No.")));
        }
        /// <summary>
        /// Platzhalter weil "Purch. Rcpt. Line" ein FlowFeld benötigt um die PO-Nummer zu identifiizieren
        /// bisher inaktiv und nur als Reminder im Code
        /// </summary>
        /*
        field(510010; "COR-DDN Purchase Order No."; Code[20])
        {
            Caption='Purchase Order No.';
            Editable=false;
            FieldClass=FlowField;
            CalcFormula=lookup("Purch. Rcpt. Header"."Order No." where("No."=field("Document No.")));
        }
        */


        field(51010; "Buy-from Vendor Name"; Text[100])
        {
            Caption = 'Buy-from Vendor Name';
            FieldClass = FlowField;
            CalcFormula = lookup("Purchase Header"."Buy-from Vendor Name" where("Document Type" = field("Document Type"), "No." = field("Document No.")));
            Editable = false;
        }
        field(51011; "COR-DDN Vendor Order No."; Code[35])
        {
            Caption = 'Vendor Order No.';
            FieldClass = FlowField;
            CalcFormula = lookup("Purchase Header"."Vendor Order No." where("Document Type" = field("Document Type"), "No." = field("Document No.")));
            Editable = false;
        }
        field(51012; "COR-DDN Legacy System Item No."; Code[20])
        {
            Caption = 'Legacy System Item No.';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(Item."DDM Legacy System Item No." where("No." = field("No.")));
        }
        field(51013; "COR-DDN Purchaser Code"; Code[20])
        {
            Caption = 'Purchaser Code';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Purchase Header"."Purchaser Code" where("Document Type" = field("document Type"), "No." = field("Document No.")));
        }
        field(51014; "COR-DDN Item GTIN"; Code[14])
        {
            Caption = 'GTIN';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(Item.GTIN where("No." = field("No.")));
        }
    }

    local procedure ValidatePlannedReceiptDate(inputDate_iDate: Date)
    var
    begin
        Rec.validate("Planned Receipt Date", CalcPlannedRecieptDate(inputDate_iDate, Rec."Buy-from Vendor No.", Rec."Location Code"));
    end;

    /// <summary>
    /// Diese Funktion ist öffentlich zugänglich weil sie im Container-Management wiederverwendet wird
    /// </summary>
    /// <param name="inputDate_iDate"></param>
    /// <param name="VendorNo_iCod"></param>
    /// <param name="LocatioCode_iCod"></param>
    /// <returns></returns>
    procedure CalcPlannedRecieptDate(inputDate_iDate: Date; VendorNo_iCod: Code[20]; LocatioCode_iCod: Code[20]) ret: date
    var
        Vendor_lRec: Record Vendor;
        CustomCalendarChange: Array[2] of Record "Customized Calendar Change";
        CalChange: Record "Customized Calendar Change";
        CalendarMgmt: Codeunit "Calendar Management";
        PlannedReceiptDate_lDate: Date;
        DateFormulatoAdjust: DateFormula;
    begin
        if Vendor_lRec.get(VendorNo_iCod) then begin
            DateFormulatoAdjust := vendor_lRec."COR-DDN Transit Periode";
        end
        else begin
            Evaluate(DateFormulatoAdjust, '<0D>');
        end;

        CustomCalendarChange[1].SetSource(CalChange."Source Type"::Location, LocatioCode_iCod, '', '');
        PlannedReceiptDate_lDate := CalendarMgmt.CalcDateBOC(Rec.AdjustDateFormula(DateFormulatoAdjust), inputDate_iDate, CustomCalendarChange, true);
        ret := PlannedReceiptDate_lDate;
    end;
}
