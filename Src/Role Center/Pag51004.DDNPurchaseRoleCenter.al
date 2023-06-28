/// <summary>
/// Page DDN Purchase Role Center (ID 51004).
/// <see cref="#13JD"/>
/// </summary>
page 51004 "DDN Purchase Role Center"
{
    Caption = 'DDN Purchase Role Center';
    PageType = RoleCenter;

    layout
    {
        area(RoleCenter)
        {
            part(Control6036525; "trm Headline Role Center")
            {
                ApplicationArea = Basic, Suite;
            }
            part("DDN Purchase Activities"; "DDN Purchase Activities")
            {
                ApplicationArea = All;
            }
            part(Control6036512; "trm My Actions")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }

    actions
    {
        area(Creation)
        {
            action(NewSalesOrder)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'New Purchase Order';
                Image = NewOrder;
                RunObject = Page "Purchase Order";
                RunPageMode = Create;
            }
            action(NewPurchaseInvoice)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'New Purchase Invoice';
                Image = NewOrder;
                RunObject = Page "Purchase Invoice";
                RunPageMode = Create;
            }
            action(NewContainer)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'New Container';
                Image = NewOrder;
                RunObject = Page "trm Container Card";
                RunPageMode = Create;
            }
            action(NewTransferOrder)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'New Transfer Order';
                Image = NewOrder;
                RunObject = Page "Transfer Order";
                RunPageMode = Create;
            }
        }
    }
}