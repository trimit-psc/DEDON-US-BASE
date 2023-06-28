pageextension 51046 "COR-DDN Post. Transf. Receipts" extends "Posted Transfer Receipts"
{
    layout
    {
        addafter("No.")
        {
            field("Transfer Order No."; Rec."Transfer Order No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the number of the related transfer order.';
            }
        }
    }
}
