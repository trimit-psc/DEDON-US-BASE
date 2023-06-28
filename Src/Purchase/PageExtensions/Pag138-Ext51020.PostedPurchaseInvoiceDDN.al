pageextension 51020 "Posted Purchase Invoice (DDN)" extends "Posted Purchase Invoice" //138
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