table 51002 "DDN Cue"
{
    Caption = 'DDN Cue';

    fields
    {
        /// <summary>
        /// Primary Key
        /// </summary>
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        /// <summary>
        /// <see cref="#MNVF"/>
        /// </summary>
        field(10; "Purch. Lines Late (Main Loc.)"; Integer)
        {
            Caption = 'Purch. Lines Late (Main Loc.)';
            FieldClass = FlowField;
            CalcFormula = count("Purchase Line" where("Document Type" = const(Order), Type = const(Item), "Location Code" = field("Location Filter Main"), "Expected Receipt Date" = field("Date Filter Late"), "Outstanding Qty. (Base)" = filter(> 0)));
            Editable = false;
        }
        /// <summary>
        /// <see cref="#MNVF"/>
        /// </summary>
        field(11; "Purch. Lines Delayed (Winsen)"; Integer)
        {
            Caption = 'Purch. Lines Delayed (Winsen)';
            FieldClass = FlowField;
            CalcFormula = count("Purchase Line" where("Document Type" = const(Order), Type = const(Item), "Location Code" = field("Location Filter Winsen"), "DDN Estimated Date Ready" = field("Date Filter Late"), "Outstanding Qty. (Base)" = filter(> 0), "trm Container No." = field("Container No. Filter")));
            Editable = false;
        }
        /// <summary>
        /// <see cref="#13JD"/>
        /// </summary>        
        field(15; "Purch. Lines (Ship)"; Integer)
        {
            Enabled = false;
            Caption = 'Purch. Lines Late (Ship)';
            FieldClass = FlowField;
            CalcFormula = count("Purchase Line" where("Document Type" = const(Order), Type = const(Item), "Location Code" = field("Location Filter Main"), "Expected Receipt Date" = field("Date Filter Late"), "Outstanding Qty. (Base)" = filter(> 0)));
            Editable = false;
        }
        /// <summary>
        /// <see cref="#13JD"/>
        /// </summary>          
        field(20; "Purch. Lines Pending (Main)"; Integer)
        {
            Caption = 'Purch. Lines Pending (Main Loc.)';
            FieldClass = FlowField;
            CalcFormula = count("Purchase Line" where("Document Type" = const(Order), Type = const(Item), "Location Code" = field("Location Filter Main"), "Planned Receipt Date" = field("Date Filter Pending"), "Outstanding Qty. (Base)" = filter(> 0)));
            Editable = false;
        }
        /// <summary>
        /// <see cref="#13JD"/>
        /// </summary>          
        field(21; "Purch. Lines Loading (Main)"; Integer)
        {
            Caption = 'Purch. Lines Loading (Main Loc.)';
            FieldClass = FlowField;
            CalcFormula = count("Purchase Line" where("Document Type" = const(Order), Type = const(Item), "Location Code" = field("Location Filter Main"), "DDN Estimated Date Ready" = field("Date Filter Pending"), "Outstanding Qty. (Base)" = filter(> 0)));
            Editable = false;
        }
        /// <summary>
        /// <see cref="#13JD"/>
        /// </summary>  
        field(25; "Scheduled Freights"; Integer)
        {
            Caption = 'Scheduled Freights';
            FieldClass = FlowField;
            CalcFormula = count("trm Container" where(Status = const(Ready)));
            Editable = false;
        }
        /// <summary>
        /// <see cref="#13JD"/>
        /// </summary>  

        field(30; "Warehouse Receipts"; Integer)
        {
            Caption = 'Warehouse Receipts';
            FieldClass = FlowField;
            // TODO ReactivateJungheinrichCode reacitvate CalcFomula in next line and delete iterim CaclFormula in the second line
            CalcFormula = count("Warehouse Receipt Header" where("Status JH" = field("JH Status Filter"), "Location Code" = field("Location Filter 1_WMS")));
            //CalcFormula = count("Warehouse Receipt Header" where("Location Code" = field("Location Filter 1_WMS")));
            Editable = false;
        }

        /// <summary>
        /// <see cref="#MNVF"/>
        /// </summary>
        field(35; "Purch. Orders not rlsd. 1_WMS"; Integer)
        {
            Caption = 'Purchase Orders not released (1_WMS)';
            FieldClass = FlowField;
            CalcFormula = count("Purchase Header" where("Document Type" = const(Order), Status = const(Open), "Location Code" = field("Location Filter 1_WMS")));
            Editable = false;
        }
        /// <summary>
        /// <see cref="#MNVF"/>
        /// </summary>
        field(36; "Purch. Orders not invoiced"; Integer)
        {
            Caption = 'Purch. Orders not invoiced';
            FieldClass = FlowField;
            CalcFormula = count("Purchase Header" where("Document Type" = const(Order), "Completely Received" = const(true)));
            Editable = false;
        }
        field(37; "Purch. Orders rcvd. not inv."; Integer)
        {
            Caption = 'Purch. Orders received not invoiced';
            FieldClass = FlowField;
            CalcFormula = count("Purchase Header" where("Document Type" = const(Order), "Completely Received" = const(false), "trm All Received and Invoiced" = const(false), "trm Status" = Const("Delivery started")));
            Editable = false;
        }
        /// <summary>
        /// <see cref="DEDT-528"/>
        /// </summary>        
        field(40; "My Due Workflow"; Integer)
        {
            // copied from Trimit 
            CalcFormula = count("trm Workflow" where(TableNo = filter(<> 6037183),
                                                      "Responsible ID" = field("User ID Filter"),
                                                      Deadline = field("Date Filter"),
                                                      Closed = const(false)));
            Caption = 'My Due Workflow';
            Editable = false;
            FieldClass = FlowField;
            TableRelation = Integer;
        }
        /// <summary>
        /// <see cref="#13JD"/>
        /// </summary>          
        field(41; "My Group Due Workflow"; Integer)
        {
            // copied from Trimit 
            CalcFormula = count("trm Workflow" where(TableNo = filter(<> 6037183),
                                                      "Responsible ID Type" = const("User Group"),
                                                      "Responsible ID" = field("Group ID Filter"),
                                                      Deadline = field("Date Filter"),
                                                      Closed = const(false)));
            Caption = 'My Group Due Workflow';
            Editable = false;
            FieldClass = FlowField;
            TableRelation = Integer;
        }
        /// <summary>
        /// <see cref="#MNVF"/>
        /// </summary>
        field(100; "Location Filter Main"; Code[20])
        {
            Caption = 'Location Filter Main';
            FieldClass = FlowFilter;
        }
        /// <summary>
        /// <see cref="#MNVF"/>
        /// </summary>
        field(101; "Location Filter Winsen"; Code[20])
        {
            Caption = 'Location Filter Winsen';
            FieldClass = FlowFilter;
        }
        /// <summary>
        /// <see cref="#MNVF"/>
        /// </summary>        
        field(102; "Date Filter Late"; Date)
        {
            Caption = 'Date Filter Late';
            FieldClass = FlowFilter;
        }
        /// <summary>
        /// <see cref="#MNVF"/>
        /// </summary>        
        field(103; "Date Filter Upcoming"; Date)
        {
            Caption = 'Date Filter Upcoming';
            FieldClass = FlowFilter;
        }
        /// <summary>
        /// <see cref="#13JD"/>
        /// </summary>          
        field(104; "Date Filter Pending"; Date)
        {
            Caption = 'Date Filter Pending';
            FieldClass = FlowFilter;
        }
        /// <summary>
        /// <see cref="#MNVF"/>
        /// </summary>          
        field(105; "Location Filter 1_WMS"; Code[20])
        {
            Caption = 'Location Filter 1_WMS';
            FieldClass = FlowFilter;
        }
        /// <summary>
        /// <see cref="#13JD"/>
        /// </summary>     

        field(106; "JH Status Filter"; Option)
        {
            Caption = 'Date Filter';
            Editable = false;
            FieldClass = FlowFilter;
            // TODO ReactivateJungheinrichCode reactivate TableRelation
            TableRelation = "Warehouse Receipt Header"."Status JH";
            OptionMembers = New,"Released to WMS","Receiving Started","Receiving Completed",Canceled,"Error Export","Error Import";
        }
        /// <summary>
        /// <see cref="#13JD"/>
        /// </summary>         
        field(107; "Container No. Filter"; Code[20])
        {
            Caption = 'Container No. Filter';
            Editable = false;
            FieldClass = FlowFilter;
            TableRelation = "trm Container";
        }
        /// <summary>
        /// <see cref="#13JD"/>
        /// </summary>          
        field(200; "Date Filter"; Date)
        {
            // copied from Trimit 
            Caption = 'Date Filter';
            Editable = false;
            FieldClass = FlowFilter;
        }
        /// <summary>
        /// <see cref="#13JD"/>
        /// </summary>          
        field(201; "User ID Filter"; Code[50])
        {
            // copied from Trimit 
            Caption = 'User ID Filter';
            FieldClass = FlowFilter;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        /// <summary>
        /// <see cref="#13JD"/>
        /// </summary>          
        field(202; "Group ID Filter"; Code[100])
        {
            // copied from Trimit 
            Caption = 'Group ID Filter';
            FieldClass = FlowFilter;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        /// <summary>
        /// <see cref="#13JD"/>
        /// </summary>         
        field(210; "Open Complaints"; Integer)
        {
            CalcFormula = count("trm Complaint Header");
            Caption = 'Open Complaints';
            Editable = false;
            FieldClass = FlowField;
        }
        /// <summary>
        /// <see cref="#13JD"/>
        /// </summary>         
        field(211; "Orders from Complaints"; Integer)
        {
            CalcFormula = count("Sales Header" where("Document Type" = const(Order),
                                                      "trm Complaint" = const(true)));
            Caption = 'Orders from Complaints';
            FieldClass = FlowField;
        }
        /// <summary>
        /// <see cref="#13JD"/>
        /// </summary>         
        field(212; "Credit Memos from Complaints"; Integer)
        {
            CalcFormula = count("Sales Header" where("Document Type" = const("Credit Memo"),
                                                      "trm Complaint" = const(true)));
            Caption = 'Credit Memos from Complaints';
            FieldClass = FlowField;
        }

    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }
}