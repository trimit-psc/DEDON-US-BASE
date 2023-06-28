pageextension 51039 "COR-DDN Purch. Invoice Subform" extends "Purch. Invoice Subform" //55
{
    layout
    {

        modify("Gen. Bus. Posting Group")
        {
            ApplicationArea = All;
            Style = Strong;
            StyleExpr = Rec."trm Show Bold";
        }


        addafter("No.")
        {
            /// <summary>
            /// <see cref="#1Z54"/>
            /// </summary>     
            field("Item No. 2"; Rec."Item No. 2")
            {
                ApplicationArea = All;
                Visible = false;
            }

            /// <summary>
            /// <see cref="#1Z54"/>
            /// </summary>                 
            field("Item Search Description"; Rec."Item Search Description")
            {
                ApplicationArea = All;
                Width = 50;
            }
            field("COR-DDN Legacy System Item No."; Rec."COR-DDN Legacy System Item No.")
            {
                ApplicationArea = All;
            }


            /// <summary>
            /// <see cref="#V5MQ"/>
            /// </summary>    
            field("DDN Item Planning Status Code"; Rec."DDN Item Planning Status Code")
            {
                ApplicationArea = All;
            }
            field("COR-DDNtrm Container No."; Rec."trm Container No.")
            {
                ApplicationArea = All;
            }

        }
        /// DEDT-531
        modify("VAT Prod. Posting Group")
        {
            Visible = true;
        }
    }
}