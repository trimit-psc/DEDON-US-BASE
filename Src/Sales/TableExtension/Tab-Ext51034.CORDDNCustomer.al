tableextension 51034 "COR-DDN Customer" extends Customer
{
    fields
    {
        /// <summary>
        /// <see cref="#U29F"/>
        /// </summary>
        field(51000; "COR-DDN Respons. Person Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Salesperson/Purchaser";
            Caption = 'Responsible Person Code';
            ObsoleteState = Pending;
            ObsoleteReason = 'moved to COR-DDN Respons. Person Code 2 because of conflict to table 5050 "contact"';
        }

        field(51001; "COR-DDN Pipedrive Org. ID"; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'Pipedrive Organisation ID';
        }
        /// Platzhalter für Pipedrive-Id auf Kontaktebene
        /*
        field(51002; "COR-DDN Pipedrive Org. ID"; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'Pipedrive Organisation ID';
        } 
        */

        /// <summary>
        /// Zuständiger Sachbearbeiter auf Kontakt-Ebene
        /// Verschoben von Feld 51000 nach 51003 damit Kontakt und Debitor synchron bzgl. ihrer Feldnummern sind
        /// </summary>
        /// <see cref="https://dedongroup.atlassian.net/browse/DEDT-562"/>
        field(51003; "COR-DDN Respons. Person Code 2"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Salesperson/Purchaser";
            Caption = 'Responsible Person Code';

            trigger OnValidate()
            var
                ContBusRel_lRec: Record "Contact Business Relation";
                Contact_lRec: Record Contact;
            begin
                ContBusRel_lRec.SetRange("Link to Table", ContBusRel_lRec."Link to Table"::Customer);
                ContBusRel_lRec.setrange("No.", Rec."No.");
                if ContBusRel_lRec.findset then
                    repeat
                        Contact_lRec.setrange(Type, Contact_lRec.type::Company);
                        Contact_lRec.setrange("No.", ContBusRel_lRec."Contact No.");
                        if Contact_lRec.FindFirst() then begin
                            Contact_lRec.validate("COR-DDN Respons. Person Code 2", Rec."COR-DDN Respons. Person Code 2");
                            Contact_lRec.modify();
                        end
                    until ContBusRel_lRec.Next() = 0;
            end;
        }
    }
}
