/// <summary>
/// <see cref="#LZ4G"/>
/// </summary>
pageextension 51023 "DDN Sales Line Disc Type Card" extends "trm Sales Line Disc Type Card"
{
    layout
    {
        addLast(content)
        {
            group(Dedon)
            {
                Caption = 'DEDON';
                field("DDN Discount Distrib. Filter"; Rec."DDN Discount Distrib. Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specify, which Saleslines should be impacted if a discount is either inserted or updated.';
                }
            }
        }
    }
}
