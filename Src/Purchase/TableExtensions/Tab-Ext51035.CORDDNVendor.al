tableextension 51035 "COR-DDN Vendor" extends Vendor
{
    fields
    {
        /// <summary>
        /// <see cref="#7JRN"/>
        /// </summary>
        field(51000; "COR-DDN Transit Periode"; DateFormula)
        {
            Caption = 'Transit Periode';

        }

        field(51001; "COR-DDN auto create Whse. Receipt"; Option)
        {
            Caption = 'Automatic Creation of Warehouse Receipts';
            DataClassification = ToBeClassified;
            OptionMembers = "do nothing","create Receipt","create Receipt + release JH";
            OptionCaption = 'nichts tun,Wareneingang erzeugen,Wareneingang erzeugen + Freigabe Jungheinrich';
        }
        /*
        field(51002; "COR-DDN Pipedrive Org. ID"; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'Pipedrive Organisation ID';
        } 
        */

    }
}
