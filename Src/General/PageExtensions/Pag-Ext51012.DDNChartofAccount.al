/// <summary>
/// Konten als "confidential" klassifizieren
/// <see cref="#Q2U8"/>
/// </summary>
pageextension 51012 "DDN Chart of Account" extends "Chart of Accounts"
{
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
