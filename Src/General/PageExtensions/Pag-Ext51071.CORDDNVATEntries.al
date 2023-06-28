/// <summary>
/// 
/// </summary>
pageextension 51071 "COR-DDN VAT Entries" extends "VAT Entries"
{
    layout
    {
        addlast(Control1)
        {

            /// <summary>
            /// 
            /// </summary>
            /// <see cref="https://dedongroup.atlassian.net/browse/DEDT-572"/>
            field("G/L Acc. No."; Rec."G/L Acc. No.")
            {
                ApplicationArea = All;
            }
        }
    }
}
