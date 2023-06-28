codeunit 51023 "COR-DDN Warehouse Trigger"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"transferOrder-Post Shipment", 'OnAfterTransferOrderPostShipment', '', false, false)]
    local procedure WarehouseTransferReleaseOnAfterTransferOrderPostShipment(var TransferHeader: Record "Transfer Header"; CommitIsSuppressed: Boolean; var TransferShipmentHeader: Record "Transfer Shipment Header"; InvtPickPutaway: Boolean)
    begin
        //TransferShipmentHeader."COR-DDN Comment" := TransferHeader.coe
    end;

}
