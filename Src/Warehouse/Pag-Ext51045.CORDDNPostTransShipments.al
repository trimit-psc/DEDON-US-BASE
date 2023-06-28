pageextension 51045 "COR-DDN Post. Trans. Shipments" extends "Posted Transfer Shipments"
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
