pageextension 51014 "DDN General Ledger Entries" extends "General Ledger Entries"
{
    layout
    {
        modify("Additional-Currency Amount")
        {
            Visible = true;
        }

        modify("VAT Bus. Posting Group")
        {
            Visible = true;
        }
        modify("VAT Prod. Posting Group")
        {
            Visible = true;
        }

    }

    /// <summary>
    /// Konten mit Flag "Confidential" ggf. ausblenden
    /// <see cref="#Q2U8"/>
    /// </summary>
    trigger OnOpenPage()
    var
        AccountMgmt_lCu: Codeunit "DDN Account Management";
    begin
        AccountMgmt_lCu.ApplyConfidentialFilter(Rec);
    end;
}
