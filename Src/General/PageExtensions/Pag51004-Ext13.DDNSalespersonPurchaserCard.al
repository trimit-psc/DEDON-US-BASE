/// <summary>
/// PageExtension DDN Salesperson/Purchaser Card (ID 51004) extends Record Salesperson/Purchaser Card.
/// </summary>
pageextension 51004 "DDN Salesperson/Purchaser Card" extends "Salesperson/Purchaser Card"
{
    layout
    {
        addlast(content)
        {
            group(DEDON)
            {
                Caption = 'DEDON';
                /// <summary>
                /// Designer auf Basis des Masters verwalten
                /// Anforderung [B-066]
                /// <see cref="#W3MP"/>
                /// </summary>
                field("DDN Vendor Classification"; Rec."DDN Vendor Classification")
                {
                    ApplicationArea = All;
                    ToolTip = 'Salesperson/Venor Classification';
                }
            }
        }
    }
}