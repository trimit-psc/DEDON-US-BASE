page 51014 "COR DSDS SalesLines Prio"
{
    Caption = 'COR DSDS SalesLines Prio';
    PageType = ListPart;
    SourceTable = "Sales Line";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the document number.';
                }
                field("Shipment Date"; Rec."Shipment Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when items on the document are shipped or were shipped. A shipment date is usually calculated from a requested delivery date plus lead time.';
                }

                // TODO ReactivateJungheinrichCode two fields below
                field("Outstanding Qty. (Base)"; Rec."Outstanding Qty. (Base)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the outstanding quantity expressed in the base units of measure.';
                }
                field("Assigned Inventory (Base) JH"; Rec."Assigned Inventory (Base) JH")
                {
                    ApplicationArea = All;
                    ToolTip = 'Assigned Inventory (Base)';
                    DecimalPlaces = 0 : 2;
                    BlankZero = true;
                }
            }
        }
    }

    procedure setSourceTable(var priorityQueueSalesLine_iRec: Record "Sales Line" temporary)
    var
        myInt: Integer;
    begin
        if not Rec.IsTemporary then
            error('iternal error becaus Sales Line is not temporary on Page 51014.');
        Rec.DeleteAll();

        if priorityQueueSalesLine_iRec.FindSet() then
            repeat
                Rec := priorityQueueSalesLine_iRec;
                Rec.Insert();

            until priorityQueueSalesLine_iRec.next = 0;
    end;
}
