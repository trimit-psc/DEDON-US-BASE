/// <summary>
/// PageExtension DDN Collection Card (ID 51003) extends Record trm Collection Card.
/// </summary>
pageextension 51003 "DDN Collection Card" extends "trm Collection Card"
{
    layout
    {
        addafter(General)
        {
            group(DEDON)
            {
                Caption = 'DEDON';
                /// <summary>
                /// <see cref="#V7ZN"/>
                /// </summary>
                field("DDN Classification"; Rec."DDN Classification")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}