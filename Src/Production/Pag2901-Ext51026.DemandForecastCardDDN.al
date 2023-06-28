pageextension 51026 "Demand Forecast Card (DDN)" extends "Demand Forecast Card" //2901
{
    actions
    {
        addlast("F&unctions")
        {
            /// <summary>
            /// <see cref="#FV2D"/>
            /// </summary>
            action(ImportFromExcel)
            {
                Caption = 'Import from Excel';
                Image = ImportExcel;
                ApplicationArea = All;

                trigger OnAction()
                var
                    ForecastImport_lCdu: Codeunit "DDN Forecast Import";
                begin
                    ForecastImport_lCdu.Run(Rec);
                end;
            }
        }
    }
}