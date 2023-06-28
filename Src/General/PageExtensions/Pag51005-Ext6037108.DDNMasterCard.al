/// <summary>
/// PageExtension DDN Master Card (ID 51005) extends Record trm Master Card.
/// </summary>
pageextension 51005 "DDN Master Card" extends "trm Master Card"
{
    layout
    {
        addafter("Tariff No.")
        {
            /// <summary>
            /// <see cref="#6M4D"/>
            /// </summary>
            field("DDN US Tariff No."; Rec."DDN US Tariff No.")
            {
                ApplicationArea = All;
                ToolTip = 'Used for US customs. The field is not used for customs declaration within BC Standard in any way.';
            }
        }
        addlast(content)
        {
            group(DEDON)
            {
                Caption = 'DEDON';
                /// <summary>
                /// Designer auf Basis des Masters verwalten
                /// <see cref="#W3MP"/>
                /// </summary>
                field("DDN Designer Code"; Rec."DDN Designer Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Enter the designer who get''s royaliteis for the Master. The designer is transferd to the sales line to calculate commission based on TRIMIT logics.';
                    // Hier ist der Designer zu hinterlegen, der für den Vekrauf dieses Masters vergütet wird. Der Designer wird in die Auftragszeile übernommen und erhält im Nachgang über die Provisionsabrechnung Gelder.
                }

                /// <summary>
                /// Automatische Auflösung der Stücklist eim Verkauf ermöglichen
                /// <see cref="#DM4X"/>
                /// </summary>
                field("DDN Auto Explode BOM"; Rec."DDN Auto Explode BOM")
                {
                    ApplicationArea = All;
                    ToolTip = 'Expand the bom automatically in sales line';
                }
                /// <summary>
                /// <see cref="#DM4X"/>
                /// </summary>
                field("DDN enable Bom Creation for BI"; Rec."DDN enable Bom Creation for BI")
                {
                    ApplicationArea = All;
                    ToolTip = 'As soon as this switch is set the bill of material within a sales line expands immediately after entering a quantity. The Item No. and the MAster No. is transfered from the furniture to the componentes, couchons and other accessorie. Both numbers are important for the BI-Team. Take care of possible recusrions. This switch must be set on the item that initiated the bom explosion. This can be the Config-ITem or even the furniture item itself.';
                }

                /// <summary>
                /// <see cref="#1QA2"/>
                /// </summary>
                field("DDN Fabric Consumption"; Rec."DDN Fabric Consumption")
                {
                    ApplicationArea = All;
                }

            }
        }
    }
    actions
    {
        addafter(ItemList)
        {
            action(deleteRelatedItems)
            {
                ApplicationArea = All;
                Caption = 'delete related items';
                image = Delete;

                trigger OnAction()
                begin
                    Rec.deleteRelatedItems();
                end;
            }
        }
        addlast(MatrixGroup)
        {
            action(CorDdnRepairMatrixCell)
            {
                ApplicationArea = All;
                Caption = 'Repair Matrix Cell';
                ToolTip = 'Assignes a item no to matrix cells where no item no. has been assigney yet.';
                image = SuggestNumber;

                trigger OnAction()
                begin
                    Rec.repairMatrixCell();
                end;
            }
        }
    }
}