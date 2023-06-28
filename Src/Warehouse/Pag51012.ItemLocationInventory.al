// page copied from NAV2018 an changed slightly for BC
/// <summary>
/// <see cref="#TW84"/>
/// </summary>     
page 51012 "Item Location Inventory"
{
    Caption = 'Item Location Inventory';
    Editable = false;
    PageType = List;
    SourceTable = "Item Ledger Entry";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
                field("Lot No."; Rec."Lot No.")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field("Remaining Quantity"; Rec."Remaining Quantity")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    procedure SetSelection(VAR itemLedgerEntry_p: Record "Item Ledger Entry")
    begin
        itemLedgerEntry_p.RESET;
        IF NOT itemLedgerEntry_p.FINDSET THEN
            EXIT;

        REPEAT
            Rec.INIT;
            Rec := itemLedgerEntry_p;
            Rec.INSERT;
        UNTIL itemLedgerEntry_p.NEXT = 0;
    end;

    procedure GetSelection(VAR itemLedgerEntry_out: Record "Item Ledger Entry")
    begin
        CurrPage.SETSELECTIONFILTER(itemLedgerEntry_out);
    end;
}