pageextension 51019 "Posted Purchase Receipt (DDN)" extends "Posted Purchase Receipt" //136
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