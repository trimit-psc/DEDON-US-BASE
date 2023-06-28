/// <summary>
/// TableExtension DDN Sales Header (ID 51000) extends Record Sales Header.
/// </summary>
tableextension 51000 "DDN Sales Header" extends "Sales Header" //36
{
    fields
    {
        /// <summary>
        /// <see cref="#NFSX"/>
        /// </summary>
        field(51000; "DDN Order Intake Date"; Date)
        {
            DataClassification = ToBeClassified;
            Caption = 'Order Intake Date';
            Editable = false;

            trigger OnValidate()
            var
                SalesLine_lRec: Record "Sales Line";
            begin
                SalesLine_lRec.Reset();
                SalesLine_lRec.SetRange("Document Type", Rec."Document Type");
                SalesLine_lRec.SetRange("Document No.", Rec."No.");
                if SalesLine_lRec.FindSet(true, false) then
                    repeat
                        SalesLine_lRec.Validate("DDN Order Intake Date", Rec."DDN Order Intake Date");
                        SalesLine_lRec.Modify(true);
                    until SalesLine_lRec.Next() = 0;
            end;
        }
        /// <summary>
        /// <see cref="#B9KS"/>
        /// </summary>  
        field(51010; "Export certificate received"; Boolean)
        {
            // Field is only used for sales shipment
            Caption = 'Export certificate received';
            Enabled = false;
            ObsoleteState = Removed;
            ObsoleteReason = 'This field in this table is used as a blocker to avoid double usage (transferfields!)';
        }

        /// <summary>
        /// <see cref="#U29F"/>
        /// </summary>
        field(51011; "COR-DDN Respons. Person Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Salesperson/Purchaser";
            Caption = 'Responsible Person Code';
        }
        /// <summary>
        /// <see cref="#GLR1"/>
        /// </summary>
        field(51012; "COR-DDN Order Amount Prepay"; Decimal)
        {
            Caption = 'Order Amount for prepayment';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        /// <summary>
        /// Genehmigungsmechanismus
        /// DEDT-471
        /// <see cref="#K1MF"/>
        /// </summary>

        field(51013; "COR-DDN Approval Entry No."; Integer)
        {
            Caption = 'postive Approval Entry No';
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = "Approval Entry";
        }

        /// <summary>
        /// Genehmigungsmechanismus
        /// DEDT-471
        /// <see cref="#K1MF"/>
        /// </summary>     
        field(51014; "COR-DDN Approved Amount"; decimal)
        {
            Caption = 'Approved Amount';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Lookup("Approval Entry".Amount where("Entry No." = field("COR-DDN Approval Entry No.")));
        }
        /// <summary>
        /// Genehmigungsmechanismus
        /// DEDT-471
        /// <see cref="#K1MF"/>
        /// </summary>             
        field(51015; "COR-DDN Approval Delta Amount"; decimal)
        {
            Caption = 'Approved Delta Amount';
            Editable = false;
            DataClassification = SystemMetadata;
        }
        field(51016; "COR-DDN Count Sent Mails"; Integer)
        {
            Caption = 'Count sent mails';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("trm E-Mail Log Entry" where(Status = filter('Sent|Error'), "COR-DDN Source Table Id" = const(36), "COR-DDN Source Doc. Type" = field("Document Type"), "COR-DDN Source Doc. No." = field("No.")));
        }
    }

    procedure VanishLineDiscounts()
    var
        salesLine_lRec: Record "Sales Line";
        x: record "trm E-Mail Log Entry";
        mh: codeunit "trm E-Mail Handling";
        rep: report 6036702;
    begin
        salesLine_lRec.SetRange("Document Type", rec."Document Type");
        salesLine_lRec.setrange("Document No.", rec."No.");
        if salesLine_lRec.findset then
            repeat
                salesLine_lRec.VanishLineDiscounts();
            until salesLine_lRec.next() = 0;
    end;

    /// <summary>
    /// Ein Delta-Amount über 0 zeigt, dass ein Teil nicht genehmigt wurde
    /// DEDT-471
    /// <see cref="#K1MF"/>
    /// </summary>     
    procedure CalculateApprovalDelta()
    var
        myInt: Integer;
    begin
        CalcFields(Amount, "COR-DDN Approved Amount");
        "COR-DDN Approval Delta Amount" := Amount - "COR-DDN Approved Amount";
    end;

    /// <summary>
    /// Zuständigkeitseinheit flach im Nachgang korrigieren
    /// <see cref="https://dedongroup.atlassian.net/browse/DEDT-504"/>
    /// </summary>
    procedure ReassignResponsibilityCenter(ResponsibilityCenterSource: Option SelectManually,SellToCustomer)
    var
        RespCenter: record "Responsibility Center";
        UserSetupMgt: Codeunit "User Setup Management";
        Text027: Label 'Your identification is set up to process from %1 %2 only.';
        SalesLine_lRec: Record "Sales Line";
        Customer_lRec: Record Customer;
    begin
        case ResponsibilityCenterSource of
            ResponsibilityCenterSource::SelectManually:
                begin
                    if not (page.runmodal(Page::"Responsibility Center List", RespCenter) in [Action::LookupOK, Action::OK]) then begin
                        if not confirm('Do you want to vanish the responsibility center from this document?') then
                            exit;
                        clear("Responsibility Center");
                    end;
                end;
            ResponsibilityCenterSource::SellToCustomer:
                begin
                    clear("Responsibility Center");
                    if Customer_lRec.get(Rec."Sell-to Customer No.") then begin
                        "Responsibility Center" := Customer_lRec."Responsibility Center";
                    end
                end;
        end;

        // nichts tun falls sich nichts geändert hat.
        if RespCenter.code = "Responsibility Center" then
            exit;
        "Responsibility Center" := RespCenter.Code;
        if not UserSetupMgt.CheckRespCenter(0, "Responsibility Center") then
            Error(
              Text027,
              RespCenter.TableCaption, UserSetupMgt.GetSalesFilter);

        SalesLine_lRec.SetRange("Document Type", "Document Type");
        SalesLine_lRec.SetRange("Document No.", "No.");
        SalesLine_lRec.ModifyAll("Responsibility Center", "Responsibility Center");

    end;
}