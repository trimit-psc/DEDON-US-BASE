/// <summary>
/// PageExtension DDN Master List (ID 51001) extends Record trm Master List.
/// </summary>
pageextension 51001 "DDN Master List" extends "trm Master List"
{
    layout
    {
        addlast(Control6036558)
        {
            /// <summary>
            /// <see cref="#V7ZN"/>
            /// </summary>
            field("DDN Included in Catalog"; Rec."DDN Included in Catalog")
            {
                ApplicationArea = All;
                DrillDown = true;

                trigger OnDrillDown()
                var
                    Collection: Record "trm Collection";
                begin
                    OpenCollectonOrCatalog_gFnc(Collection."DDN Classification"::Catalog)
                end;



            }
            /// <summary>
            /// <see cref="#V7ZN"/>
            /// </summary>
            field("DDN Included in Colelction"; Rec."DDN Included in Collection")
            {
                ApplicationArea = All;

                trigger OnDrillDown()
                var
                    Collection: Record "trm Collection";
                begin
                    OpenCollectonOrCatalog_gFnc(Collection."DDN Classification"::Collection)
                end;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    /// <summary>
    /// <see cref="#V7ZN"/>
    /// </summary>
    /// <param name="whatToOpen_iOpt">Kollektion oder Katalog</param>
    local procedure OpenCollectonOrCatalog_gFnc(whatToOpen_iOpt: Option Collection,Catalog)
    var
        Collection_lRec: Record "trm Collection";
        CollectionMasterRelation_lRec: Record "trm Collection Master Relation";

    begin
        CollectionMasterRelation_lRec.SetRange("No.", Rec."No.");
        CollectionMasterRelation_lRec.Setrange("DDN Collection Classification", whatToOpen_iOpt);
        if CollectionMasterRelation_lRec.findset() then
            repeat
                Collection_lRec.get(CollectionMasterRelation_lRec."Collection No.");
                Collection_lRec.mark(true);
            until CollectionMasterRelation_lRec.next() = 0;
        Collection_lRec.MarkedOnly(true);
        case Collection_lRec.count of
            1:
                Page.run(Page::"trm Collection Card", Collection_lRec);
            0:
                ;
            else
                Page.run(Page::"trm Collection List", Collection_lRec);
        end

    end;

}