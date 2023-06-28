report 51002 "COR-DDN Container History"
{
    Caption = 'COR-DDN Container History';
    ExcelLayout = 'Src/Purchase/Reports/Rep51002.CORDDNContainerHistory.xlsx';
    DefaultLayout = Excel;
    dataset
    {
        dataitem(ContainerHistoryHeader; "COR-DDN Container Hist. Header")
        {
            dataitem(ContainerHistoryLine; "COR-DDN Container Hist. Line")
            {
                DataItemLink = "Container History Id" = field("Id");
                DataItemLinkReference = ContainerHistoryHeader;
                DataItemTableView = sorting("Container History Id", "Document Type", "Document No.", "Line No.");

                column(CreatedAtDate; ContainerHistoryHeader."crated at date")
                {
                }
                column(CreatedAtTime; ContainerHistoryHeader."crated at time")
                {
                }
                column(AmountLCY; "Amount (LCY)")
                {
                    IncludeCaption = true;
                }

                column(ContainerHistoryId; "Container History Id")
                {
                }
                column(ContainerID; "Container ID")
                {
                }
                column(ContainerNo; "Container No.")
                {
                }
                column(DocumentNo; "Document No.")
                {
                }
                column(DocumentType; "Document Type")
                {
                }
                column(Estimatedtimeofarrival; "Estimated time of arrival")
                {
                }
                column(Estimatedtimeofdeparture; "Estimated time of departure")
                {
                }
                column(GenProductPostingGroup; "Gen. Product Posting Group")
                {
                }
                column(ItemDescription; "Item Description")
                {
                }
                column(ItemDescription2; "Item Description 2")
                {
                }
                column(ItemNo; "Item No.")
                {
                }
                column(LineNo; "Line No.")
                {
                }
                column(MasterNo; "Master No.")
                {
                }
                column(Quantity; Quantity)
                {
                }
                column(QuantityBase; "Quantity (Base)")
                {
                }
                column(ShipmentMethod; "Shipment Method")
                {
                }
                column(Status; Status)
                {
                }
                column(SystemCreatedAt; SystemCreatedAt)
                {
                }
                column(SystemCreatedBy; SystemCreatedBy)
                {
                }
                column(SystemId; SystemId)
                {
                }
                column(SystemModifiedAt; SystemModifiedAt)
                {
                }
                column(SystemModifiedBy; SystemModifiedBy)
                {
                }
                column(VATProductPostingGroup; "VAT Product Posting Group")
                {
                }
                column(VendorNo; "Vendor No.")
                {
                }
                column(VendorPostingGroup; "Vendor Posting Group")
                {
                }

            }
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                }
            }
        }
        actions
        {
            area(processing)
            {
            }
        }
    }
}
