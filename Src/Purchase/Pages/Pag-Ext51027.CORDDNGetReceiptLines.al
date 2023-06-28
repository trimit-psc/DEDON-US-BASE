/// <summary>
/// <see cref="AT4L"/>
/// </summary>
pageextension 51027 "COR-DDN Get Receipt Lines" extends "Get Receipt Lines"
{
    layout
    {
        addafter("Document No.")
        {
            field("COR-DDN trm Container No."; Rec."trm Container No.")
            {
                ApplicationArea = All;
            }
            field("COR-DDN Location Code"; Rec."Location Code")
            {
                ApplicationArea = All;
            }
        }
        addafter("No.")
        {
            field("COR-DDN Legacy System Item No."; Rec."COR-DDN Legacy System Item No.")
            {
                ApplicationArea = All;
            }
        }
        addafter(OrderNo)
        {
            /// <summary>
            /// verwendet zum filtern
            /// </summary>
            field("COR-DDN Order No."; Rec."Order No.")
            {
                ApplicationArea = All;
                ToolTip = 'Purchase Order No. accoring to the reception header.';
            }
        }
        modify(OrderNo)
        {
            Visible = false;
        }
    }
}
