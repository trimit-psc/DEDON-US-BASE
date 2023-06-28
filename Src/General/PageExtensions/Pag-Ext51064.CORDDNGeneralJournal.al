pageextension 51064 "COR-DDN General Journal" extends "General Journal"
{
    layout
    {
        addafter("trm Payment Discount Amount")
        {

            field("Pmt. Discount Date"; Rec."Pmt. Discount Date")
            {
                ApplicationArea = All;
            }
        }
    }
}
