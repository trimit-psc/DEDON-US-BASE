/// <summary>
/// Aptean Workflow Kacheln ergänzen
/// <see cref="#KRK2"/>
/// </summary>
pageextension 51040 "COR-DDN Cust Service Role Cent" extends "trm Cust Service Role Center"
{
    layout
    {
        addafter(Control6036525)
        {
            // TODO ReactivateApteanCode reactivate part below
            // part("Aptean Workflow"; "aWF - To-do Activities")
            // {
            //     ApplicationArea = Basic, Suite;
            // }
        }

    }
}
