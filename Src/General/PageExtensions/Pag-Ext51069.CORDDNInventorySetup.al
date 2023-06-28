pageextension 51069 "COR-DDN Inventory Setup" extends "Inventory Setup"
{
    layout
    {
        addfirst(trmVarDim)
        {
            /// <summary>
            /// Beim Buchen des VK-Auftrags wird der FA automatisch gebucht.
            /// Der Schalter um das abzuschalten ist auf de rPage nicht erreichbar.
            /// </summary>
            /// <see cref="https://dedongroup.atlassian.net/browse/DEDT-541"/>
            field("COR-DDN trm Time for RelatOrd Posting"; Rec."trm Time for RelatOrd Posting")
            {
                ApplicationArea = All;
            }
        }
    }
}
