pageextension 51010 "DDN G/L Account List" extends "G/L Account List"
{
    /// <summary>
    /// Konten mit Flag "Confidential" ggf. ausblenden
    /// 
    /// </summary>
    trigger OnOpenPage()
    var
        AccountMgmt_lCu: Codeunit "DDN Account Management";
    begin
        AccountMgmt_lCu.ApplyConfidentialFilter(Rec);
    end;
}
