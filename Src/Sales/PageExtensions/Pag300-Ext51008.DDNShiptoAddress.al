/// <summary>
/// Buchungsgruppe via Lieferadresse bestimmen
/// <see cref="#CTDG"/>
/// </summary>
pageextension 51008 "DDN Ship-to Address" extends "Ship-to Address"
{
    layout
    {
        addafter(Name)
        {
            field("Name 2"; Rec."Name 2")
            {
                ApplicationArea = All;
            }
        }
        addLast(content)
        {
            group(DDNFaktura)
            {
                Caption = 'Invoice';

                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = All;
                }

            }
        }
    }
}
