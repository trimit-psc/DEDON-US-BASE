pageextension 51031 "COR-DDN Customer Card" extends "Customer Card"
{
    layout
    {
        /// <summary>
        /// <see cref="#U29F"/>
        /// </summary>
        addafter("trm Salesperson 3")
        {
            field("COR-DDN Respons. Person Code"; Rec."COR-DDN Respons. Person Code 2")
            {
                ApplicationArea = All;
            }
        }
    }
}
