/// <summary>
/// <see cref="#Q84K"/>
/// </summary>
table 51004 "COR-DDN Container Hist. Header"
{
    Caption = 'COR-DDN Container History Header';
    DataClassification = ToBeClassified;
    LookupPageId = "COR-DDN Container History List";
    DrillDownPageId = "COR-DDN Container Hist. Entr.";

    fields
    {
        field(1; id; Integer)
        {
            Caption = 'Container History id';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(2; "crated at date"; date)
        {
            Caption = 'created at date';
            Editable = false;
        }
        field(3; Description; text[50])
        {
            Caption = 'Description';
            Editable = false;
        }
        field(4; "Amount (LCY)"; Decimal)
        {
            Editable = false;
            Caption = 'Amount (LCY)';
            FieldClass = FlowField;
            CalcFormula = sum("COR-DDN Container Hist. Line"."Amount (LCY)" where("Container History Id" = field(id)));
        }
        field(5; "crated at time"; time)
        {
            Caption = 'created at time';
            Editable = false;
        }
    }
    keys
    {
        key(PK; id)
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        lastRec_lRec: Record "COR-DDN Container Hist. Header";
    begin
        if not lastRec_lRec.FindLast() then
            id := 1
        else
            id := lastRec_lRec.id + 1;
        Rec."crated at date" := today();
        Rec."crated at time" := Time();
        if GuiAllowed then begin
            Description := 'Berechnung durch Benutzer ausgelöst';
        end
        else begin
            Description := 'durch Lauf automatisch berechnet';
        end;
    end;

    trigger OnDelete()
    var
        Line_lRec: record "COR-DDN Container Hist. Line";
    begin
        Line_lRec.SetRange("Container History Id", Rec.id);
        Line_lRec.DeleteAll(true);
    end;
}
