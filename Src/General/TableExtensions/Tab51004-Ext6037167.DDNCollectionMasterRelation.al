/// <summary>
/// TableExtension DDN Collection Master Relation (ID 51004) extends Record trm Collection Master Relation.
/// </summary>
tableextension 51004 "DDN Collection Master Relation" extends "trm Collection Master Relation"
{
    fields
    {
        /// <summary>
        /// Bestimmt, ob es sich bei der Kollektion im Sinne von Trimit um eine Kollektion oder einen Katalog im
        /// Sinne von DEDON handelt. Das Kennzeichen wird für FlowFilter auf <c>trm Master</c> genutzt
        /// <see cref="#V7ZN"/>
        /// </summary>
        field(51001; "DDN Collection Classification"; Option)
        {
            OptionMembers = Collection,Catalog;
            OptionCaption = 'Collection,Catalog';
            Caption = 'Classification';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup("trm collection"."DDN Classification" where("Collection No." = field("Collection No.")));
        }
    }
}