pageextension 51042 "COR-DDN Warehouse Receipt" extends "Warehouse Receipt"
{
    actions
    {
        addlast(processing)
        {
            action("COR-DDN JH releaseDoc")
            {
                ApplicationArea = Warehouse;
                Caption = 'Re&lease';
                Image = ReleaseDoc;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ShortCutKey = 'Ctrl+F9';

                trigger OnAction()
                begin
                    // TODO ReactivateJungheinrichCode 1 Line                                
                    Rec.Validate("Status JH", Rec."Status JH"::"Released to WMS");
                end;
            }
        }
    }
}
