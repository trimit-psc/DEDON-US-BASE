tableextension 51031 "DDN G/L Entry" extends "G/L Entry"
{
    fields
    {
        /// <summary>
        /// Konten mit Flag "Confidential" berücksichtigen
        /// <see cref="#Q2U8"/>
        /// </summary>
        field(51000; "DDN Account confidential"; Boolean)
        {
            Caption = 'G/L Account is confidential';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("G/L Account".Confidential where("No." = field("G/L Account No.")));
        }
    }
}
