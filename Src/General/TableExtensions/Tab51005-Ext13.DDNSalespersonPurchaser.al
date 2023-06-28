tableextension 51005 "DDN Salesperson/Purchaser" extends "Salesperson/Purchaser"
{
    fields
    {
        /// <summary>
        /// Bestimmt, ob ein verkäufer ein Verkäufer ist oder ein Designer eines Produkts
        /// <see cref="#V7ZN"/>
        /// </summary>
        field(51000; "DDN Vendor Classification"; Option)
        {
            OptionMembers = SalesPerson,Designer;
            OptionCaption = 'Sales Person,Designer';
            Caption = 'Salesperson/Venor Classification';
        }
    }
}