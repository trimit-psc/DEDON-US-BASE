/// <summary>
/// Page DDN Purchase Activities (ID 51005).
/// <see cref="#13JD"/>
/// </summary>
page 51005 "DDN Purchase Activities"
{
    Caption = 'Purchase Activities';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "DDN Cue";

    layout
    {
        area(content)
        {
            cuegroup(Tasks)
            {
                CuegroupLayout = Wide;
                field("My Due Workflow"; Rec."My Due Workflow")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDownPageID = "trm My Workflow Activites";
                }
                field("My Group Due Workflow"; Rec."My Group Due Workflow")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDownPageID = "trm My Workflow Activites";
                }
            }

            cuegroup(Purchase)
            {
                Caption = 'Purchase';

                field("Purch. Lines Late (Main Loc.)"; Rec."Purch. Lines Late (Main Loc.)")
                {
                    ApplicationArea = All;
                }
                field("Purch. Lines Upcoming (Winsen)"; Rec."Purch. Lines Delayed (Winsen)")
                {
                    ApplicationArea = All;
                }
                field("Purch. Lines Pending (Main)"; Rec."Purch. Lines Pending (Main)")
                {
                    ApplicationArea = All;
                }
                field("Purch. Lines Loading (Main)"; Rec."Purch. Lines Loading (Main)")
                {
                    ApplicationArea = All;
                }
                field("Scheduled Freights"; Rec."Scheduled Freights")
                {
                    ApplicationArea = All;
                }
                field("Warehouse Receipts"; Rec."Warehouse Receipts")
                {
                    ApplicationArea = All;
                }
                field("Purch. Orders not rlsd. 1_WMS"; Rec."Purch. Orders not rlsd. 1_WMS")
                {
                    ApplicationArea = All;
                }
                field("Purch. Orders not invoiced"; Rec."Purch. Orders not invoiced")
                {
                    ApplicationArea = All;
                }
                field("Purch. Orders received not invoiced"; Rec."Purch. Orders rcvd. not inv.")
                {
                    ApplicationArea = All;
                }
                field(ContainerReceiveidNotInvoiced; ContainerReceiveidNotInvoiced_gRec.count())
                {
                    Caption = 'Containers to be invoiced';
                    ToolTip = 'These Containers were received but have not been invoiced completely yet.';
                    ApplicationArea = All;
                    Lookup = true;
                    DrillDown = true;
                    trigger OnDrillDown()
                    var
                    //ContainerList: Page "trm Container List";
                    begin
                        if ContainerReceiveidNotInvoiced_gRec.count() > 0 then
                            Page.run(Page::"trm container List", ContainerReceiveidNotInvoiced_gRec);
                    end;
                }
            }
            cuegroup(Complaints)
            {
                Caption = 'Complaints';
                field("Open Complaints"; Rec."Open Complaints")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDownPageID = "trm Complaint Orders List";
                }
                field("Orders from Complaints"; Rec."Orders from Complaints")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDownPageID = "Sales Order List";
                }
                field("Credit Memos from Complaints"; Rec."Credit Memos from Complaints")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDownPageID = "Sales Credit Memos";
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        DDNSetup_lRec: Record "DDN Setup";
        NotifyMissingSetup1_gNot: Notification;
        NotifyMissingSetup2_gNot: Notification;
        Container_lRec: Record "trm Container";
        ContainerNoFilter_lTxt: Text;
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;

        // -taken from Trimit
        if not RoleCenterSetup.Get then
            RoleCenterSetup.Insert;

        if (RoleCenterSetup."Starting Date Formula To Ship" <> TestDateFormula) and
           (RoleCenterSetup."Ending Date Formula To Ship" <> TestDateFormula)
        then begin
            Rec.SetRange(
                "Date Filter",
                CalcDate(RoleCenterSetup."Starting Date Formula To Ship", WorkDate),
                CalcDate(RoleCenterSetup."Ending Date Formula To Ship", WorkDate));
            // Rec.SetRange("Date Filter2", 0D, (CalcDate(RoleCenterSetup."Starting Date Formula To Ship", WorkDate) - 1));
        end else begin
            Rec.SetRange("Date Filter", (WorkDate - 1), WorkDate);
            // Rec.SetFilter("Date Filter2", '<=%1', WorkDate - 2);
        end;
        // Rec.SetFilter("Date Filter3", '<=%1', WorkDate);

        Rec.SetFilter("User ID Filter", UserId);
        if (UserSetup.Get(UserId)) and
           (UserSetup."trm Workflow User Groups" <> '')
        then
            Rec.SetFilter("Group ID Filter", UserSetup."trm Workflow User Groups")
        else
            Rec.SetRange("Group ID Filter", ' ');
        // +taken from Trimit

        Rec.SetFilter("Date Filter Upcoming", '%1..%2', WorkDate(), CalcDate('<+1D>', WorkDate()));
        Rec.SetFilter("Date Filter Late", '<%1', WorkDate());
        Rec.SetFilter("Date Filter Pending", '%1..%2', WorkDate(), CalcDate('<+10D>', WorkDate()));

        if DDNSetup_lRec.Get() then begin
            if DDNSetup_lRec."Location Code Main" <> '' then begin
                Rec.SetFilter("Location Filter Main", DDNSetup_lRec."Location Code Main");
            end else begin
                NotifyMissingSetup1_gNot.Message := StrSubstNo(LocationMissing_gLbl, DDNSetup_lRec.FieldCaption("Location Code Main"), DDNSetup_lRec.TableCaption);
                NotifyMissingSetup1_gNot.Send();
            end;

            if DDNSetup_lRec."Location Code Winsen" <> '' then begin
                Rec.SetFilter("Location Filter Winsen", DDNSetup_lRec."Location Code Winsen");
            end else begin
                NotifyMissingSetup2_gNot.Message := StrSubstNo(LocationMissing_gLbl, DDNSetup_lRec.FieldCaption("Location Code Winsen"), DDNSetup_lRec.TableCaption);
                NotifyMissingSetup2_gNot.Send();
            end;

            if DDNSetup_lRec."Location Code 1_WMS" <> '' then begin
                Rec.SetFilter("Location Filter 1_WMS", DDNSetup_lRec."Location Code 1_WMS");
            end else begin
                NotifyMissingSetup2_gNot.Message := StrSubstNo(LocationMissing_gLbl, DDNSetup_lRec.FieldCaption("Location Code 1_WMS"), DDNSetup_lRec.TableCaption);
                NotifyMissingSetup2_gNot.Send();
            end;
        end;

        Rec.setrange("JH Status Filter", rec."JH Status Filter"::New);

        // nur Bestellzeilen deren Container-Status passt
        Container_lRec.setfilter(Status, '%1|%2', Container_lRec.Status::" ", Container_lRec.Status::Ready);
        Container_lRec.setrange(Type, Container_lRec.Type::Inbound);
        Container_lRec.SetLoadFields("No.");
        if Container_lRec.FindSet() then begin
            ContainerNoFilter_lTxt := Container_lRec."No.";
            repeat
                ContainerNoFilter_lTxt += '|' + Container_lRec."No."
            until Container_lRec.next() = 0;
        end;
        Rec.setfilter("Container No. Filter", ContainerNoFilter_lTxt);

        CreateQueueContainerReceiveidNotInvoiced();
    end;

    /// <summary>
    /// Baut einen Stapel auf um die eingetroffenen, noch nicht fakturierten Container anzuzeigen
    /// </summary>
    local procedure CreateQueueContainerReceiveidNotInvoiced()
    var
        PurchaseInvoiceLine: Record "Purch. Inv. Line";
        purchaseLine_lRec: Record "Purchase Line";
    begin
        purchaseLine_lRec.setfilter("trm Container No.", '<>''''');
        purchaseLine_lRec.setfilter("Qty. Rcd. Not Invoiced (Base)", '<>0');
        purchaseLine_lRec.setrange("Document Type", purchaseLine_lRec."Document Type"::Order);
        purchaseLine_lRec.SetLoadFields("trm Container No.");
        //purchaseLine_lRec.setrange("Document No.", '100-POC-2021-00147');
        ContainerReceiveidNotInvoiced_gRec.reset();
        if purchaseLine_lRec.findset(false, false) then
            repeat
                // nur alle jene Zeilen berücksichtigen, die etwas mit Vorkasse zu tun haben
                PurchaseInvoiceLine.setrange("Order No.", purchaseLine_lRec."Document No.");
                PurchaseInvoiceLine.setrange("Order Line No.", purchaseLine_lRec."Line No.");
                PurchaseInvoiceLine.setrange(type, PurchaseInvoiceLine.type::"G/L Account");
                PurchaseInvoiceLine.SetLoadFields("Order No.", "Order Line No.", "Document No.");
                if not PurchaseInvoiceLine.isempty() then begin
                    if ContainerReceiveidNotInvoiced_gRec.Get(purchaseLine_lRec."trm Container No.") then begin
                        ContainerReceiveidNotInvoiced_gRec.mark(true);
                    end;
                end;
            until purchaseLine_lRec.next() = 0;
        ContainerReceiveidNotInvoiced_gRec.MarkedOnly(true);
    end;

    var
        UserSetup: Record "User Setup";
        RoleCenterSetup: Record "trm Role Center Setup";
        TestDateFormula: DateFormula;
        LocationMissing_gLbl: Label 'Warning: You have to set %1 in %2 to calculate the cues correctly.';
        ContainerReceiveidNotInvoiced_gRec: Record "trm Container";

        cu80: codeunit 80;
}