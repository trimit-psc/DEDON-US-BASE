pageextension 51022 "Purchase Order Archive (DDN)" extends "Purchase Order Archive" //5167
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