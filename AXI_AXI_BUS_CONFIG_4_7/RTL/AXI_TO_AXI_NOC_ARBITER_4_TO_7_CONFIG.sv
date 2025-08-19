`define AMBA_AXI_PROT
`define AMBA_QOS

module axi_to_axi_noc_arbiter_4_7_config_top
           #(parameter NUM_MASTER  = 4  // should not be changed
                     , NUM_SLAVE   = 7  // should not be changed
                     , WIDTH_CID   = $clog2(NUM_MASTER) // Channel ID width in bits
                     , WIDTH_ID    = 4 // ID width in bits
                     , WIDTH_AD    =32 // address width
                     , WIDTH_DA    =32 // data width
                     , WIDTH_DS    =(WIDTH_DA/8)  // data strobe width
                     , WIDTH_SID   =(WIDTH_CID+WIDTH_ID)// ID for slave
                     `ifdef AMBA_AXI_AWUSER
                     , WIDTH_AWUSER= 1 // Write-address user path
                     `endif
                     `ifdef AMBA_AXI_WUSER
                     , WIDTH_WUSER = 1 // Write-data user path
                     `endif
                     `ifdef AMBA_AXI_BUSER
                     , WIDTH_BUSER = 1 // Write-response user path
                     `endif
                     `ifdef AMBA_AXI_ARUSER
                     , WIDTH_ARUSER= 1 // read-address user path
                     `endif
                     `ifdef AMBA_AXI_RUSER
                     , WIDTH_RUSER = 1 // read-data user path
                     `endif
                     , SLAVE_EN0=1, ADDR_LENGTH0=12 // effective address bits-widgh
                     , SLAVE_EN1=1, ADDR_LENGTH1=12 // effective address bits-widgh
                     , SLAVE_EN2=1, ADDR_LENGTH2=12 // effective address bits-widgh
                     , SLAVE_EN3=1, ADDR_LENGTH3=12 // effective address bits-widgh
                     , SLAVE_EN4=1, ADDR_LENGTH4=12 // effective address bits-widgh
                     , SLAVE_EN5=1, ADDR_LENGTH5=12 // effective address bits-widgh
                     , SLAVE_EN6=1, ADDR_LENGTH6=12 // effective address bits-widgh
            ,parameter [WIDTH_AD-1:0] ADDR_BASE0='h0
            ,parameter [WIDTH_AD-1:0] ADDR_BASE1='h2000
            ,parameter [WIDTH_AD-1:0] ADDR_BASE2='h4000
            ,parameter [WIDTH_AD-1:0] ADDR_BASE3='h6000
            ,parameter [WIDTH_AD-1:0] ADDR_BASE4='h8000
            ,parameter [WIDTH_AD-1:0] ADDR_BASE5='hA000
            ,parameter [WIDTH_AD-1:0] ADDR_BASE6='hC000
           )
         
           (
            //      GLOBAL SIGNALS
            input   logic                      axi_m4s7_NOC_arbiter_top_clk          ,
            input   logic                      axi_m4s7_NOC_arbiter_top_rstn         ,

            //      4 MASTERS
            //      MASTER_0 SIGNALS 
            input   logic  [WIDTH_ID-1:0]      M0_AWID                          ,                               
            input   logic  [WIDTH_AD-1:0]      M0_AWADDR                        ,  
            input   logic  [ 7:0]              M0_AWLEN                         ,
            input   logic                      M0_AWLOCK                        ,
            input   logic  [ 2:0]              M0_AWSIZE                        ,
            input   logic  [ 1:0]              M0_AWBURST                       ,
           `ifdef AMBA_AXI_PROT
            input   logic  [ 2:0]              M0_AWPROT                        ,   
           `endif
            input   logic                      M0_AWVALID                       ,
            output  logic                      M0_AWREADY                       ,
           `ifdef AMBA_QOS  
            input   logic  [ 3:0]              M0_AWQOS                         ,
            input   logic  [ 3:0]              M0_AWREGION                      ,
           `endif
            input   logic   [WIDTH_DA-1:0]     M0_WDATA                         ,     
            input   logic   [WIDTH_DS-1:0]     M0_WSTRB                         ,
            input   logic                      M0_WLAST                         ,
            input   logic                      M0_WVALID                        , 
            output  logic                      M0_WREADY                        , 

            output  logic   [WIDTH_ID-1:0]     M0_BID                           ,
            output  logic   [ 1:0]             M0_BRESP                         ,    
            output  logic                      M0_BVALID                        ,
            input   logic                      M0_BREADY                        ,

            input   logic   [WIDTH_ID-1:0]     M0_ARID                          ,    
            input   logic   [WIDTH_AD-1:0]     M0_ARADDR                        ,  
            input   logic   [ 7:0]             M0_ARLEN                         ,
            input   logic                      M0_ARLOCK                        ,
            input   logic   [ 2:0]             M0_ARSIZE                        ,
            input   logic   [ 1:0]             M0_ARBURST                       ,
           `ifdef AMBA_AXI_PROT
            input   logic   [ 2:0]             M0_ARPROT                        ,
           `endif
            input   logic                      M0_ARVALID                       ,
            output  logic                      M0_ARREADY                       ,
           `ifdef AMBA_QOS
            input   logic   [ 3:0]             M0_ARQOS                         ,
            input   logic   [ 3:0]             M0_ARREGION                      ,
           `endif
            output  logic   [WIDTH_ID-1:0]     M0_RID                           ,
            output  logic   [WIDTH_DA-1:0]     M0_RDATA                         ,
            output  logic   [ 1:0]             M0_RRESP                         ,
            output  logic                      M0_RLAST                         ,
            output  logic                      M0_RVALID                        ,
            input   logic                      M0_RREADY                        ,
           //------------------------------------------------------

            //         MASTER_1 SIGNALS 
            input   logic  [WIDTH_ID-1:0]      M1_AWID                          ,                               
            input   logic  [WIDTH_AD-1:0]      M1_AWADDR                        ,  
            input   logic  [ 7:0]              M1_AWLEN                         ,
            input   logic                      M1_AWLOCK                        ,
            input   logic  [ 2:0]              M1_AWSIZE                        ,
            input   logic  [ 1:0]              M1_AWBURST                       ,
           `ifdef AMBA_AXI_PROT
            input   logic  [ 2:0]              M1_AWPROT                        ,   
           `endif
            input   logic                      M1_AWVALID                       ,
            output  logic                      M1_AWREADY                       ,
           `ifdef AMBA_QOS  
            input   logic  [ 3:0]              M1_AWQOS                         ,
            input   logic  [ 3:0]              M1_AWREGION                      ,
           `endif
            input   logic   [WIDTH_DA-1:0]     M1_WDATA                         ,     
            input   logic   [WIDTH_DS-1:0]     M1_WSTRB                         ,
            input   logic                      M1_WLAST                         ,
            input   logic                      M1_WVALID                        , 
            output  logic                      M1_WREADY                        , 

            output  logic   [WIDTH_ID-1:0]     M1_BID                           ,
            output  logic   [ 1:0]             M1_BRESP                         ,    
            output  logic                      M1_BVALID                        ,
            input   logic                      M1_BREADY                        ,

            input   logic   [WIDTH_ID-1:0]     M1_ARID                          ,    
            input   logic   [WIDTH_AD-1:0]     M1_ARADDR                        ,  
            input   logic   [ 7:0]             M1_ARLEN                         ,
            input   logic                      M1_ARLOCK                        ,
            input   logic   [ 2:0]             M1_ARSIZE                        ,
            input   logic   [ 1:0]             M1_ARBURST                       ,
           `ifdef AMBA_AXI_PROT
            input   logic   [ 2:0]             M1_ARPROT                        ,
           `endif
            input   logic                      M1_ARVALID                       ,
            output  logic                      M1_ARREADY                       ,
           `ifdef AMBA_QOS
            input   logic   [ 3:0]             M1_ARQOS                         ,
            input   logic   [ 3:0]             M1_ARREGION                      ,
           `endif
            output  logic   [WIDTH_ID-1:0]     M1_RID                           ,
            output  logic   [WIDTH_DA-1:0]     M1_RDATA                         ,
            output  logic   [ 1:0]             M1_RRESP                         ,
            output  logic                      M1_RLAST                         ,
            output  logic                      M1_RVALID                        ,
            input   logic                      M1_RREADY                        ,
           //------------------------------------------------------

            //         MASTER_2 SIGNALS 
            input   logic  [WIDTH_ID-1:0]      M2_AWID                          ,                               
            input   logic  [WIDTH_AD-1:0]      M2_AWADDR                        ,  
            input   logic  [ 7:0]              M2_AWLEN                         ,
            input   logic                      M2_AWLOCK                        ,
            input   logic  [ 2:0]              M2_AWSIZE                        ,
            input   logic  [ 1:0]              M2_AWBURST                       ,
           `ifdef AMBA_AXI_PROT
            input   logic  [ 2:0]              M2_AWPROT                        ,   
           `endif
            input   logic                      M2_AWVALID                       ,
            output  logic                      M2_AWREADY                       ,
           `ifdef AMBA_QOS  
            input   logic  [ 3:0]              M2_AWQOS                         ,
            input   logic  [ 3:0]              M2_AWREGION                      ,
           `endif
            input   logic   [WIDTH_DA-1:0]     M2_WDATA                         ,     
            input   logic   [WIDTH_DS-1:0]     M2_WSTRB                         ,
            input   logic                      M2_WLAST                         ,
            input   logic                      M2_WVALID                        , 
            output  logic                      M2_WREADY                        , 

            output  logic   [WIDTH_ID-1:0]     M2_BID                           ,
            output  logic   [ 1:0]             M2_BRESP                         ,    
            output  logic                      M2_BVALID                        ,
            input   logic                      M2_BREADY                        ,

            input   logic   [WIDTH_ID-1:0]     M2_ARID                          ,    
            input   logic   [WIDTH_AD-1:0]     M2_ARADDR                        ,  
            input   logic   [ 7:0]             M2_ARLEN                         ,
            input   logic                      M2_ARLOCK                        ,
            input   logic   [ 2:0]             M2_ARSIZE                        ,
            input   logic   [ 1:0]             M2_ARBURST                       ,
           `ifdef AMBA_AXI_PROT
            input   logic   [ 2:0]             M2_ARPROT                        ,
           `endif
            input   logic                      M2_ARVALID                       ,
            output  logic                      M2_ARREADY                       ,
           `ifdef AMBA_QOS
            input   logic   [ 3:0]             M2_ARQOS                         ,
            input   logic   [ 3:0]             M2_ARREGION                      ,
           `endif
            output  logic   [WIDTH_ID-1:0]     M2_RID                           ,
            output  logic   [WIDTH_DA-1:0]     M2_RDATA                         ,
            output  logic   [ 1:0]             M2_RRESP                         ,
            output  logic                      M2_RLAST                         ,
            output  logic                      M2_RVALID                        ,
            input   logic                      M2_RREADY                        ,
           //------------------------------------------------------

            //         MASTER_3 SIGNALS
            input   logic  [WIDTH_ID-1:0]      M3_AWID                          ,                               
            input   logic  [WIDTH_AD-1:0]      M3_AWADDR                        ,  
            input   logic  [ 7:0]              M3_AWLEN                         ,
            input   logic                      M3_AWLOCK                        ,
            input   logic  [ 2:0]              M3_AWSIZE                        ,
            input   logic  [ 1:0]              M3_AWBURST                       ,
           `ifdef AMBA_AXI_PROT
            input   logic  [ 2:0]              M3_AWPROT                        ,   
           `endif
            input   logic                      M3_AWVALID                       ,
            output  logic                      M3_AWREADY                       ,
           `ifdef AMBA_QOS  
            input   logic  [ 3:0]              M3_AWQOS                         ,
            input   logic  [ 3:0]              M3_AWREGION                      ,
           `endif
            input   logic   [WIDTH_DA-1:0]     M3_WDATA                         ,     
            input   logic   [WIDTH_DS-1:0]     M3_WSTRB                         ,
            input   logic                      M3_WLAST                         ,
            input   logic                      M3_WVALID                        , 
            output  logic                      M3_WREADY                        , 

            output  logic   [WIDTH_ID-1:0]     M3_BID                           ,
            output  logic   [ 1:0]             M3_BRESP                         ,    
            output  logic                      M3_BVALID                        ,
            input   logic                      M3_BREADY                        ,

            input   logic   [WIDTH_ID-1:0]     M3_ARID                          ,    
            input   logic   [WIDTH_AD-1:0]     M3_ARADDR                        ,  
            input   logic   [ 7:0]             M3_ARLEN                         ,
            input   logic                      M3_ARLOCK                        ,
            input   logic   [ 2:0]             M3_ARSIZE                        ,
            input   logic   [ 1:0]             M3_ARBURST                       ,
           `ifdef AMBA_AXI_PROT
            input   logic   [ 2:0]             M3_ARPROT                        ,
           `endif
            input   logic                      M3_ARVALID                       ,
            output  logic                      M3_ARREADY                       ,
           `ifdef AMBA_QOS
            input   logic   [ 3:0]             M3_ARQOS                         ,
            input   logic   [ 3:0]             M3_ARREGION                      ,
           `endif
            output  logic   [WIDTH_ID-1:0]     M3_RID                           ,
            output  logic   [WIDTH_DA-1:0]     M3_RDATA                         ,
            output  logic   [ 1:0]             M3_RRESP                         ,
            output  logic                      M3_RLAST                         ,
            output  logic                      M3_RVALID                        ,
            input   logic                      M3_RREADY                        ,
            //------------------------------------------------------

             //      7 SLAVES 
             //------------SIGNALS TO AXI SLAVES------------//
             output  logic  [WIDTH_SID-1:0]    S0_AWID                      ,                               
             output  logic  [WIDTH_AD-1:0]     S0_AWADDR                    ,  
             output  logic  [ 7:0]             S0_AWLEN                     ,
             output  logic                     S0_AWLOCK                    ,
             output  logic  [ 2:0]             S0_AWSIZE                    ,
             output  logic  [ 1:0]             S0_AWBURST                   ,
            `ifdef AMBA_AXI_PROT
             output  logic  [ 2:0]             S0_AWPROT                    ,   
            `endif
             output  logic                     S0_AWVALID                   ,
             input   logic                     S0_AWREADY                   ,
            `ifdef AMBA_QOS  
             output  logic  [ 3:0]             S0_AWQOS                     ,
             output  logic  [ 3:0]             S0_AWREGION                  ,
            `endif
             output  logic   [WIDTH_DA-1:0]    S0_WDATA                     ,     
             output  logic   [WIDTH_DS-1:0]    S0_WSTRB                     ,
             output  logic                     S0_WLAST                     ,
             output  logic                     S0_WVALID                    , 
             input   logic                     S0_WREADY                    , 

             input   logic   [WIDTH_SID-1:0]   S0_BID                       ,
             input   logic   [ 1:0]            S0_BRESP                     ,    
             input   logic                     S0_BVALID                    ,
             output  logic                     S0_BREADY                    ,

             output  logic   [WIDTH_SID-1:0]   S0_ARID                      ,    
             output  logic   [WIDTH_AD-1:0]    S0_ARADDR                    ,  
             output  logic   [ 7:0]            S0_ARLEN                     ,
             output  logic                     S0_ARLOCK                    ,
             output  logic   [ 2:0]            S0_ARSIZE                    ,
             output  logic   [ 1:0]            S0_ARBURST                   ,
            `ifdef AMBA_AXI_PROT
             output  logic   [ 2:0]            S0_ARPROT                    ,
            `endif
             output  logic                     S0_ARVALID                   ,
             input   logic                     S0_ARREADY                   ,
            `ifdef AMBA_QOS
             output  logic   [ 3:0]            S0_ARQOS                     ,
             output  logic   [ 3:0]            S0_ARREGION                  ,
            `endif
             input   logic   [WIDTH_SID-1:0]   S0_RID                       ,
             input   logic   [WIDTH_DA-1:0]    S0_RDATA                     ,
             input   logic   [ 1:0]            S0_RRESP                     ,
             input   logic                     S0_RLAST                     ,
             input   logic                     S0_RVALID                    ,
             output  logic                     S0_RREADY                    ,
            //------------------------------------------------------

             output  logic  [WIDTH_SID-1:0]    S1_AWID                      ,        
             output  logic  [WIDTH_AD-1:0]     S1_AWADDR                    ,
             output  logic  [ 7:0]             S1_AWLEN                     ,
             output  logic                     S1_AWLOCK                    ,
             output  logic  [ 2:0]             S1_AWSIZE                    ,
             output  logic  [ 1:0]             S1_AWBURST                   ,
            `ifdef AMBA_AXI_PROT
             output  logic  [ 2:0]             S1_AWPROT                    ,
            `endif
             output  logic                     S1_AWVALID                   , 
             input   logic                     S1_AWREADY                   ,
            `ifdef AMBA_QOS
             output  logic  [ 3:0]             S1_AWQOS                     ,
             output  logic  [ 3:0]             S1_AWREGION                  ,
            `endif

             output  logic   [WIDTH_DA-1:0]    S1_WDATA                     ,    
             output  logic   [WIDTH_DS-1:0]    S1_WSTRB                     ,
             output  logic                     S1_WLAST                     ,
             output  logic                     S1_WVALID                    ,
             input   logic                     S1_WREADY                    ,

             input   logic   [WIDTH_SID-1:0]   S1_BID                       ,
             input   logic   [ 1:0]            S1_BRESP                     ,
             input   logic                     S1_BVALID                    ,
             output  logic                     S1_BREADY                    ,

             output  logic   [WIDTH_SID-1:0]   S1_ARID                      ,   
             output  logic   [WIDTH_AD-1:0]    S1_ARADDR                    ,
             output  logic   [ 7:0]            S1_ARLEN                     ,
             output  logic                     S1_ARLOCK                    ,
             output  logic   [ 2:0]            S1_ARSIZE                    ,
             output  logic   [ 1:0]            S1_ARBURST                   ,
            `ifdef AMBA_AXI_PROT
             output  logic   [ 2:0]            S1_ARPROT                    ,
            `endif
             output  logic                     S1_ARVALID                   ,
             input   logic                     S1_ARREADY                   ,
            `ifdef AMBA_QOS
             output  logic   [ 3:0]            S1_ARQOS                     ,
             output  logic   [ 3:0]            S1_ARREGION                  ,
            `endif

             input   logic   [WIDTH_SID-1:0]   S1_RID                       ,    
             input   logic   [WIDTH_DA-1:0]    S1_RDATA                     ,
             input   logic   [ 1:0]            S1_RRESP                     ,
             input   logic                     S1_RLAST                     ,
             input   logic                     S1_RVALID                    ,
             output  logic                     S1_RREADY                    ,
            //-----------------------------------------------------

             output  logic  [WIDTH_SID-1:0]    S2_AWID                      ,   
             output  logic  [WIDTH_AD-1:0]     S2_AWADDR                    , 
             output  logic  [ 7:0]             S2_AWLEN                     ,
             output  logic                     S2_AWLOCK                    ,
             output  logic  [ 2:0]             S2_AWSIZE                    ,
             output  logic  [ 1:0]             S2_AWBURST                   ,
            `ifdef AMBA_AXI_PROT
             output  logic  [ 2:0]             S2_AWPROT                    ,
            `endif
             output  logic                     S2_AWVALID                   ,
             input   logic                     S2_AWREADY                   ,
            `ifdef AMBA_QOS
             output  logic  [ 3:0]             S2_AWQOS                     ,
             output  logic  [ 3:0]             S2_AWREGION                  ,
            `endif

             output  logic   [WIDTH_DA-1:0]    S2_WDATA                     ,     
             output  logic   [WIDTH_DS-1:0]    S2_WSTRB                     ,
             output  logic                     S2_WLAST                     ,
             output  logic                     S2_WVALID                    ,
             input   logic                     S2_WREADY                    ,

             input   logic   [WIDTH_SID-1:0]   S2_BID                       ,  
             input   logic   [ 1:0]            S2_BRESP                     ,
             input   logic                     S2_BVALID                    ,
             output  logic                     S2_BREADY                    ,

             output  logic   [WIDTH_SID-1:0]   S2_ARID                      ,   
             output  logic   [WIDTH_AD-1:0]    S2_ARADDR                    ,    
             output  logic   [ 7:0]            S2_ARLEN                     ,
             output  logic                     S2_ARLOCK                    ,
             output  logic   [ 2:0]            S2_ARSIZE                    ,
             output  logic   [ 1:0]            S2_ARBURST                   ,
            `ifdef AMBA_AXI_PROT
             output  logic   [ 2:0]            S2_ARPROT                    ,
            `endif
             output  logic                     S2_ARVALID                   ,
             input   logic                     S2_ARREADY                   ,
            `ifdef AMBA_QOS
             output  logic   [ 3:0]            S2_ARQOS                     ,
             output  logic   [ 3:0]            S2_ARREGION                  ,
            `endif

             input   logic   [WIDTH_SID-1:0]   S2_RID                       ,    
             input   logic   [WIDTH_DA-1:0]    S2_RDATA                     , 
             input   logic   [ 1:0]            S2_RRESP                     ,
             input   logic                     S2_RLAST                     ,
             input   logic                     S2_RVALID                    ,
             output  logic                     S2_RREADY                    ,
            //-----------------------------------------------------

             output  logic  [WIDTH_SID-1:0]    S3_AWID                      ,   
             output  logic  [WIDTH_AD-1:0]     S3_AWADDR                    ,
             output  logic  [ 7:0]             S3_AWLEN                     ,
             output  logic                     S3_AWLOCK                    ,
             output  logic  [ 2:0]             S3_AWSIZE                    ,
             output  logic  [ 1:0]             S3_AWBURST                   ,
            `ifdef AMBA_AXI_PROT
             output  logic  [ 2:0]             S3_AWPROT                    ,
            `endif
             output  logic                     S3_AWVALID                   ,
             input   logic                     S3_AWREADY                   ,
            `ifdef AMBA_QOS
             output  logic  [ 3:0]             S3_AWQOS                     ,
             output  logic  [ 3:0]             S3_AWREGION                  ,
            `endif
             output  logic   [WIDTH_DA-1:0]    S3_WDATA                     ,    
             output  logic   [WIDTH_DS-1:0]    S3_WSTRB                     ,
             output  logic                     S3_WLAST                     ,
             output  logic                     S3_WVALID                    ,
             input   logic                     S3_WREADY                    ,

             input   logic   [WIDTH_SID-1:0]   S3_BID                       ,
             input   logic   [ 1:0]            S3_BRESP                     ,
             input   logic                     S3_BVALID                    ,
             output  logic                     S3_BREADY                    ,

             output  logic   [WIDTH_SID-1:0]   S3_ARID                      ,   
             output  logic   [WIDTH_AD-1:0]    S3_ARADDR                    ,
             output  logic   [ 7:0]            S3_ARLEN                     ,
             output  logic                     S3_ARLOCK                    ,
             output  logic   [ 2:0]            S3_ARSIZE                    ,
             output  logic   [ 1:0]            S3_ARBURST                   ,
            `ifdef AMBA_AXI_PROT
             output  logic   [ 2:0]            S3_ARPROT                    ,
            `endif
             output  logic                     S3_ARVALID                   ,
             input   logic                     S3_ARREADY                   ,
            `ifdef AMBA_QOS
             output  logic   [ 3:0]            S3_ARQOS                     ,
             output  logic   [ 3:0]            S3_ARREGION                  ,
            `endif
             input   logic   [WIDTH_SID-1:0]   S3_RID                       ,    
             input   logic   [WIDTH_DA-1:0]    S3_RDATA                     ,  
             input   logic   [ 1:0]            S3_RRESP                     ,
             input   logic                     S3_RLAST                     ,
             input   logic                     S3_RVALID                    ,
             output  logic                     S3_RREADY                    ,
            //-----------------------------------------------------

             output  logic  [WIDTH_SID-1:0]    S4_AWID                      ,
             output  logic  [WIDTH_AD-1:0]     S4_AWADDR                    ,
             output  logic  [ 7:0]             S4_AWLEN                     ,
             output  logic                     S4_AWLOCK                    ,
             output  logic  [ 2:0]             S4_AWSIZE                    ,
             output  logic  [ 1:0]             S4_AWBURST                   ,
            `ifdef AMBA_AXI_PROT
             output  logic  [ 2:0]             S4_AWPROT                    , 
            `endif
             output  logic                     S4_AWVALID                   ,
             input   logic                     S4_AWREADY                   ,
            `ifdef AMBA_QOS
             output  logic  [ 3:0]             S4_AWQOS                     ,
             output  logic  [ 3:0]             S4_AWREGION                  ,
            `endif

             output  logic   [WIDTH_DA-1:0]    S4_WDATA                     ,
             output  logic   [WIDTH_DS-1:0]    S4_WSTRB                     ,
             output  logic                     S4_WLAST                     ,
             output  logic                     S4_WVALID                    ,
             input   logic                     S4_WREADY                    ,

             input   logic   [WIDTH_SID-1:0]   S4_BID                       ,
             input   logic   [ 1:0]            S4_BRESP                     ,
             input   logic                     S4_BVALID                    ,
             output  logic                     S4_BREADY                    ,

             output  logic   [WIDTH_SID-1:0]   S4_ARID                      ,   
             output  logic   [WIDTH_AD-1:0]    S4_ARADDR                    ,
             output  logic   [ 7:0]            S4_ARLEN                     ,
             output  logic                     S4_ARLOCK                    ,
             output  logic   [ 2:0]            S4_ARSIZE                    ,
             output  logic   [ 1:0]            S4_ARBURST                   ,
            `ifdef AMBA_AXI_PROT
             output  logic   [ 2:0]            S4_ARPROT                    ,
            `endif
             output  logic                     S4_ARVALID                   ,
             input   logic                     S4_ARREADY                   ,
            `ifdef AMBA_QOS
             output  logic   [ 3:0]            S4_ARQOS                     ,
             output  logic   [ 3:0]            S4_ARREGION                  ,
            `endif

             input   logic   [WIDTH_SID-1:0]   S4_RID                       ,    
             input   logic   [WIDTH_DA-1:0]    S4_RDATA                     , 
             input   logic   [ 1:0]            S4_RRESP                     ,
             input   logic                     S4_RLAST                     ,
             input   logic                     S4_RVALID                    ,
             output  logic                     S4_RREADY                    ,
            //-----------------------------------------------------

             output  logic  [WIDTH_SID-1:0]    S5_AWID                      ,
             output  logic  [WIDTH_AD-1:0]     S5_AWADDR                    ,
             output  logic  [ 7:0]             S5_AWLEN                     ,
             output  logic                     S5_AWLOCK                    ,
             output  logic  [ 2:0]             S5_AWSIZE                    ,
             output  logic  [ 1:0]             S5_AWBURST                   ,
            `ifdef AMBA_AXI_PROT
             output  logic  [ 2:0]             S5_AWPROT                    ,
            `endif
             output  logic                     S5_AWVALID                   ,
             input   logic                     S5_AWREADY                   ,
            `ifdef AMBA_QOS
             output  logic  [ 3:0]             S5_AWQOS                     ,
             output  logic  [ 3:0]             S5_AWREGION                  ,
            `endif

             output  logic   [WIDTH_DA-1:0]    S5_WDATA                     , 
             output  logic   [WIDTH_DS-1:0]    S5_WSTRB                     ,
             output  logic                     S5_WLAST                     ,
             output  logic                     S5_WVALID                    ,
             input   logic                     S5_WREADY                    ,

             input   logic   [WIDTH_SID-1:0]   S5_BID                       ,    
             input   logic   [ 1:0]            S5_BRESP                     ,
             input   logic                     S5_BVALID                    ,
             output  logic                     S5_BREADY                    ,

             output  logic   [WIDTH_SID-1:0]   S5_ARID                      ,   
             output  logic   [WIDTH_AD-1:0]    S5_ARADDR                    ,
             output  logic   [ 7:0]            S5_ARLEN                     ,
             output  logic                     S5_ARLOCK                    ,
             output  logic   [ 2:0]            S5_ARSIZE                    ,
             output  logic   [ 1:0]            S5_ARBURST                   ,
            `ifdef AMBA_AXI_PROT
             output  logic   [ 2:0]            S5_ARPROT                    ,
            `endif
             output  logic                     S5_ARVALID                   ,
             input   logic                     S5_ARREADY                   ,
            `ifdef AMBA_QOS
             output  logic   [ 3:0]            S5_ARQOS                     ,
             output  logic   [ 3:0]            S5_ARREGION                  ,
            `endif

             input   logic   [WIDTH_SID-1:0]   S5_RID                       ,    
             input   logic   [WIDTH_DA-1:0]    S5_RDATA                     ,
             input   logic   [ 1:0]            S5_RRESP                     ,
             input   logic                     S5_RLAST                     ,
             input   logic                     S5_RVALID                    ,
             output  logic                     S5_RREADY                    ,
            //-----------------------------------------------------

             output  logic  [WIDTH_SID-1:0]    S6_AWID                      ,  
             output  logic  [WIDTH_AD-1:0]     S6_AWADDR                    ,
             output  logic  [ 7:0]             S6_AWLEN                     ,
             output  logic                     S6_AWLOCK                    ,
             output  logic  [ 2:0]             S6_AWSIZE                    ,
             output  logic  [ 1:0]             S6_AWBURST                   ,
            `ifdef AMBA_AXI_PROT
             output  logic  [ 2:0]             S6_AWPROT                    ,
            `endif
             output  logic                     S6_AWVALID                   ,
             input   logic                     S6_AWREADY                   ,
            `ifdef AMBA_QOS
             output  logic  [ 3:0]             S6_AWQOS                     ,
             output  logic  [ 3:0]             S6_AWREGION                  ,
            `endif

             output  logic   [WIDTH_DA-1:0]    S6_WDATA                     ,    
             output  logic   [WIDTH_DS-1:0]    S6_WSTRB                     ,
             output  logic                     S6_WLAST                     ,
             output  logic                     S6_WVALID                    ,
             input   logic                     S6_WREADY                    ,

             input   logic   [WIDTH_SID-1:0]   S6_BID                       ,    
             input   logic   [ 1:0]            S6_BRESP                     ,
             input   logic                     S6_BVALID                    ,
             output  logic                     S6_BREADY                    ,

             output  logic   [WIDTH_SID-1:0]   S6_ARID                      ,   
             output  logic   [WIDTH_AD-1:0]    S6_ARADDR                    ,    
             output  logic   [ 7:0]            S6_ARLEN                     ,
             output  logic                     S6_ARLOCK                    ,
             output  logic   [ 2:0]            S6_ARSIZE                    ,
             output  logic   [ 1:0]            S6_ARBURST                   ,
            `ifdef AMBA_AXI_PROT
             output  logic   [ 2:0]            S6_ARPROT                    ,
            `endif
             output  logic                     S6_ARVALID                   ,
             input   logic                     S6_ARREADY                   ,
            `ifdef AMBA_QOS
             output  logic   [ 3:0]            S6_ARQOS                     ,
             output  logic   [ 3:0]            S6_ARREGION                  ,
            `endif

             input   logic   [WIDTH_SID-1:0]   S6_RID                       ,
             input   logic   [WIDTH_DA-1:0]    S6_RDATA                     ,
             input   logic   [ 1:0]            S6_RRESP                     ,
             input   logic                     S6_RLAST                     ,
             input   logic                     S6_RVALID                    ,
             output  logic                     S6_RREADY                    
           );

            //  INTERNAL DECLERATIONS FOR CONNECTIONS
            logic  [WIDTH_ID-1:0]      w_M1_AWID       ;        
            logic  [WIDTH_AD-1:0]      w_M1_AWADDR     ;        
            logic  [ 7:0]              w_M1_AWLEN      ;        
            logic                      w_M1_AWLOCK     ;        
            logic  [ 2:0]              w_M1_AWSIZE     ;        
            logic  [ 1:0]              w_M1_AWBURST    ;        
            logic  [ 2:0]              w_M1_AWPROT     ;        
            logic                      w_M1_AWVALID    ;        
            logic                      w_M1_AWREADY    ;        
            logic  [ 3:0]              w_M1_AWQOS      ;        
            logic  [ 3:0]              w_M1_AWREGION   ;        
            logic   [WIDTH_DA-1:0]     w_M1_WDATA      ;        
            logic   [WIDTH_DS-1:0]     w_M1_WSTRB      ;        
            logic                      w_M1_WLAST      ;        
            logic                      w_M1_WVALID     ;        
            logic                      w_M1_WREADY     ;        
            logic   [WIDTH_ID-1:0]     w_M1_BID        ;        
            logic   [ 1:0]             w_M1_BRESP      ;        
            logic                      w_M1_BVALID     ;        
            logic                      w_M1_BREADY     ;        
            logic   [WIDTH_ID-1:0]     w_M1_ARID       ;        
            logic   [WIDTH_AD-1:0]     w_M1_ARADDR     ;        
            logic   [ 7:0]             w_M1_ARLEN      ;        
            logic                      w_M1_ARLOCK     ;        
            logic   [ 2:0]             w_M1_ARSIZE     ;        
            logic   [ 1:0]             w_M1_ARBURST    ;        
            logic   [ 2:0]             w_M1_ARPROT     ;        
            logic                      w_M1_ARVALID    ;        
            logic                      w_M1_ARREADY    ;        
            logic   [ 3:0]             w_M1_ARQOS      ;        
            logic   [ 3:0]             w_M1_ARREGION   ;        
            logic   [WIDTH_ID-1:0]     w_M1_RID        ;        
            logic   [WIDTH_DA-1:0]     w_M1_RDATA      ;        
            logic   [ 1:0]             w_M1_RRESP      ;        
            logic                      w_M1_RLAST      ;        
            logic                      w_M1_RVALID     ;        
            logic                      w_M1_RREADY     ;

            logic  [WIDTH_ID-1:0]      w_M2_AWID       ;        
            logic  [WIDTH_AD-1:0]      w_M2_AWADDR     ;        
            logic  [ 7:0]              w_M2_AWLEN      ;        
            logic                      w_M2_AWLOCK     ;        
            logic  [ 2:0]              w_M2_AWSIZE     ;        
            logic  [ 1:0]              w_M2_AWBURST    ;        
            logic  [ 2:0]              w_M2_AWPROT     ;        
            logic                      w_M2_AWVALID    ;        
            logic                      w_M2_AWREADY    ;        
            logic  [ 3:0]              w_M2_AWQOS      ;        
            logic  [ 3:0]              w_M2_AWREGION   ;        
            logic   [WIDTH_DA-1:0]     w_M2_WDATA      ;        
            logic   [WIDTH_DS-1:0]     w_M2_WSTRB      ;        
            logic                      w_M2_WLAST      ;        
            logic                      w_M2_WVALID     ;        
            logic                      w_M2_WREADY     ;        
            logic   [WIDTH_ID-1:0]     w_M2_BID        ;        
            logic   [ 1:0]             w_M2_BRESP      ;        
            logic                      w_M2_BVALID     ;        
            logic                      w_M2_BREADY     ;        
            logic   [WIDTH_ID-1:0]     w_M2_ARID       ;        
            logic   [WIDTH_AD-1:0]     w_M2_ARADDR     ;        
            logic   [ 7:0]             w_M2_ARLEN      ;        
            logic                      w_M2_ARLOCK     ;        
            logic   [ 2:0]             w_M2_ARSIZE     ;        
            logic   [ 1:0]             w_M2_ARBURST    ;        
            logic   [ 2:0]             w_M2_ARPROT     ;        
            logic                      w_M2_ARVALID    ;        
            logic                      w_M2_ARREADY    ;        
            logic   [ 3:0]             w_M2_ARQOS      ;        
            logic   [ 3:0]             w_M2_ARREGION   ;        
            logic   [WIDTH_ID-1:0]     w_M2_RID        ;        
            logic   [WIDTH_DA-1:0]     w_M2_RDATA      ;        
            logic   [ 1:0]             w_M2_RRESP      ;        
            logic                      w_M2_RLAST      ;        
            logic                      w_M2_RVALID     ;        
            logic                      w_M2_RREADY     ;

            logic  [WIDTH_ID-1:0]      w_M3_AWID       ;        
            logic  [WIDTH_AD-1:0]      w_M3_AWADDR     ;        
            logic  [ 7:0]              w_M3_AWLEN      ;        
            logic                      w_M3_AWLOCK     ;        
            logic  [ 2:0]              w_M3_AWSIZE     ;        
            logic  [ 1:0]              w_M3_AWBURST    ;        
            logic  [ 2:0]              w_M3_AWPROT     ;        
            logic                      w_M3_AWVALID    ;        
            logic                      w_M3_AWREADY    ;        
            logic  [ 3:0]              w_M3_AWQOS      ;        
            logic  [ 3:0]              w_M3_AWREGION   ;        
            logic   [WIDTH_DA-1:0]     w_M3_WDATA      ;        
            logic   [WIDTH_DS-1:0]     w_M3_WSTRB      ;        
            logic                      w_M3_WLAST      ;        
            logic                      w_M3_WVALID     ;        
            logic                      w_M3_WREADY     ;        
            logic   [WIDTH_ID-1:0]     w_M3_BID        ;        
            logic   [ 1:0]             w_M3_BRESP      ;        
            logic                      w_M3_BVALID     ;        
            logic                      w_M3_BREADY     ;        
            logic   [WIDTH_ID-1:0]     w_M3_ARID       ;        
            logic   [WIDTH_AD-1:0]     w_M3_ARADDR     ;        
            logic   [ 7:0]             w_M3_ARLEN      ;        
            logic                      w_M3_ARLOCK     ;        
            logic   [ 2:0]             w_M3_ARSIZE     ;        
            logic   [ 1:0]             w_M3_ARBURST    ;        
            logic   [ 2:0]             w_M3_ARPROT     ;        
            logic                      w_M3_ARVALID    ;        
            logic                      w_M3_ARREADY    ;        
            logic   [ 3:0]             w_M3_ARQOS      ;        
            logic   [ 3:0]             w_M3_ARREGION   ;        
            logic   [WIDTH_ID-1:0]     w_M3_RID        ;        
            logic   [WIDTH_DA-1:0]     w_M3_RDATA      ;        
            logic   [ 1:0]             w_M3_RRESP      ;        
            logic                      w_M3_RLAST      ;        
            logic                      w_M3_RVALID     ;        
            logic                      w_M3_RREADY     ;

          //    AXI_MASTER_1_SLAVE_ROUTER MODULE INSTANTIATION
          axi_master_1_slave_router
                #(
                  .WIDTH_ID     ( WIDTH_ID )         , 
                  .WIDTH_DA     ( WIDTH_DA )         ,
                  .WIDTH_AD     ( WIDTH_AD )         ,
                  .WIDTH_DS     ( WIDTH_DS )         
                 )
          axi_master_1_slave_router_inst
                (
                 .axi_master_1_slave_router_clk    ( axi_m4s7_NOC_arbiter_top_clk  )           , 
                 .axi_master_1_slave_router_rstn   ( axi_m4s7_NOC_arbiter_top_rstn )           ,

                 .AWID                             ( M1_AWID                  )           ,                      
                 .AWADDR                           ( M1_AWADDR                )           ,                      
                 .AWLEN                            ( M1_AWLEN                 )           ,                      
                 .AWLOCK                           ( M1_AWLOCK                )           ,                      
                 .AWSIZE                           ( M1_AWSIZE                )           ,                      
                 .AWBURST                          ( M1_AWBURST               )           ,                      
                 .AWPROT                           ( M1_AWPROT                )           ,                      
                 .AWVALID                          ( M1_AWVALID               )           ,                      
                 .AWREADY                          ( M1_AWREADY               )           ,                      
                 .AWQOS                            ( M1_AWQOS                 )           ,                      
                 .AWREGION                         ( M1_AWREGION              )           ,                      
                 .WDATA                            ( M1_WDATA                 )           ,                      
                 .WSTRB                            ( M1_WSTRB                 )           ,                      
                 .WLAST                            ( M1_WLAST                 )           ,                      
                 .WVALID                           ( M1_WVALID                )           ,                      
                 .WREADY                           ( M1_WREADY                )           ,                      
                 .BID                              ( M1_BID                   )           ,                      
                 .BRESP                            ( M1_BRESP                 )           ,                      
                 .BVALID                           ( M1_BVALID                )           ,                      
                 .BREADY                           ( M1_BREADY                )           ,                      
                 .ARID                             ( M1_ARID                  )           ,                      
                 .ARADDR                           ( M1_ARADDR                )           ,                      
                 .ARLEN                            ( M1_ARLEN                 )           ,                      
                 .ARLOCK                           ( M1_ARLOCK                )           ,                      
                 .ARSIZE                           ( M1_ARSIZE                )           ,                      
                 .ARBURST                          ( M1_ARBURST               )           ,                      
                 .ARPROT                           ( M1_ARPROT                )           ,                      
                 .ARVALID                          ( M1_ARVALID               )           ,                      
                 .ARREADY                          ( M1_ARREADY               )           ,                      
                 .ARQOS                            ( M1_ARQOS                 )           ,                      
                 .ARREGION                         ( M1_ARREGION              )           ,                      
                 .RID                              ( M1_RID                   )           ,                      
                 .RDATA                            ( M1_RDATA                 )           ,                      
                 .RRESP                            ( M1_RRESP                 )           ,                      
                 .RLAST                            ( M1_RLAST                 )           ,                      
                 .RVALID                           ( M1_RVALID                )           ,                      
                 .RREADY                           ( M1_RREADY                )           ,                      

                 .M1_AWID                          ( w_M1_AWID                )           ,                      
                 .M1_AWADDR                        ( w_M1_AWADDR              )           ,                      
                 .M1_AWLEN                         ( w_M1_AWLEN               )           ,                      
                 .M1_AWLOCK                        ( w_M1_AWLOCK              )           ,                      
                 .M1_AWSIZE                        ( w_M1_AWSIZE              )           ,                      
                 .M1_AWBURST                       ( w_M1_AWBURST             )           ,                      
                 .M1_AWPROT                        ( w_M1_AWPROT              )           ,                      
                 .M1_AWVALID                       ( w_M1_AWVALID             )           ,                      
                 .M1_AWREADY                       ( w_M1_AWREADY             )           ,                      
                 .M1_AWQOS                         ( w_M1_AWQOS               )           ,                      
                 .M1_AWREGION                      ( w_M1_AWREGION            )           ,                      
                 .M1_WDATA                         ( w_M1_WDATA               )           ,                      
                 .M1_WSTRB                         ( w_M1_WSTRB               )           ,                      
                 .M1_WLAST                         ( w_M1_WLAST               )           ,                      
                 .M1_WVALID                        ( w_M1_WVALID              )           ,                      
                 .M1_WREADY                        ( w_M1_WREADY              )           ,                      
                 .M1_BID                           ( w_M1_BID                 )           ,                      
                 .M1_BRESP                         ( w_M1_BRESP               )           ,                      
                 .M1_BVALID                        ( w_M1_BVALID              )           ,                      
                 .M1_BREADY                        ( w_M1_BREADY              )           ,                      
                 .M1_ARID                          ( w_M1_ARID                )           ,                      
                 .M1_ARADDR                        ( w_M1_ARADDR              )           ,                      
                 .M1_ARLEN                         ( w_M1_ARLEN               )           ,                      
                 .M1_ARLOCK                        ( w_M1_ARLOCK              )           ,                      
                 .M1_ARSIZE                        ( w_M1_ARSIZE              )           ,                      
                 .M1_ARBURST                       ( w_M1_ARBURST             )           ,                      
                 .M1_ARPROT                        ( w_M1_ARPROT              )           ,                      
                 .M1_ARVALID                       ( w_M1_ARVALID             )           ,                      
                 .M1_ARREADY                       ( w_M1_ARREADY             )           ,                      
                 .M1_ARQOS                         ( w_M1_ARQOS               )           ,                      
                 .M1_ARREGION                      ( w_M1_ARREGION            )           ,                      
                 .M1_RID                           ( w_M1_RID                 )           ,                      
                 .M1_RDATA                         ( w_M1_RDATA               )           ,                      
                 .M1_RRESP                         ( w_M1_RRESP               )           ,                      
                 .M1_RLAST                         ( w_M1_RLAST               )           ,                      
                 .M1_RVALID                        ( w_M1_RVALID              )           ,                      
                 .M1_RREADY                        ( w_M1_RREADY              )                                 
                );
          ///////////////////////////////////////////////////////////////////////////////////////      

          //    AXI_MASTER_2_SLAVE_ROUTER MODULE INSTANTIATION
          axi_master_2_slave_router
                #(
                  .WIDTH_ID     ( WIDTH_ID )         , 
                  .WIDTH_DA     ( WIDTH_DA )         ,
                  .WIDTH_AD     ( WIDTH_AD )         ,
                  .WIDTH_DS     ( WIDTH_DS )         
                 )
          axi_master_2_slave_router_inst
                (
                 .axi_master_2_slave_router_clk    ( axi_m4s7_NOC_arbiter_top_clk  )           ,
                 .axi_master_2_slave_router_rstn   ( axi_m4s7_NOC_arbiter_top_rstn )           ,

                 .AWID                             ( M2_AWID                  )           ,                      
                 .AWADDR                           ( M2_AWADDR                )           ,                      
                 .AWLEN                            ( M2_AWLEN                 )           ,                      
                 .AWLOCK                           ( M2_AWLOCK                )           ,                      
                 .AWSIZE                           ( M2_AWSIZE                )           ,                      
                 .AWBURST                          ( M2_AWBURST               )           ,                      
                 .AWPROT                           ( M2_AWPROT                )           ,                      
                 .AWVALID                          ( M2_AWVALID               )           ,                      
                 .AWREADY                          ( M2_AWREADY               )           ,                      
                 .AWQOS                            ( M2_AWQOS                 )           ,                      
                 .AWREGION                         ( M2_AWREGION              )           ,                      
                 .WDATA                            ( M2_WDATA                 )           ,                      
                 .WSTRB                            ( M2_WSTRB                 )           ,                      
                 .WLAST                            ( M2_WLAST                 )           ,                      
                 .WVALID                           ( M2_WVALID                )           ,                      
                 .WREADY                           ( M2_WREADY                )           ,                      
                 .BID                              ( M2_BID                   )           ,                      
                 .BRESP                            ( M2_BRESP                 )           ,                      
                 .BVALID                           ( M2_BVALID                )           ,                      
                 .BREADY                           ( M2_BREADY                )           ,                      
                 .ARID                             ( M2_ARID                  )           ,                      
                 .ARADDR                           ( M2_ARADDR                )           ,                      
                 .ARLEN                            ( M2_ARLEN                 )           ,                      
                 .ARLOCK                           ( M2_ARLOCK                )           ,                      
                 .ARSIZE                           ( M2_ARSIZE                )           ,                      
                 .ARBURST                          ( M2_ARBURST               )           ,                      
                 .ARPROT                           ( M2_ARPROT                )           ,                      
                 .ARVALID                          ( M2_ARVALID               )           ,                      
                 .ARREADY                          ( M2_ARREADY               )           ,                      
                 .ARQOS                            ( M2_ARQOS                 )           ,                      
                 .ARREGION                         ( M2_ARREGION              )           ,                      
                 .RID                              ( M2_RID                   )           ,                      
                 .RDATA                            ( M2_RDATA                 )           ,                      
                 .RRESP                            ( M2_RRESP                 )           ,                      
                 .RLAST                            ( M2_RLAST                 )           ,                      
                 .RVALID                           ( M2_RVALID                )           ,                      
                 .RREADY                           ( M2_RREADY                )           ,                      

                 .M2_AWID                          ( w_M2_AWID                )           ,                      
                 .M2_AWADDR                        ( w_M2_AWADDR              )           ,                      
                 .M2_AWLEN                         ( w_M2_AWLEN               )           ,                      
                 .M2_AWLOCK                        ( w_M2_AWLOCK              )           ,                      
                 .M2_AWSIZE                        ( w_M2_AWSIZE              )           ,                      
                 .M2_AWBURST                       ( w_M2_AWBURST             )           ,                      
                 .M2_AWPROT                        ( w_M2_AWPROT              )           ,                      
                 .M2_AWVALID                       ( w_M2_AWVALID             )           ,                      
                 .M2_AWREADY                       ( w_M2_AWREADY             )           ,                      
                 .M2_AWQOS                         ( w_M2_AWQOS               )           ,                      
                 .M2_AWREGION                      ( w_M2_AWREGION            )           ,                      
                 .M2_WDATA                         ( w_M2_WDATA               )           ,                      
                 .M2_WSTRB                         ( w_M2_WSTRB               )           ,                      
                 .M2_WLAST                         ( w_M2_WLAST               )           ,                      
                 .M2_WVALID                        ( w_M2_WVALID              )           ,                      
                 .M2_WREADY                        ( w_M2_WREADY              )           ,                      
                 .M2_BID                           ( w_M2_BID                 )           ,                      
                 .M2_BRESP                         ( w_M2_BRESP               )           ,                      
                 .M2_BVALID                        ( w_M2_BVALID              )           ,                      
                 .M2_BREADY                        ( w_M2_BREADY              )           ,                      
                 .M2_ARID                          ( w_M2_ARID                )           ,                      
                 .M2_ARADDR                        ( w_M2_ARADDR              )           ,                      
                 .M2_ARLEN                         ( w_M2_ARLEN               )           ,                      
                 .M2_ARLOCK                        ( w_M2_ARLOCK              )           ,                      
                 .M2_ARSIZE                        ( w_M2_ARSIZE              )           ,                      
                 .M2_ARBURST                       ( w_M2_ARBURST             )           ,                      
                 .M2_ARPROT                        ( w_M2_ARPROT              )           ,                      
                 .M2_ARVALID                       ( w_M2_ARVALID             )           ,                      
                 .M2_ARREADY                       ( w_M2_ARREADY             )           ,                      
                 .M2_ARQOS                         ( w_M2_ARQOS               )           ,                      
                 .M2_ARREGION                      ( w_M2_ARREGION            )           ,                      
                 .M2_RID                           ( w_M2_RID                 )           ,                      
                 .M2_RDATA                         ( w_M2_RDATA               )           ,                      
                 .M2_RRESP                         ( w_M2_RRESP               )           ,                      
                 .M2_RLAST                         ( w_M2_RLAST               )           ,                      
                 .M2_RVALID                        ( w_M2_RVALID              )           ,                      
                 .M2_RREADY                        ( w_M2_RREADY              )                                 
                );
          //////////////////////////////////////////////////////////////////////////////////////      

          //    AXI_MASTER_3_SLAVE_ROUTER MODULE INSTANTIATION
          axi_master_3_slave_router
                #(
                  .WIDTH_ID     ( WIDTH_ID )         , 
                  .WIDTH_DA     ( WIDTH_DA )         ,
                  .WIDTH_AD     ( WIDTH_AD )         ,
                  .WIDTH_DS     ( WIDTH_DS )         
                 )
          axi_master_3_slave_router_inst
                (
                 .axi_master_3_slave_router_clk    ( axi_m4s7_NOC_arbiter_top_clk  )           ,    
                 .axi_master_3_slave_router_rstn   ( axi_m4s7_NOC_arbiter_top_rstn )           ,

                 .AWID                             ( M3_AWID                  )           ,                      
                 .AWADDR                           ( M3_AWADDR                )           ,                      
                 .AWLEN                            ( M3_AWLEN                 )           ,                      
                 .AWLOCK                           ( M3_AWLOCK                )           ,                      
                 .AWSIZE                           ( M3_AWSIZE                )           ,                      
                 .AWBURST                          ( M3_AWBURST               )           ,                      
                 .AWPROT                           ( M3_AWPROT                )           ,                      
                 .AWVALID                          ( M3_AWVALID               )           ,                      
                 .AWREADY                          ( M3_AWREADY               )           ,                      
                 .AWQOS                            ( M3_AWQOS                 )           ,                      
                 .AWREGION                         ( M3_AWREGION              )           ,                      
                 .WDATA                            ( M3_WDATA                 )           ,                      
                 .WSTRB                            ( M3_WSTRB                 )           ,                      
                 .WLAST                            ( M3_WLAST                 )           ,                      
                 .WVALID                           ( M3_WVALID                )           ,                      
                 .WREADY                           ( M3_WREADY                )           ,                      
                 .BID                              ( M3_BID                   )           ,                      
                 .BRESP                            ( M3_BRESP                 )           ,                      
                 .BVALID                           ( M3_BVALID                )           ,                      
                 .BREADY                           ( M3_BREADY                )           ,                      
                 .ARID                             ( M3_ARID                  )           ,                      
                 .ARADDR                           ( M3_ARADDR                )           ,                      
                 .ARLEN                            ( M3_ARLEN                 )           ,                      
                 .ARLOCK                           ( M3_ARLOCK                )           ,                      
                 .ARSIZE                           ( M3_ARSIZE                )           ,                      
                 .ARBURST                          ( M3_ARBURST               )           ,                      
                 .ARPROT                           ( M3_ARPROT                )           ,                      
                 .ARVALID                          ( M3_ARVALID               )           ,                      
                 .ARREADY                          ( M3_ARREADY               )           ,                      
                 .ARQOS                            ( M3_ARQOS                 )           ,                      
                 .ARREGION                         ( M3_ARREGION              )           ,                      
                 .RID                              ( M3_RID                   )           ,                      
                 .RDATA                            ( M3_RDATA                 )           ,                      
                 .RRESP                            ( M3_RRESP                 )           ,                      
                 .RLAST                            ( M3_RLAST                 )           ,                      
                 .RVALID                           ( M3_RVALID                )           ,                      
                 .RREADY                           ( M3_RREADY                )           ,                      

                 .M3_AWID                          ( w_M3_AWID                )           ,                      
                 .M3_AWADDR                        ( w_M3_AWADDR              )           ,                      
                 .M3_AWLEN                         ( w_M3_AWLEN               )           ,                      
                 .M3_AWLOCK                        ( w_M3_AWLOCK              )           ,                      
                 .M3_AWSIZE                        ( w_M3_AWSIZE              )           ,                      
                 .M3_AWBURST                       ( w_M3_AWBURST             )           ,                      
                 .M3_AWPROT                        ( w_M3_AWPROT              )           ,                      
                 .M3_AWVALID                       ( w_M3_AWVALID             )           ,                      
                 .M3_AWREADY                       ( w_M3_AWREADY             )           ,                      
                 .M3_AWQOS                         ( w_M3_AWQOS               )           ,                      
                 .M3_AWREGION                      ( w_M3_AWREGION            )           ,                      
                 .M3_WDATA                         ( w_M3_WDATA               )           ,                      
                 .M3_WSTRB                         ( w_M3_WSTRB               )           ,                      
                 .M3_WLAST                         ( w_M3_WLAST               )           ,                      
                 .M3_WVALID                        ( w_M3_WVALID              )           ,                      
                 .M3_WREADY                        ( w_M3_WREADY              )           ,                      
                 .M3_BID                           ( w_M3_BID                 )           ,                      
                 .M3_BRESP                         ( w_M3_BRESP               )           ,                      
                 .M3_BVALID                        ( w_M3_BVALID              )           ,                      
                 .M3_BREADY                        ( w_M3_BREADY              )           ,                      
                 .M3_ARID                          ( w_M3_ARID                )           ,                      
                 .M3_ARADDR                        ( w_M3_ARADDR              )           ,                      
                 .M3_ARLEN                         ( w_M3_ARLEN               )           ,                      
                 .M3_ARLOCK                        ( w_M3_ARLOCK              )           ,                      
                 .M3_ARSIZE                        ( w_M3_ARSIZE              )           ,                      
                 .M3_ARBURST                       ( w_M3_ARBURST             )           ,                      
                 .M3_ARPROT                        ( w_M3_ARPROT              )           ,                      
                 .M3_ARVALID                       ( w_M3_ARVALID             )           ,                      
                 .M3_ARREADY                       ( w_M3_ARREADY             )           ,                      
                 .M3_ARQOS                         ( w_M3_ARQOS               )           ,                      
                 .M3_ARREGION                      ( w_M3_ARREGION            )           ,                      
                 .M3_RID                           ( w_M3_RID                 )           ,                      
                 .M3_RDATA                         ( w_M3_RDATA               )           ,                      
                 .M3_RRESP                         ( w_M3_RRESP               )           ,                      
                 .M3_RLAST                         ( w_M3_RLAST               )           ,                      
                 .M3_RVALID                        ( w_M3_RVALID              )           ,                      
                 .M3_RREADY                        ( w_M3_RREADY              )                                 
                ); 
           //////////////////////////////////////////////////////////////////////////////////     

           //   AMBA_AXI_M4S7 MODULE INSTANTIATION
           amba_axi_m4s7
               #(
                 .NUM_MASTER    ( NUM_MASTER   )     ,   
                 .NUM_SLAVE     ( NUM_SLAVE    )     , 
                 .WIDTH_CID     ( WIDTH_CID    )     , 
                 .WIDTH_ID      ( WIDTH_ID     )     , 
                 .WIDTH_AD      ( WIDTH_AD     )     , 
                 .WIDTH_DA      ( WIDTH_DA     )     , 
                 .WIDTH_DS      ( WIDTH_DS     )     , 
                 .WIDTH_SID     ( WIDTH_SID    )     , 
                 .SLAVE_EN0     ( SLAVE_EN0    )     ,
                 .ADDR_LENGTH0  ( ADDR_LENGTH0 )     ,
                 .SLAVE_EN1     ( SLAVE_EN1    )     ,
                 .ADDR_LENGTH1  ( ADDR_LENGTH1 )     ,
                 .SLAVE_EN2     ( SLAVE_EN2    )     ,
                 .ADDR_LENGTH2  ( ADDR_LENGTH2 )     ,
                 .SLAVE_EN3     ( SLAVE_EN3    )     ,
                 .ADDR_LENGTH3  ( ADDR_LENGTH3 )     ,
                 .SLAVE_EN4     ( SLAVE_EN4    )     ,
                 .ADDR_LENGTH4  ( ADDR_LENGTH4 )     ,
                 .SLAVE_EN5     ( SLAVE_EN5    )     ,
                 .ADDR_LENGTH5  ( ADDR_LENGTH5 )     ,
                 .SLAVE_EN6     ( SLAVE_EN6    )     ,
                 .ADDR_LENGTH6  ( ADDR_LENGTH6 )     ,
                 .ADDR_BASE0    ( ADDR_BASE0   )     , 
                 .ADDR_BASE1    ( ADDR_BASE1   )     ,
                 .ADDR_BASE2    ( ADDR_BASE2   )     ,
                 .ADDR_BASE3    ( ADDR_BASE3   )     ,
                 .ADDR_BASE4    ( ADDR_BASE4   )     ,
                 .ADDR_BASE5    ( ADDR_BASE5   )     ,
                 .ADDR_BASE6    ( ADDR_BASE6   )     
                )
           amba_axi_m4s7_inst
                (
                 .ARESETn           (   axi_m4s7_NOC_arbiter_top_rstn    )   ,   
                 .ACLK              (   axi_m4s7_NOC_arbiter_top_clk     )   ,
                                                     
                 .M0_AWID           (   M0_AWID                     )   ,
                 .M0_AWADDR         (   M0_AWADDR                   )   ,
                 .M0_AWLEN          (   M0_AWLEN                    )   ,
                 .M0_AWLOCK         (   M0_AWLOCK                   )   ,
                 .M0_AWSIZE         (   M0_AWSIZE                   )   ,
                 .M0_AWBURST        (   M0_AWBURST                  )   ,
                 .M0_AWPROT         (   M0_AWPROT                   )   ,
                 .M0_AWVALID        (   M0_AWVALID                  )   ,
                 .M0_AWREADY        (   M0_AWREADY                  )   ,
                 .M0_AWQOS          (   M0_AWQOS                    )   ,
                 .M0_AWREGION       (   M0_AWREGION                 )   ,
                 .M0_WDATA          (   M0_WDATA                    )   ,
                 .M0_WSTRB          (   M0_WSTRB                    )   ,
                 .M0_WLAST          (   M0_WLAST                    )   ,
                 .M0_WVALID         (   M0_WVALID                   )   ,
                 .M0_WREADY         (   M0_WREADY                   )   ,
                 .M0_BID            (   M0_BID                      )   ,
                 .M0_BRESP          (   M0_BRESP                    )   ,
                 .M0_BVALID         (   M0_BVALID                   )   ,
                 .M0_BREADY         (   M0_BREADY                   )   ,
                 .M0_ARID           (   M0_ARID                     )   ,
                 .M0_ARADDR         (   M0_ARADDR                   )   ,
                 .M0_ARLEN          (   M0_ARLEN                    )   ,
                 .M0_ARLOCK         (   M0_ARLOCK                   )   ,
                 .M0_ARSIZE         (   M0_ARSIZE                   )   ,
                 .M0_ARBURST        (   M0_ARBURST                  )   ,
                 .M0_ARPROT         (   M0_ARPROT                   )   ,
                 .M0_ARVALID        (   M0_ARVALID                  )   ,
                 .M0_ARREADY        (   M0_ARREADY                  )   ,
                 .M0_ARQOS          (   M0_ARQOS                    )   ,
                 .M0_ARREGION       (   M0_ARREGION                 )   ,
                 .M0_RID            (   M0_RID                      )   ,
                 .M0_RDATA          (   M0_RDATA                    )   ,
                 .M0_RRESP          (   M0_RRESP                    )   ,
                 .M0_RLAST          (   M0_RLAST                    )   ,
                 .M0_RVALID         (   M0_RVALID                   )   ,
                 .M0_RREADY         (   M0_RREADY                   )   ,
                               
                 .M1_AWID           (   w_M1_AWID                   )   ,
                 .M1_AWADDR         (   w_M1_AWADDR                 )   ,
                 .M1_AWLEN          (   w_M1_AWLEN                  )   ,
                 .M1_AWLOCK         (   w_M1_AWLOCK                 )   ,
                 .M1_AWSIZE         (   w_M1_AWSIZE                 )   ,
                 .M1_AWBURST        (   w_M1_AWBURST                )   ,                      
                 .M1_AWPROT         (   w_M1_AWPROT                 )   ,                     
                 .M1_AWVALID        (   w_M1_AWVALID                )   ,
                 .M1_AWREADY        (   w_M1_AWREADY                )   ,
                 .M1_AWQOS          (   w_M1_AWQOS                  )   ,
                 .M1_AWREGION       (   w_M1_AWREGION               )   ,
                 .M1_WDATA          (   w_M1_WDATA                  )   ,
                 .M1_WSTRB          (   w_M1_WSTRB                  )   ,
                 .M1_WLAST          (   w_M1_WLAST                  )   ,
                 .M1_WVALID         (   w_M1_WVALID                 )   ,
                 .M1_WREADY         (   w_M1_WREADY                 )   ,
                 .M1_BID            (   w_M1_BID                    )   ,
                 .M1_BRESP          (   w_M1_BRESP                  )   ,
                 .M1_BVALID         (   w_M1_BVALID                 )   ,
                 .M1_BREADY         (   w_M1_BREADY                 )   ,
                 .M1_ARID           (   w_M1_ARID                   )   ,
                 .M1_ARADDR         (   w_M1_ARADDR                 )   ,
                 .M1_ARLEN          (   w_M1_ARLEN                  )   ,
                 .M1_ARLOCK         (   w_M1_ARLOCK                 )   ,
                 .M1_ARSIZE         (   w_M1_ARSIZE                 )   ,
                 .M1_ARBURST        (   w_M1_ARBURST                )   ,
                 .M1_ARPROT         (   w_M1_ARPROT                 )   ,
                 .M1_ARVALID        (   w_M1_ARVALID                )   ,
                 .M1_ARREADY        (   w_M1_ARREADY                )   ,
                 .M1_ARQOS          (   w_M1_ARQOS                  )   ,
                 .M1_ARREGION       (   w_M1_ARREGION               )   ,
                 .M1_RID            (   w_M1_RID                    )   ,
                 .M1_RDATA          (   w_M1_RDATA                  )   ,
                 .M1_RRESP          (   w_M1_RRESP                  )   ,
                 .M1_RLAST          (   w_M1_RLAST                  )   ,
                 .M1_RVALID         (   w_M1_RVALID                 )   ,
                 .M1_RREADY         (   w_M1_RREADY                 )   ,
                             
                 .M2_AWID           (   w_M2_AWID                   )   ,
                 .M2_AWADDR         (   w_M2_AWADDR                 )   ,
                 .M2_AWLEN          (   w_M2_AWLEN                  )   ,
                 .M2_AWLOCK         (   w_M2_AWLOCK                 )   ,
                 .M2_AWSIZE         (   w_M2_AWSIZE                 )   ,
                 .M2_AWBURST        (   w_M2_AWBURST                )   ,
                 .M2_AWPROT         (   w_M2_AWPROT                 )   ,
                 .M2_AWVALID        (   w_M2_AWVALID                )   ,
                 .M2_AWREADY        (   w_M2_AWREADY                )   ,
                 .M2_AWQOS          (   w_M2_AWQOS                  )   ,
                 .M2_AWREGION       (   w_M2_AWREGION               )   ,
                 .M2_WDATA          (   w_M2_WDATA                  )   ,
                 .M2_WSTRB          (   w_M2_WSTRB                  )   ,
                 .M2_WLAST          (   w_M2_WLAST                  )   ,
                 .M2_WVALID         (   w_M2_WVALID                 )   ,
                 .M2_WREADY         (   w_M2_WREADY                 )   ,
                 .M2_BID            (   w_M2_BID                    )   ,
                 .M2_BRESP          (   w_M2_BRESP                  )   ,
                 .M2_BVALID         (   w_M2_BVALID                 )   ,
                 .M2_BREADY         (   w_M2_BREADY                 )   ,
                 .M2_ARID           (   w_M2_ARID                   )   ,
                 .M2_ARADDR         (   w_M2_ARADDR                 )   ,
                 .M2_ARLEN          (   w_M2_ARLEN                  )   ,
                 .M2_ARLOCK         (   w_M2_ARLOCK                 )   ,
                 .M2_ARSIZE         (   w_M2_ARSIZE                 )   ,
                 .M2_ARBURST        (   w_M2_ARBURST                )   ,
                 .M2_ARPROT         (   w_M2_ARPROT                 )   ,
                 .M2_ARVALID        (   w_M2_ARVALID                )   ,
                 .M2_ARREADY        (   w_M2_ARREADY                )   ,
                 .M2_ARQOS          (   w_M2_ARQOS                  )   ,
                 .M2_ARREGION       (   w_M2_ARREGION               )   ,
                 .M2_RID            (   w_M2_RID                    )   ,
                 .M2_RDATA          (   w_M2_RDATA                  )   ,
                 .M2_RRESP          (   w_M2_RRESP                  )   ,
                 .M2_RLAST          (   w_M2_RLAST                  )   ,
                 .M2_RVALID         (   w_M2_RVALID                 )   ,
                 .M2_RREADY         (   w_M2_RREADY                 )   ,
                          
                 .M3_AWID           (   w_M3_AWID                   )   ,
                 .M3_AWADDR         (   w_M3_AWADDR                 )   ,
                 .M3_AWLEN          (   w_M3_AWLEN                  )   ,
                 .M3_AWLOCK         (   w_M3_AWLOCK                 )   ,
                 .M3_AWSIZE         (   w_M3_AWSIZE                 )   ,
                 .M3_AWBURST        (   w_M3_AWBURST                )   ,
                 .M3_AWPROT         (   w_M3_AWPROT                 )   ,
                 .M3_AWVALID        (   w_M3_AWVALID                )   ,
                 .M3_AWREADY        (   w_M3_AWREADY                )   ,
                 .M3_AWQOS          (   w_M3_AWQOS                  )   ,
                 .M3_AWREGION       (   w_M3_AWREGION               )   ,
                 .M3_WDATA          (   w_M3_WDATA                  )   ,
                 .M3_WSTRB          (   w_M3_WSTRB                  )   ,
                 .M3_WLAST          (   w_M3_WLAST                  )   ,
                 .M3_WVALID         (   w_M3_WVALID                 )   ,
                 .M3_WREADY         (   w_M3_WREADY                 )   ,
                 .M3_BID            (   w_M3_BID                    )   ,
                 .M3_BRESP          (   w_M3_BRESP                  )   ,
                 .M3_BVALID         (   w_M3_BVALID                 )   ,
                 .M3_BREADY         (   w_M3_BREADY                 )   ,
                 .M3_ARID           (   w_M3_ARID                   )   ,
                 .M3_ARADDR         (   w_M3_ARADDR                 )   ,
                 .M3_ARLEN          (   w_M3_ARLEN                  )   ,
                 .M3_ARLOCK         (   w_M3_ARLOCK                 )   ,
                 .M3_ARSIZE         (   w_M3_ARSIZE                 )   ,
                 .M3_ARBURST        (   w_M3_ARBURST                )   ,
                 .M3_ARPROT         (   w_M3_ARPROT                 )   ,
                 .M3_ARVALID        (   w_M3_ARVALID                )   ,
                 .M3_ARREADY        (   w_M3_ARREADY                )   ,
                 .M3_ARQOS          (   w_M3_ARQOS                  )   ,
                 .M3_ARREGION       (   w_M3_ARREGION               )   ,
                 .M3_RID            (   w_M3_RID                    )   ,
                 .M3_RDATA          (   w_M3_RDATA                  )   ,
                 .M3_RRESP          (   w_M3_RRESP                  )   ,
                 .M3_RLAST          (   w_M3_RLAST                  )   ,
                 .M3_RVALID         (   w_M3_RVALID                 )   ,
                 .M3_RREADY         (   w_M3_RREADY                 )   ,
                      
                 .S0_AWID           (   S0_AWID                     )   , 
                 .S0_AWADDR         (   S0_AWADDR                   )   ,
                 .S0_AWLEN          (   S0_AWLEN                    )   ,
                 .S0_AWLOCK         (   S0_AWLOCK                   )   ,
                 .S0_AWSIZE         (   S0_AWSIZE                   )   ,
                 .S0_AWBURST        (   S0_AWBURST                  )   ,
                 .S0_AWPROT         (   S0_AWPROT                   )   ,
                 .S0_AWVALID        (   S0_AWVALID                  )   ,
                 .S0_AWREADY        (   S0_AWREADY                  )   ,
                 .S0_AWQOS          (   S0_AWQOS                    )   ,
                 .S0_AWREGION       (   S0_AWREGION                 )   ,
                 .S0_WDATA          (   S0_WDATA                    )   ,
                 .S0_WSTRB          (   S0_WSTRB                    )   ,
                 .S0_WLAST          (   S0_WLAST                    )   ,
                 .S0_WVALID         (   S0_WVALID                   )   ,
                 .S0_WREADY         (   S0_WREADY                   )   ,
                 .S0_BID            (   S0_BID                      )   ,
                 .S0_BRESP          (   S0_BRESP                    )   ,
                 .S0_BVALID         (   S0_BVALID                   )   ,
                 .S0_BREADY         (   S0_BREADY                   )   ,
                 .S0_ARID           (   S0_ARID                     )   ,
                 .S0_ARADDR         (   S0_ARADDR                   )   ,
                 .S0_ARLEN          (   S0_ARLEN                    )   ,
                 .S0_ARLOCK         (   S0_ARLOCK                   )   ,
                 .S0_ARSIZE         (   S0_ARSIZE                   )   ,
                 .S0_ARBURST        (   S0_ARBURST                  )   ,
                 .S0_ARPROT         (   S0_ARPROT                   )   ,
                 .S0_ARVALID        (   S0_ARVALID                  )   ,
                 .S0_ARREADY        (   S0_ARREADY                  )   ,
                 .S0_ARQOS          (   S0_ARQOS                    )   ,
                 .S0_ARREGION       (   S0_ARREGION                 )   ,
                 .S0_RID            (   S0_RID                      )   ,
                 .S0_RDATA          (   S0_RDATA                    )   ,
                 .S0_RRESP          (   S0_RRESP                    )   ,
                 .S0_RLAST          (   S0_RLAST                    )   ,
                 .S0_RVALID         (   S0_RVALID                   )   ,
                 .S0_RREADY         (   S0_RREADY                   )   ,
                                        
                 .S1_AWID           (   S1_AWID                     )   ,
                 .S1_AWADDR         (   S1_AWADDR                   )   ,
                 .S1_AWLEN          (   S1_AWLEN                    )   ,
                 .S1_AWLOCK         (   S1_AWLOCK                   )   ,
                 .S1_AWSIZE         (   S1_AWSIZE                   )   ,
                 .S1_AWBURST        (   S1_AWBURST                  )   ,
                 .S1_AWPROT         (   S1_AWPROT                   )   ,
                 .S1_AWVALID        (   S1_AWVALID                  )   ,
                 .S1_AWREADY        (   S1_AWREADY                  )   ,
                 .S1_AWQOS          (   S1_AWQOS                    )   ,
                 .S1_AWREGION       (   S1_AWREGION                 )   ,
                 .S1_WDATA          (   S1_WDATA                    )   ,
                 .S1_WSTRB          (   S1_WSTRB                    )   ,
                 .S1_WLAST          (   S1_WLAST                    )   ,
                 .S1_WVALID         (   S1_WVALID                   )   ,
                 .S1_WREADY         (   S1_WREADY                   )   ,
                 .S1_BID            (   S1_BID                      )   ,
                 .S1_BRESP          (   S1_BRESP                    )   ,
                 .S1_BVALID         (   S1_BVALID                   )   ,
                 .S1_BREADY         (   S1_BREADY                   )   ,
                 .S1_ARID           (   S1_ARID                     )   ,
                 .S1_ARADDR         (   S1_ARADDR                   )   ,
                 .S1_ARLEN          (   S1_ARLEN                    )   ,
                 .S1_ARLOCK         (   S1_ARLOCK                   )   ,
                 .S1_ARSIZE         (   S1_ARSIZE                   )   ,
                 .S1_ARBURST        (   S1_ARBURST                  )   ,
                 .S1_ARPROT         (   S1_ARPROT                   )   ,
                 .S1_ARVALID        (   S1_ARVALID                  )   ,
                 .S1_ARREADY        (   S1_ARREADY                  )   ,
                 .S1_ARQOS          (   S1_ARQOS                    )   ,
                 .S1_ARREGION       (   S1_ARREGION                 )   ,
                 .S1_RID            (   S1_RID                      )   ,
                 .S1_RDATA          (   S1_RDATA                    )   ,
                 .S1_RRESP          (   S1_RRESP                    )   ,
                 .S1_RLAST          (   S1_RLAST                    )   ,
                 .S1_RVALID         (   S1_RVALID                   )   ,
                 .S1_RREADY         (   S1_RREADY                   )   ,
                                          
                 .S2_AWID           (   S2_AWID                     )   ,
                 .S2_AWADDR         (   S2_AWADDR                   )   ,
                 .S2_AWLEN          (   S2_AWLEN                    )   ,
                 .S2_AWLOCK         (   S2_AWLOCK                   )   ,
                 .S2_AWSIZE         (   S2_AWSIZE                   )   ,
                 .S2_AWBURST        (   S2_AWBURST                  )   ,
                 .S2_AWPROT         (   S2_AWPROT                   )   ,
                 .S2_AWVALID        (   S2_AWVALID                  )   ,
                 .S2_AWREADY        (   S2_AWREADY                  )   ,
                 .S2_AWQOS          (   S2_AWQOS                    )   ,
                 .S2_AWREGION       (   S2_AWREGION                 )   ,
                 .S2_WDATA          (   S2_WDATA                    )   ,
                 .S2_WSTRB          (   S2_WSTRB                    )   ,
                 .S2_WLAST          (   S2_WLAST                    )   ,
                 .S2_WVALID         (   S2_WVALID                   )   ,
                 .S2_WREADY         (   S2_WREADY                   )   ,
                 .S2_BID            (   S2_BID                      )   ,
                 .S2_BRESP          (   S2_BRESP                    )   ,
                 .S2_BVALID         (   S2_BVALID                   )   ,
                 .S2_BREADY         (   S2_BREADY                   )   ,
                 .S2_ARID           (   S2_ARID                     )   ,
                 .S2_ARADDR         (   S2_ARADDR                   )   ,
                 .S2_ARLEN          (   S2_ARLEN                    )   ,
                 .S2_ARLOCK         (   S2_ARLOCK                   )   ,
                 .S2_ARSIZE         (   S2_ARSIZE                   )   ,
                 .S2_ARBURST        (   S2_ARBURST                  )   ,
                 .S2_ARPROT         (   S2_ARPROT                   )   ,
                 .S2_ARVALID        (   S2_ARVALID                  )   ,
                 .S2_ARREADY        (   S2_ARREADY                  )   ,
                 .S2_ARQOS          (   S2_ARQOS                    )   ,
                 .S2_ARREGION       (   S2_ARREGION                 )   ,
                 .S2_RID            (   S2_RID                      )   ,
                 .S2_RDATA          (   S2_RDATA                    )   ,
                 .S2_RRESP          (   S2_RRESP                    )   ,
                 .S2_RLAST          (   S2_RLAST                    )   ,
                 .S2_RVALID         (   S2_RVALID                   )   ,
                 .S2_RREADY         (   S2_RREADY                   )   ,
                                        
                 .S3_AWID           (   S3_AWID                     )   ,
                 .S3_AWADDR         (   S3_AWADDR                   )   ,
                 .S3_AWLEN          (   S3_AWLEN                    )   ,
                 .S3_AWLOCK         (   S3_AWLOCK                   )   ,
                 .S3_AWSIZE         (   S3_AWSIZE                   )   ,
                 .S3_AWBURST        (   S3_AWBURST                  )   ,
                 .S3_AWPROT         (   S3_AWPROT                   )   ,
                 .S3_AWVALID        (   S3_AWVALID                  )   ,
                 .S3_AWREADY        (   S3_AWREADY                  )   ,
                 .S3_AWQOS          (   S3_AWQOS                    )   ,
                 .S3_AWREGION       (   S3_AWREGION                 )   ,
                 .S3_WDATA          (   S3_WDATA                    )   ,
                 .S3_WSTRB          (   S3_WSTRB                    )   ,
                 .S3_WLAST          (   S3_WLAST                    )   ,
                 .S3_WVALID         (   S3_WVALID                   )   ,
                 .S3_WREADY         (   S3_WREADY                   )   ,
                 .S3_BID            (   S3_BID                      )   ,
                 .S3_BRESP          (   S3_BRESP                    )   ,
                 .S3_BVALID         (   S3_BVALID                   )   ,
                 .S3_BREADY         (   S3_BREADY                   )   ,
                 .S3_ARID           (   S3_ARID                     )   ,
                 .S3_ARADDR         (   S3_ARADDR                   )   ,
                 .S3_ARLEN          (   S3_ARLEN                    )   ,
                 .S3_ARLOCK         (   S3_ARLOCK                   )   ,
                 .S3_ARSIZE         (   S3_ARSIZE                   )   ,
                 .S3_ARBURST        (   S3_ARBURST                  )   ,
                 .S3_ARPROT         (   S3_ARPROT                   )   ,
                 .S3_ARVALID        (   S3_ARVALID                  )   ,
                 .S3_ARREADY        (   S3_ARREADY                  )   ,
                 .S3_ARQOS          (   S3_ARQOS                    )   ,
                 .S3_ARREGION       (   S3_ARREGION                 )   ,
                 .S3_RID            (   S3_RID                      )   ,
                 .S3_RDATA          (   S3_RDATA                    )   ,
                 .S3_RRESP          (   S3_RRESP                    )   ,
                 .S3_RLAST          (   S3_RLAST                    )   ,
                 .S3_RVALID         (   S3_RVALID                   )   ,
                 .S3_RREADY         (   S3_RREADY                   )   ,
                                     
                 .S4_AWID           (   S4_AWID                     )   ,
                 .S4_AWADDR         (   S4_AWADDR                   )   ,
                 .S4_AWLEN          (   S4_AWLEN                    )   ,
                 .S4_AWLOCK         (   S4_AWLOCK                   )   ,
                 .S4_AWSIZE         (   S4_AWSIZE                   )   ,
                 .S4_AWBURST        (   S4_AWBURST                  )   ,
                 .S4_AWPROT         (   S4_AWPROT                   )   ,
                 .S4_AWVALID        (   S4_AWVALID                  )   ,
                 .S4_AWREADY        (   S4_AWREADY                  )   ,
                 .S4_AWQOS          (   S4_AWQOS                    )   ,
                 .S4_AWREGION       (   S4_AWREGION                 )   ,
                 .S4_WDATA          (   S4_WDATA                    )   ,
                 .S4_WSTRB          (   S4_WSTRB                    )   ,
                 .S4_WLAST          (   S4_WLAST                    )   ,
                 .S4_WVALID         (   S4_WVALID                   )   ,
                 .S4_WREADY         (   S4_WREADY                   )   ,
                 .S4_BID            (   S4_BID                      )   ,
                 .S4_BRESP          (   S4_BRESP                    )   ,
                 .S4_BVALID         (   S4_BVALID                   )   ,
                 .S4_BREADY         (   S4_BREADY                   )   ,
                 .S4_ARID           (   S4_ARID                     )   ,
                 .S4_ARADDR         (   S4_ARADDR                   )   ,
                 .S4_ARLEN          (   S4_ARLEN                    )   ,
                 .S4_ARLOCK         (   S4_ARLOCK                   )   ,
                 .S4_ARSIZE         (   S4_ARSIZE                   )   ,
                 .S4_ARBURST        (   S4_ARBURST                  )   ,
                 .S4_ARPROT         (   S4_ARPROT                   )   ,
                 .S4_ARVALID        (   S4_ARVALID                  )   ,
                 .S4_ARREADY        (   S4_ARREADY                  )   ,
                 .S4_ARQOS          (   S4_ARQOS                    )   ,
                 .S4_ARREGION       (   S4_ARREGION                 )   ,
                 .S4_RID            (   S4_RID                      )   ,
                 .S4_RDATA          (   S4_RDATA                    )   ,
                 .S4_RRESP          (   S4_RRESP                    )   ,
                 .S4_RLAST          (   S4_RLAST                    )   ,
                 .S4_RVALID         (   S4_RVALID                   )   ,
                 .S4_RREADY         (   S4_RREADY                   )   ,
                                        
                 .S5_AWID           (   S5_AWID                     )   ,
                 .S5_AWADDR         (   S5_AWADDR                   )   ,
                 .S5_AWLEN          (   S5_AWLEN                    )   ,
                 .S5_AWLOCK         (   S5_AWLOCK                   )   ,
                 .S5_AWSIZE         (   S5_AWSIZE                   )   ,
                 .S5_AWBURST        (   S5_AWBURST                  )   ,                      
                 .S5_AWPROT         (   S5_AWPROT                   )   ,
                 .S5_AWVALID        (   S5_AWVALID                  )   ,
                 .S5_AWREADY        (   S5_AWREADY                  )   ,
                 .S5_AWQOS          (   S5_AWQOS                    )   ,
                 .S5_AWREGION       (   S5_AWREGION                 )   ,
                 .S5_WDATA          (   S5_WDATA                    )   ,
                 .S5_WSTRB          (   S5_WSTRB                    )   ,
                 .S5_WLAST          (   S5_WLAST                    )   ,
                 .S5_WVALID         (   S5_WVALID                   )   ,
                 .S5_WREADY         (   S5_WREADY                   )   ,
                 .S5_BID            (   S5_BID                      )   ,
                 .S5_BRESP          (   S5_BRESP                    )   ,
                 .S5_BVALID         (   S5_BVALID                   )   ,
                 .S5_BREADY         (   S5_BREADY                   )   ,
                 .S5_ARID           (   S5_ARID                     )   ,
                 .S5_ARADDR         (   S5_ARADDR                   )   ,
                 .S5_ARLEN          (   S5_ARLEN                    )   ,
                 .S5_ARLOCK         (   S5_ARLOCK                   )   ,
                 .S5_ARSIZE         (   S5_ARSIZE                   )   ,
                 .S5_ARBURST        (   S5_ARBURST                  )   ,
                 .S5_ARPROT         (   S5_ARPROT                   )   ,
                 .S5_ARVALID        (   S5_ARVALID                  )   ,
                 .S5_ARREADY        (   S5_ARREADY                  )   ,
                 .S5_ARQOS          (   S5_ARQOS                    )   ,
                 .S5_ARREGION       (   S5_ARREGION                 )   ,
                 .S5_RID            (   S5_RID                      )   ,
                 .S5_RDATA          (   S5_RDATA                    )   ,
                 .S5_RRESP          (   S5_RRESP                    )   ,
                 .S5_RLAST          (   S5_RLAST                    )   ,
                 .S5_RVALID         (   S5_RVALID                   )   ,
                 .S5_RREADY         (   S5_RREADY                   )   ,
                                        
                 .S6_AWID           (   S6_AWID                     )   ,
                 .S6_AWADDR         (   S6_AWADDR                   )   ,
                 .S6_AWLEN          (   S6_AWLEN                    )   ,
                 .S6_AWLOCK         (   S6_AWLOCK                   )   ,
                 .S6_AWSIZE         (   S6_AWSIZE                   )   ,
                 .S6_AWBURST        (   S6_AWBURST                  )   ,
                 .S6_AWPROT         (   S6_AWPROT                   )   ,
                 .S6_AWVALID        (   S6_AWVALID                  )   ,
                 .S6_AWREADY        (   S6_AWREADY                  )   ,
                 .S6_AWQOS          (   S6_AWQOS                    )   ,
                 .S6_AWREGION       (   S6_AWREGION                 )   ,
                 .S6_WDATA          (   S6_WDATA                    )   ,
                 .S6_WSTRB          (   S6_WSTRB                    )   ,
                 .S6_WLAST          (   S6_WLAST                    )   ,
                 .S6_WVALID         (   S6_WVALID                   )   ,
                 .S6_WREADY         (   S6_WREADY                   )   ,
                 .S6_BID            (   S6_BID                      )   ,
                 .S6_BRESP          (   S6_BRESP                    )   ,
                 .S6_BVALID         (   S6_BVALID                   )   ,
                 .S6_BREADY         (   S6_BREADY                   )   ,
                 .S6_ARID           (   S6_ARID                     )   ,
                 .S6_ARADDR         (   S6_ARADDR                   )   ,
                 .S6_ARLEN          (   S6_ARLEN                    )   ,
                 .S6_ARLOCK         (   S6_ARLOCK                   )   ,
                 .S6_ARSIZE         (   S6_ARSIZE                   )   ,
                 .S6_ARBURST        (   S6_ARBURST                  )   ,
                 .S6_ARPROT         (   S6_ARPROT                   )   ,
                 .S6_ARVALID        (   S6_ARVALID                  )   ,
                 .S6_ARREADY        (   S6_ARREADY                  )   ,
                 .S6_ARQOS          (   S6_ARQOS                    )   ,
                 .S6_ARREGION       (   S6_ARREGION                 )   ,  
                 .S6_RID            (   S6_RID                      )   ,
                 .S6_RDATA          (   S6_RDATA                    )   ,
                 .S6_RRESP          (   S6_RRESP                    )   ,
                 .S6_RLAST          (   S6_RLAST                    )   ,
                 .S6_RVALID         (   S6_RVALID                   )   ,
                 .S6_RREADY         (   S6_RREADY                   )   
                ); 


endmodule
