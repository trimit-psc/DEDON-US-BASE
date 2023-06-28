tableextension 51019 "DDN User Setup" extends "User Setup"
{
    fields
    {
        /// <summary>
        /// Festlegen, wer gesperrte Konten sehen darf
        /// <see cref="#Q2U8"/>
        /// </summary>
        field(51000; "Access confidential G/L Accout"; Boolean)
        {
            Caption = 'Allow Access to confidential G/L Accout';
            DataClassification = ToBeClassified;
        }
    }
}
