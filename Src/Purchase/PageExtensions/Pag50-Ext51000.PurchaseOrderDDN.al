pageextension 51000 "Purchase Order (DDN)" extends "Purchase Order" //50
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