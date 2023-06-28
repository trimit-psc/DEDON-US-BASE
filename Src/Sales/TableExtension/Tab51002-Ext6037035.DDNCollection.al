tableextension 51002 "DDN Collection" extends "trm Collection"
{
    fields
    {
        /// <summary>
        /// Klassifiziert ene Kollektion um später Abfragen der Form, "welche Kollektionen sind in welchem Katalog gelistet?" generieren zu können
        /// Anforderung [B-037]:
        /// </summary>
        field(51000; "DDN Classification"; Option)
        {
            Caption = 'Classification';
            OptionMembers = Collection,Catalog;
            OptionCaption = 'Collection,Catalog';
            DataClassification = ToBeClassified;
        }
    }

}