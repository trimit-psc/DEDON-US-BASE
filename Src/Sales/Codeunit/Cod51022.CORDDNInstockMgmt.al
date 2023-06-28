/// <summary>
/// <see cref="#G3L9"/>
/// </summary>
codeunit 51022 "COR-DDN Instock Delegator"
{
    procedure CalcInstockAvailibilityHint(ItemNo: Code[20]; forecRecalculation_iBool: boolean) ret: text
    var
        item: Record Item;
        balance: Decimal;
        ddnSetup: Record "DDN Setup";
        InstockQty_lDec: Decimal;
        InstockDataAvailable_lBool: Boolean;
    begin
        OnRequestInstockQty(ItemNo, InstockQty_lDec, InstockDataAvailable_lBool, forecRecalculation_iBool, forecRecalculation_iBool);

        if not InstockDataAvailable_lBool then begin
            ret := '';
        end
        else begin
            if InstockQty_lDec > 0 then begin
                ret := '✔ ' + format(InstockQty_lDec, 0, '<Precision,0:2><Standard Format,0>');
            end
            else begin
                ret := '✖';
            end;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRequestInstockQty(ItemNo_iCode: Code[20]; var InstockQty_vDec: Decimal; var InstockDataAvailable_vBool: boolean; forceCreateBom: Boolean; forceCalculateInventoryAndAvailibility: Boolean)
    begin
    end;
}
