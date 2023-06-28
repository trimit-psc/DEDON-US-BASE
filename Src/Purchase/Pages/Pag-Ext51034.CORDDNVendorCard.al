pageextension 51034 "COR-DDN Vendor Card" extends "Vendor Card"
{
    layout
    {
        addafter("Lead Time Calculation")
        {
            /// <summary>
            /// <see cref="#7JRN"/>
            /// </summary>
            field("COR-DDN Tranist Periode"; Rec."COR-DDN Transit Periode")
            {
                ApplicationArea = All;
                ToolTip = 'Time from putting goods into a container and receipt at DEDON Stock';
            }
        }
        addlast(Receiving)
        {

            /// <summary>
            /// <see cref="#M9LS"/>
            /// </summary>
            field("COR-DDN auto create Whse. Receipt"; Rec."COR-DDN auto create Whse. Receipt")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Automatic Creation of Warehouse Receipts field.';
            }
        }
    }
}
