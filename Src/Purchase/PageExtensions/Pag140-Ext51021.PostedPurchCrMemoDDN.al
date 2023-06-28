pageextension 51021 "Posted Purch. Cr. Memo (DDN)" extends "Posted Purchase Credit Memo" //140
{
    layout
    {
        addlast(General)
        {
            /// <summary>
            /// <see cref="#VCWD"/>
            /// </summary>     
            field(Commission; Rec.Commission)
            {
                ApplicationArea = All;
            }
        }
    }
}