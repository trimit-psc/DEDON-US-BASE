tableextension 51042 "COR-DDN Contact" extends Contact
{
    fields
    {
        field(51000; "COR-DDN Pipedrive Org. ID"; Integer)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Conflict with vendor table';
            DataClassification = ToBeClassified;
            Caption = 'Pipedrive Organisation ID';
        }

        field(51002; "COR-DDN Pipedrive Org. ID 2"; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'Pipedrive Organisation ID';
        }
        /// <summary>
        /// Zuständiger Sachbearbeiter auf Kontakt-Ebene
        /// </summary>
        /// <see cref="https://dedongroup.atlassian.net/browse/DEDT-562"/>
        field(51003; "COR-DDN Respons. Person Code 2"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Salesperson/Purchaser";
            Caption = 'Responsible Person Code';


            trigger OnValidate()
            var
                PersonContact_lRec: Record Contact;
                DivergentRespnsiblePersonsForund_lLbl: Label 'There are persons in the company %1 for whom someone else than %2 was responsible. Do you want to assign %3 to those persons anyway?';
            begin
                if Rec.type <> rec.type::Company then
                    exit;
                PersonContact_lRec.setrange(Type, PersonContact_lRec.Type::Person);
                PersonContact_lRec.setrange("Company No.", Rec."No.");
                PersonContact_lRec.setfilter("COR-DDN Respons. Person Code 2", '<>''''');
                // falls es keinen einzigen Kontakt mit nicht leerem Sachbearbeiter gibt dann kann einfach überschrieben werden
                if PersonContact_lRec.isempty then begin
                    PersonContact_lRec.setrange("COR-DDN Respons. Person Code 2");
                    PersonContact_lRec.ModifyAll("COR-DDN Respons. Person Code 2", Rec."COR-DDN Respons. Person Code 2");
                end
                // es gibt Kontakt emit einem Sachbearbeiter
                else begin
                    // falls alle Sachbearbeiter gleich dem der Company sind darf ohne Rückfrage geändert werden
                    PersonContact_lRec.setfilter("COR-DDN Respons. Person Code 2", '<>''''&<>%1', xRec."COR-DDN Respons. Person Code 2");
                    if PersonContact_lRec.isempty then begin
                        PersonContact_lRec.setrange("COR-DDN Respons. Person Code 2");
                        PersonContact_lRec.ModifyAll("COR-DDN Respons. Person Code 2", Rec."COR-DDN Respons. Person Code 2");
                    end
                    else begin
                        if confirm(DivergentRespnsiblePersonsForund_lLbl, false, Rec.Name, xRec."COR-DDN Respons. Person Code 2", Rec."COR-DDN Respons. Person Code 2") then begin
                            PersonContact_lRec.setrange("COR-DDN Respons. Person Code 2");
                        end;
                        PersonContact_lRec.ModifyAll("COR-DDN Respons. Person Code 2", Rec."COR-DDN Respons. Person Code 2");
                    end;

                end;


            end;
        }
    }
}
