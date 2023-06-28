// query copied from NAV2018 an changed slightly for BC
/// <summary>
/// <see cref="#TW84"/>
/// </summary>     
query 51000 "Item Inventory"
{
    QueryType = Normal;
    Caption = 'Item Inventory';

    elements
    {
        dataitem(Item_Ledger_Entry; "Item Ledger Entry")
        {
            column(Item_No; "Item No.")
            {
            }
            column(Variant_Code; "Variant Code")
            {
            }
            column(Location_Code; "Location Code")
            {
            }
            column(Lot_No; "Lot No.")
            {
            }
            column(Serial_No; "Serial No.")
            {
            }
            column(Sum_Remaining_Quantity; "Remaining Quantity")
            {
                Method = Sum;
            }
        }
    }
}