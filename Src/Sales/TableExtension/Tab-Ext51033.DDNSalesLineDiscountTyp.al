/// <summary>
/// <see cref="#LZ4G"/>
/// </summary>
tableextension 51033 "DDN Sales Line Discount Typ" extends "trm Sales Line Discount Type"
{
    fields
    {
        /// <summary>
        /// <see cref="#LZ4G"/>
        /// </summary>
        field(51000; "DDN Discount Distrib. Filter"; Option)
        {
            Caption = 'Discount Distribution Filter';
            DataClassification = ToBeClassified;
            OptionMembers = " ","All Item Lines","Master No.","Item No.","Set Master No.";
            OptionCaption = ' ,All Item Lines,Master No.,Item No.,Set Master No.';

        }
    }
}
