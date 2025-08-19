`define AMBA_AXI_PROT
`define AMBA_QOS

module axi_master_2_slave_router
          #(
            parameter  WIDTH_ID = 4     ,
                       WIDTH_DA = 32    ,
                       WIDTH_AD = 32    ,
                       WIDTH_DS = 4     
           )
           (
            input   logic                      axi_master_2_slave_router_clk    ,
            input   logic                      axi_master_2_slave_router_rstn   ,

            //         MASTER_2 SIGNALS 
            input   logic  [WIDTH_ID-1:0]      AWID                             ,                               
            input   logic  [WIDTH_AD-1:0]      AWADDR                           ,  
            input   logic  [ 7:0]              AWLEN                            ,
            input   logic                      AWLOCK                           ,
            input   logic  [ 2:0]              AWSIZE                           ,
            input   logic  [ 1:0]              AWBURST                          ,
           `ifdef AMBA_AXI_PROT
            input   logic  [ 2:0]              AWPROT                           ,   
           `endif
            input   logic                      AWVALID                          ,
            output  logic                      AWREADY                          ,
           `ifdef AMBA_QOS  
            input   logic  [ 3:0]              AWQOS                            ,
            input   logic  [ 3:0]              AWREGION                         ,
           `endif
            input   logic   [WIDTH_DA-1:0]     WDATA                            ,     
            input   logic   [WIDTH_DS-1:0]     WSTRB                            ,
            input   logic                      WLAST                            ,
            input   logic                      WVALID                           , 
            output  logic                      WREADY                           , 

            output  logic   [WIDTH_ID-1:0]     BID                              ,
            output  logic   [ 1:0]             BRESP                            ,    
            output  logic                      BVALID                           ,
            input   logic                      BREADY                           ,

            input   logic   [WIDTH_ID-1:0]     ARID                             ,    
            input   logic   [WIDTH_AD-1:0]     ARADDR                           ,  
            input   logic   [ 7:0]             ARLEN                            ,
            input   logic                      ARLOCK                           ,
            input   logic   [ 2:0]             ARSIZE                           ,
            input   logic   [ 1:0]             ARBURST                          ,
           `ifdef AMBA_AXI_PROT
            input   logic   [ 2:0]             ARPROT                           ,
           `endif
            input   logic                      ARVALID                          ,
            output  logic                      ARREADY                          ,
           `ifdef AMBA_QOS
            input   logic   [ 3:0]             ARQOS                            ,
            input   logic   [ 3:0]             ARREGION                         ,
           `endif
            output  logic   [WIDTH_ID-1:0]     RID                              ,
            output  logic   [WIDTH_DA-1:0]     RDATA                            ,
            output  logic   [ 1:0]             RRESP                            ,
            output  logic                      RLAST                            ,
            output  logic                      RVALID                           ,
            input   logic                      RREADY                           ,                 
           //----------------------------------------------------------- 

            //         MASTER_2 SIGNALS OUTPUT
            output  logic  [WIDTH_ID-1:0]      M2_AWID                          ,                               
            output  logic  [WIDTH_AD-1:0]      M2_AWADDR                        ,  
            output  logic  [ 7:0]              M2_AWLEN                         ,
            output  logic                      M2_AWLOCK                        ,
            output  logic  [ 2:0]              M2_AWSIZE                        ,
            output  logic  [ 1:0]              M2_AWBURST                       ,
           `ifdef AMBA_AXI_PROT
            output  logic  [ 2:0]              M2_AWPROT                        ,   
           `endif
            output  logic                      M2_AWVALID                       ,
            input   logic                      M2_AWREADY                       ,
           `ifdef AMBA_QOS  
            output  logic  [ 3:0]              M2_AWQOS                         ,
            output  logic  [ 3:0]              M2_AWREGION                      ,
           `endif
            output  logic   [WIDTH_DA-1:0]     M2_WDATA                         ,     
            output  logic   [WIDTH_DS-1:0]     M2_WSTRB                         ,
            output  logic                      M2_WLAST                         ,
            output  logic                      M2_WVALID                        , 
            input   logic                      M2_WREADY                        , 

            input   logic   [WIDTH_ID-1:0]     M2_BID                           ,
            input   logic   [ 1:0]             M2_BRESP                         ,    
            input   logic                      M2_BVALID                        ,
            output  logic                      M2_BREADY                        ,

            output  logic   [WIDTH_ID-1:0]     M2_ARID                          ,    
            output  logic   [WIDTH_AD-1:0]     M2_ARADDR                        ,  
            output  logic   [ 7:0]             M2_ARLEN                         ,
            output  logic                      M2_ARLOCK                        ,
            output  logic   [ 2:0]             M2_ARSIZE                        ,
            output  logic   [ 1:0]             M2_ARBURST                       ,
           `ifdef AMBA_AXI_PROT
            output  logic   [ 2:0]             M2_ARPROT                        ,
           `endif
            output  logic                      M2_ARVALID                       ,
            input   logic                      M2_ARREADY                       ,
           `ifdef AMBA_QOS
            output  logic   [ 3:0]             M2_ARQOS                         ,
            output  logic   [ 3:0]             M2_ARREGION                      ,
           `endif
            input   logic   [WIDTH_ID-1:0]     M2_RID                           ,
            input   logic   [WIDTH_DA-1:0]     M2_RDATA                         ,
            input   logic   [ 1:0]             M2_RRESP                         ,
            input   logic                      M2_RLAST                         ,
            input   logic                      M2_RVALID                        ,
            output  logic                      M2_RREADY                        
          );

           //   WRITE TRANSATION INTERNAL DECLERATIONS        
           localparam   [1:0]     STATE_IDLE_WR = 2'd0     ,
                                  STATE_RUN     = 2'd1     ,
                                  STATE_WAIT    = 2'd2     ,
                                  STATE_RESP    = 2'd3     ;
    
           logic  [1:0]   present_state_wr              ;
           logic          slave_0_wr                    ;
           logic          slave_3_wr                    ;
           logic          slave_5_wr                    ;
           logic          slave_6_wr                    ;
           logic          AWREADY_REG                   ;
           logic          WREADY_REG                    ;
           logic  [3:0]   BID_REG                       ;
           logic          BVALID_REG                    ;
           logic          BRESP_REG                     ;
           logic  [8:0]   count_wr                      ;
           logic  [8:0]   awlen_reg                     ;
           logic  [3:0]   awid_reg                      ;
           ////////////////////////////////////////////////////////////////////////////////////////
           
           //      READ TRANSACTION DECLERATIONS 
           localparam   [1:0]     STATE_IDLE_RD = 2'd0     ,
                                  STATE_RUN_RD  = 2'd1     ,
                                  STATE_WAIT_RD = 2'd2     ,
                                  STATE_END     = 2'd3     ;

           logic  [1:0]   present_state_rd              ;
           logic          slave_0_rd                    ;
           logic          slave_3_rd                    ;
           logic          slave_5_rd                    ;
           logic          slave_6_rd                    ;
           logic          ARREADY_REG                   ;
           logic  [3:0]   RID_REG                       ;
           logic          RLAST_REG                     ;
           logic          RVALID_REG                    ;
           logic  [1:0]   RRESP_REG                     ;
           logic  [8:0]   count_rd                      ;
           logic  [8:0]   arlen_reg                     ;
           logic  [3:0]   arid_reg                      ;
           ///////////////////////////////////////////////////////////////////////////////////////
                    
           //                   MASTER 2 WRITE ACCESS LOGIC                            //    
           //  MASTER_2 CAN'T ACCESS THESE SLAVES 
           assign slave_0_wr = ((AWADDR>=32'h0000_0000) && (AWADDR<=32'h0000_0FFF))        ;
           assign slave_3_wr = ((AWADDR>=32'h0000_6000) && (AWADDR<=32'h0000_6FFF))        ;
           assign slave_5_wr = ((AWADDR>=32'h0000_A000) && (AWADDR<=32'h0000_AFFF))        ;
           assign slave_6_wr = ((AWADDR>=32'h0000_C000) && (AWADDR<=32'h0000_CFFF))        ;
           
           always_ff@(posedge axi_master_2_slave_router_clk or negedge axi_master_2_slave_router_rstn) 
           begin

           if(!axi_master_2_slave_router_rstn)
               begin
               present_state_wr <= STATE_IDLE_WR       ;
               AWREADY_REG      <= 1'b0             ;    
               WREADY_REG       <= 1'b0             ;
               BID_REG          <= 4'd0             ;
               BVALID_REG       <= 1'b0             ;
               BRESP_REG        <= 2'd0             ;
               count_wr         <= 9'd0             ;            
               awlen_reg        <= 9'd0             ;
               awid_reg         <= 4'd0             ;
               end
           else
           begin 
                unique case(present_state_wr)
                STATE_IDLE_WR : 
                            begin       
                            if((AWVALID == 1'b1) && (slave_0_wr || slave_3_wr || slave_5_wr || slave_6_wr))
                                begin
                                AWREADY_REG      <= 1'b1            ;
                                present_state_wr <= STATE_RUN       ;
                                end
                            end 
                STATE_RUN  : 
                            begin 
                            if((AWVALID == 1'b1) && (AWREADY == 1'b1))
                                begin
                                AWREADY_REG      <= 1'b0            ;
                                WREADY_REG       <= 1'b1            ;
                                awlen_reg        <= {1'b0,AWLEN}    ;
                                awid_reg         <= AWID            ;
                                present_state_wr <= STATE_WAIT      ;
                                end
                            end
                STATE_WAIT : 
                            begin 
                            if(WVALID == 1'b1)
                                begin
                                if((count_wr>=awlen_reg)||(WLAST == 1'b1))
                                    begin
                                    BID_REG          <= awid_reg        ;
                                    BVALID_REG       <= 1'b1            ;
                                    WREADY_REG       <= 1'b0            ;
                                    count_wr         <= 9'd0            ;
                                    present_state_wr <= STATE_RESP      ;
                                    end
                                else
                                    begin
                                    count_wr <= count_wr + 1'b1          ;
                                    end
                                end
                            end
                STATE_RESP : 
                            begin     
                            if(BREADY == 1'b1)
                                begin
                                BVALID_REG          <= 1'b0        ;
                                BRESP_REG           <= 2'b11       ;
                                if((AWVALID == 1'b1) && (slave_0_wr || slave_3_wr || slave_5_wr || slave_6_wr))
                                    begin
                                    present_state_wr <= STATE_RUN  ;
                                    end
                                else
                                    begin
                                    present_state_wr <= STATE_IDLE_WR ;
                                    end
                                end
                            end
                endcase
           end
           end
       //////////////////////////////////////////////////////////////////////////////////////////////////////    

       //   ASSIGNING ALL THE MASTER_2 WRITE TRANSACTION SIGNALS
       assign M2_AWID       = ((~slave_0_wr || ~slave_3_wr || ~slave_5_wr || ~slave_6_wr) && AWVALID) ? AWID        : 4'd0                ;    
       assign M2_AWADDR     = ((~slave_0_wr || ~slave_3_wr || ~slave_5_wr || ~slave_6_wr) && AWVALID) ? AWADDR      : {WIDTH_AD{1'b0}}    ;       
       assign M2_AWLEN      = ((~slave_0_wr || ~slave_3_wr || ~slave_5_wr || ~slave_6_wr) && AWVALID) ? AWLEN       : 8'd0                ;       
       assign M2_AWLOCK     = ((~slave_0_wr || ~slave_3_wr || ~slave_5_wr || ~slave_6_wr) && AWVALID) ? AWLOCK      : 1'b0                ;
       assign M2_AWSIZE     = ((~slave_0_wr || ~slave_3_wr || ~slave_5_wr || ~slave_6_wr) && AWVALID) ? AWSIZE      : 3'd0                ; 
       assign M2_AWBURST    = ((~slave_0_wr || ~slave_3_wr || ~slave_5_wr || ~slave_6_wr) && AWVALID) ? AWBURST     : 2'd0                ;  
       assign M2_AWPROT     = ((~slave_0_wr || ~slave_3_wr || ~slave_5_wr || ~slave_6_wr) && AWVALID) ? AWPROT      : 3'd0                ; 
       assign M2_AWVALID    = ((~slave_0_wr || ~slave_3_wr || ~slave_5_wr || ~slave_6_wr) && AWVALID) ? AWVALID     : 1'b0                ;
       assign M2_AWQOS      = ((~slave_0_wr || ~slave_3_wr || ~slave_5_wr || ~slave_6_wr) && AWVALID) ? AWQOS       : 4'd0                ;
       assign M2_AWREGION   = ((~slave_0_wr || ~slave_3_wr || ~slave_5_wr || ~slave_6_wr) && AWVALID) ? AWREGION    : 4'd0                ; 
       assign M2_WDATA      =  WDATA          ;
       assign M2_WSTRB      =  WSTRB          ;
       assign M2_WLAST      =  WLAST          ;
       assign M2_WVALID     =  WVALID         ;
       assign M2_BREADY     =  BVALID_REG                      ? 1'b0        : BREADY            ;               
       assign AWREADY       = (present_state_wr == STATE_RUN ) ? AWREADY_REG : M2_AWREADY        ; 
       assign WREADY        = (present_state_wr == STATE_WAIT) ? WREADY_REG  : M2_WREADY         ;    
       assign BID           = (present_state_wr == STATE_RUN ) ? BID_REG     : M2_BID            ;   
       assign BRESP         = (present_state_wr == STATE_RUN ) ? BRESP_REG   : M2_BRESP          ;  
       assign BVALID        = (present_state_wr == STATE_RUN ) ? BVALID_REG  : M2_BVALID         ; 
       /////////////////////////////////////////////////////////////////////////////////////////////

       //                   MASTER 2 READ ACCESS LOGIC                            //    
       //  MASTER_2 CAN'T ACCESS THESE SLAVES 
       assign slave_0_rd = ((ARADDR>=32'h0000_0000) && (ARADDR<=32'h0000_0FFF))        ;
       assign slave_3_rd = ((ARADDR>=32'h0000_6000) && (ARADDR<=32'h0000_6FFF))        ;
       assign slave_5_rd = ((ARADDR>=32'h0000_A000) && (ARADDR<=32'h0000_AFFF))        ;
       assign slave_6_rd = ((ARADDR>=32'h0000_C000) && (ARADDR<=32'h0000_CFFF))        ;
       
       always_ff@(posedge axi_master_2_slave_router_clk or negedge axi_master_2_slave_router_rstn)
       begin

       if(!axi_master_2_slave_router_rstn)
           begin
           ARREADY_REG      <= 1'b0             ;
           RID_REG          <= 4'd0             ;
           RLAST_REG        <= 1'b0             ;
           RVALID_REG       <= 1'b0             ;
           arid_reg         <= 4'd0             ;
           arlen_reg        <= 9'd0             ;
           count_rd         <= 9'd0             ;
           present_state_rd <= STATE_IDLE_RD    ;
           end
       else
           begin
           unique case(present_state_rd)
           STATE_IDLE_RD :  
                          begin      
                          if((ARVALID == 1'b1) && (slave_0_rd || slave_3_rd || slave_5_rd || slave_6_rd))
                              begin
                              ARREADY_REG      <= 1'b1       ;
                              present_state_rd <= STATE_RUN  ;
                              end
                          end   
           STATE_RUN_RD  : 
                          begin      
                          if((ARVALID == 1'b1)&&(ARREADY == 1'b1))
                              begin
                              ARREADY_REG      <= 1'b0                            ;
                              arlen_reg        <= ARLEN + 1'b1                    ;
                              arid_reg         <= ARID                            ;
                              RID_REG          <= ARID                            ;
                              RVALID_REG       <= 1'b1                            ;
                              RRESP_REG        <= 2'b11                           ;
                              RLAST_REG        <= (ARLEN == 8'd0) ? 1'b1 : 1'b0   ;
                              count_rd         <= 9'd2                            ;
                              present_state_rd <= STATE_WAIT                      ;
                              end
                          end
           STATE_WAIT_RD : 
                          begin      
                          if(RREADY == 1'b1)
                              begin
                              if(count_rd>= (arlen_reg+1'b1))
                                  begin
                                  RVALID_REG       <= 1'b0         ;
                                  RLAST_REG        <= 1'b0         ;
                                  RRESP_REG        <= 2'b00        ;
                                  count_rd         <= 9'd0         ;
                                  present_state_rd <= STATE_END    ;
                                  end
                              else
                                  begin
                                  RRESP_REG        <= 2'b10        ;
                                  count_rd <= count_rd + 1'b1      ;
                                  if(count_rd == arlen_reg)
                                      begin
                                      RLAST_REG <= 1'b1            ;
                                      end
                                  end
                              end
                          end
           STATE_END     : 
                          begin      
                          if((ARVALID == 1'b1)&&(slave_0_rd || slave_3_rd || slave_5_rd || slave_6_rd))
                              begin
                              ARREADY_REG      <= 1'b1          ;
                              present_state_rd <= STATE_RUN     ;
                              end
                          else
                              begin
                              present_state_rd <= STATE_IDLE_RD    ;
                              end
                          end
           endcase
           end
       end
       ///////////////////////////////////////////////////////////////////////////////////////////////////////////

       //   ASSIGNING ALL THE MASTER_2 WRITE TRANSACTION SIGNALS
       assign M2_ARID       = ((~slave_0_rd || ~slave_3_rd || ~slave_5_rd || ~slave_6_rd) && ARVALID) ? ARID        : 4'd0             ; 
       assign M2_ARADDR     = ((~slave_0_rd || ~slave_3_rd || ~slave_5_rd || ~slave_6_rd) && ARVALID) ? ARADDR      : {WIDTH_AD{1'b0}} ;
       assign M2_ARLEN      = ((~slave_0_rd || ~slave_3_rd || ~slave_5_rd || ~slave_6_rd) && ARVALID) ? ARLEN       : 8'd0             ;
       assign M2_ARLOCK     = ((~slave_0_rd || ~slave_3_rd || ~slave_5_rd || ~slave_6_rd) && ARVALID) ? ARLOCK      : 1'b0             ;
       assign M2_ARSIZE     = ((~slave_0_rd || ~slave_3_rd || ~slave_5_rd || ~slave_6_rd) && ARVALID) ? ARSIZE      : 3'd0             ;
       assign M2_ARBURST    = ((~slave_0_rd || ~slave_3_rd || ~slave_5_rd || ~slave_6_rd) && ARVALID) ? ARBURST     : 8'd0             ;
       assign M2_ARPROT     = ((~slave_0_rd || ~slave_3_rd || ~slave_5_rd || ~slave_6_rd) && ARVALID) ? ARPROT      : 3'd0             ;
       assign M2_ARVALID    = ((~slave_0_rd || ~slave_3_rd || ~slave_5_rd || ~slave_6_rd) && ARVALID) ? ARVALID     : 1'b0             ;
       assign M2_ARQOS      = ((~slave_0_rd || ~slave_3_rd || ~slave_5_rd || ~slave_6_rd) && ARVALID) ? ARQOS       : 4'd0             ;
       assign M2_ARREGION   = ((~slave_0_rd || ~slave_3_rd || ~slave_5_rd || ~slave_6_rd) && ARVALID) ? ARREGION    : 4'd0             ;
       assign M2_RREADY     = RVALID_REG                          ?  1'b0            : RREADY       ;
       assign ARREADY       = (present_state_rd == STATE_RUN_RD ) ? ARREADY_REG      : M2_ARREADY   ; 
       assign RID           = (present_state_rd == STATE_WAIT_RD) ? RID_REG          : M2_RID       ;
       assign RDATA         = (present_state_rd == STATE_WAIT_RD) ? {WIDTH_DA{1'b0}} : M2_RDATA     ;
       assign RRESP         = (present_state_rd == STATE_WAIT_RD) ? RRESP_REG        : M2_RRESP     ;
       assign RLAST         = (present_state_rd == STATE_WAIT_RD) ? RLAST_REG        : M2_RLAST     ;
       assign RVALID        = (present_state_rd == STATE_WAIT_RD) ? RVALID_REG       : M2_RVALID    ;
       
       /////////////////////////////////////////////////////////////////////////////////////////////////////////////
     
endmodule       
