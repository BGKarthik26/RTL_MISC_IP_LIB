`define AMBA_AXI_PROT
`define AMBA_QOS

module axi_master_3_slave_router
          #(
            parameter  WIDTH_ID = 4     ,
                       WIDTH_DA = 32    ,
                       WIDTH_AD = 32    ,
                       WIDTH_DS = 4     
           )
           (
            input   logic                      axi_master_3_slave_router_clk    ,
            input   logic                      axi_master_3_slave_router_rstn   ,

            //         MASTER_3 SIGNALS 
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

            //         MASTER_3 SIGNALS OUTPUT
            output  logic  [WIDTH_ID-1:0]      M3_AWID                          ,                               
            output  logic  [WIDTH_AD-1:0]      M3_AWADDR                        ,  
            output  logic  [ 7:0]              M3_AWLEN                         ,
            output  logic                      M3_AWLOCK                        ,
            output  logic  [ 2:0]              M3_AWSIZE                        ,
            output  logic  [ 1:0]              M3_AWBURST                       ,
           `ifdef AMBA_AXI_PROT
            output  logic  [ 2:0]              M3_AWPROT                        ,   
           `endif
            output  logic                      M3_AWVALID                       ,
            input   logic                      M3_AWREADY                       ,
           `ifdef AMBA_QOS  
            output  logic  [ 3:0]              M3_AWQOS                         ,
            output  logic  [ 3:0]              M3_AWREGION                      ,
           `endif
            output  logic   [WIDTH_DA-1:0]     M3_WDATA                         ,     
            output  logic   [WIDTH_DS-1:0]     M3_WSTRB                         ,
            output  logic                      M3_WLAST                         ,
            output  logic                      M3_WVALID                        , 
            input   logic                      M3_WREADY                        , 

            input   logic   [WIDTH_ID-1:0]     M3_BID                           ,
            input   logic   [ 1:0]             M3_BRESP                         ,    
            input   logic                      M3_BVALID                        ,
            output  logic                      M3_BREADY                        ,

            output  logic   [WIDTH_ID-1:0]     M3_ARID                          ,    
            output  logic   [WIDTH_AD-1:0]     M3_ARADDR                        ,  
            output  logic   [ 7:0]             M3_ARLEN                         ,
            output  logic                      M3_ARLOCK                        ,
            output  logic   [ 2:0]             M3_ARSIZE                        ,
            output  logic   [ 1:0]             M3_ARBURST                       ,
           `ifdef AMBA_AXI_PROT
            output  logic   [ 2:0]             M3_ARPROT                        ,
           `endif
            output  logic                      M3_ARVALID                       ,
            input   logic                      M3_ARREADY                       ,
           `ifdef AMBA_QOS
            output  logic   [ 3:0]             M3_ARQOS                         ,
            output  logic   [ 3:0]             M3_ARREGION                      ,
           `endif
            input   logic   [WIDTH_ID-1:0]     M3_RID                           ,
            input   logic   [WIDTH_DA-1:0]     M3_RDATA                         ,
            input   logic   [ 1:0]             M3_RRESP                         ,
            input   logic                      M3_RLAST                         ,
            input   logic                      M3_RVALID                        ,
            output  logic                      M3_RREADY                        
          );

           //   WRITE TRANSATION INTERNAL DECLERATIONS        
           localparam   [1:0]     STATE_IDLE_WR = 2'd0     ,
                                  STATE_RUN  = 2'd1     ,
                                  STATE_WAIT = 2'd2     ,
                                  STATE_RESP = 2'd3     ;
    
           logic  [1:0]   present_state_wr              ;
           logic          slave_0_wr                    ;
           logic          slave_2_wr                    ;
           logic          slave_3_wr                    ;
           logic          slave_4_wr                    ;
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
           logic          slave_2_rd                    ;
           logic          slave_3_rd                    ;
           logic          slave_4_rd                    ;
           logic          ARREADY_REG                   ;
           logic  [3:0]   RID_REG                       ;
           logic          RLAST_REG                     ;
           logic          RVALID_REG                    ;
           logic  [1:0]   RRESP_REG                     ;
           logic  [8:0]   count_rd                      ;
           logic  [8:0]   arlen_reg                     ;
           logic  [3:0]   arid_reg                      ;
           ///////////////////////////////////////////////////////////////////////////////////////
                    
           //                   MASTER 3 WRITE ACCESS LOGIC                            //    
           //  MASTER_3 CAN'T ACCESS THESE SLAVES 
           assign slave_0_wr = ((AWADDR>=32'h0000_0000) && (AWADDR<=32'h0000_0FFF))        ;
           assign slave_2_wr = ((AWADDR>=32'h0000_4000) && (AWADDR<=32'h0000_4FFF))        ;
           assign slave_3_wr = ((AWADDR>=32'h0000_6000) && (AWADDR<=32'h0000_6FFF))        ;
           assign slave_4_wr = ((AWADDR>=32'h0000_8000) && (AWADDR<=32'h0000_8FFF))        ;
           
           always_ff@(posedge axi_master_3_slave_router_clk or negedge axi_master_3_slave_router_rstn) 
           begin

           if(!axi_master_3_slave_router_rstn)
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
                            if((AWVALID == 1'b1) && (slave_0_wr || slave_2_wr || slave_3_wr || slave_4_wr))
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
                            if((WVALID == 1'b1))
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
                                if((AWVALID == 1'b1) && (slave_0_wr || slave_2_wr || slave_3_wr || slave_4_wr))
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

       //   ASSIGNING ALL THE MASTER_3 WRITE TRANSACTION SIGNALS
       assign M3_AWID       = ((~slave_0_wr || ~slave_2_wr || ~slave_3_wr || ~slave_4_wr) && AWVALID) ? AWID        : 4'd0                ;    
       assign M3_AWADDR     = ((~slave_0_wr || ~slave_2_wr || ~slave_3_wr || ~slave_4_wr) && AWVALID) ? AWADDR      : {WIDTH_AD{1'b0}}    ;       
       assign M3_AWLEN      = ((~slave_0_wr || ~slave_2_wr || ~slave_3_wr || ~slave_4_wr) && AWVALID) ? AWLEN       : 8'd0                ;       
       assign M3_AWLOCK     = ((~slave_0_wr || ~slave_2_wr || ~slave_3_wr || ~slave_4_wr) && AWVALID) ? AWLOCK      : 1'b0                ;
       assign M3_AWSIZE     = ((~slave_0_wr || ~slave_2_wr || ~slave_3_wr || ~slave_4_wr) && AWVALID) ? AWSIZE      : 3'd0                ; 
       assign M3_AWBURST    = ((~slave_0_wr || ~slave_2_wr || ~slave_3_wr || ~slave_4_wr) && AWVALID) ? AWBURST     : 2'd0                ;  
       assign M3_AWPROT     = ((~slave_0_wr || ~slave_2_wr || ~slave_3_wr || ~slave_4_wr) && AWVALID) ? AWPROT      : 3'd0                ; 
       assign M3_AWVALID    = ((~slave_0_wr || ~slave_2_wr || ~slave_3_wr || ~slave_4_wr) && AWVALID) ? AWVALID     : 1'b0                ;
       assign M3_AWQOS      = ((~slave_0_wr || ~slave_2_wr || ~slave_3_wr || ~slave_4_wr) && AWVALID) ? AWQOS       : 4'd0                ;
       assign M3_AWREGION   = ((~slave_0_wr || ~slave_2_wr || ~slave_3_wr || ~slave_4_wr) && AWVALID) ? AWREGION    : 4'd0                ; 
       assign M3_WDATA      =  WDATA          ;
       assign M3_WSTRB      =  WSTRB          ;
       assign M3_WLAST      =  WLAST          ;
       assign M3_WVALID     =  WVALID         ;
       assign M3_BREADY     =  BVALID_REG                      ? 1'b0        : BREADY             ;        
       assign AWREADY       = (present_state_wr == STATE_RUN ) ? AWREADY_REG : M3_AWREADY         ; 
       assign WREADY        = (present_state_wr == STATE_WAIT) ? WREADY_REG  : M3_WREADY          ;    
       assign BID           = (present_state_wr == STATE_RUN ) ? BID_REG     : M3_BID             ;   
       assign BRESP         = (present_state_wr == STATE_RUN ) ? BRESP_REG   : M3_BRESP           ;  
       assign BVALID        = (present_state_wr == STATE_RUN ) ? BVALID_REG  : M3_BVALID          ;        
       /////////////////////////////////////////////////////////////////////////////////////////////

       //                   MASTER 3 READ ACCESS LOGIC                            //    
       //  MASTER_3 CAN'T ACCESS THESE SLAVES 
       assign slave_0_rd = ((ARADDR>=32'h0000_0000) && (ARADDR<=32'h0000_0FFF))        ;
       assign slave_2_rd = ((ARADDR>=32'h0000_4000) && (ARADDR<=32'h0000_4FFF))        ;
       assign slave_3_rd = ((ARADDR>=32'h0000_6000) && (ARADDR<=32'h0000_6FFF))        ;
       assign slave_4_rd = ((ARADDR>=32'h0000_8000) && (ARADDR<=32'h0000_8FFF))        ;
       
       always_ff@(posedge axi_master_3_slave_router_clk or negedge axi_master_3_slave_router_rstn)
       begin

       if(!axi_master_3_slave_router_rstn)
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
                          if((ARVALID == 1'b1) && (slave_0_rd || slave_2_rd || slave_3_rd || slave_4_rd))
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
                          if((ARVALID == 1'b1)&&(slave_0_rd || slave_2_rd || slave_3_rd || slave_4_rd))
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

       //   ASSIGNING ALL THE MASTER_3 WRITE TRANSACTION SIGNALS
       assign M3_ARID       = ((~slave_0_rd || ~slave_2_rd || ~slave_3_rd || ~slave_4_rd) && ARVALID) ? ARID        : 4'd0             ; 
       assign M3_ARADDR     = ((~slave_0_rd || ~slave_2_rd || ~slave_3_rd || ~slave_4_rd) && ARVALID) ? ARADDR      : {WIDTH_AD{1'b0}} ;
       assign M3_ARLEN      = ((~slave_0_rd || ~slave_2_rd || ~slave_3_rd || ~slave_4_rd) && ARVALID) ? ARLEN       : 8'd0             ;
       assign M3_ARLOCK     = ((~slave_0_rd || ~slave_2_rd || ~slave_3_rd || ~slave_4_rd) && ARVALID) ? ARLOCK      : 1'b0             ;
       assign M3_ARSIZE     = ((~slave_0_rd || ~slave_2_rd || ~slave_3_rd || ~slave_4_rd) && ARVALID) ? ARSIZE      : 3'd0             ;
       assign M3_ARBURST    = ((~slave_0_rd || ~slave_2_rd || ~slave_3_rd || ~slave_4_rd) && ARVALID) ? ARBURST     : 8'd0             ;
       assign M3_ARPROT     = ((~slave_0_rd || ~slave_2_rd || ~slave_3_rd || ~slave_4_rd) && ARVALID) ? ARPROT      : 3'd0             ;
       assign M3_ARVALID    = ((~slave_0_rd || ~slave_2_rd || ~slave_3_rd || ~slave_4_rd) && ARVALID) ? ARVALID     : 1'b0             ;
       assign M3_ARQOS      = ((~slave_0_rd || ~slave_2_rd || ~slave_3_rd || ~slave_4_rd) && ARVALID) ? ARQOS       : 4'd0             ;
       assign M3_ARREGION   = ((~slave_0_rd || ~slave_2_rd || ~slave_3_rd || ~slave_4_rd) && ARVALID) ? ARREGION    : 4'd0             ;
       assign M3_RREADY     = RVALID_REG                          ?  1'b0            : RREADY       ;
       assign ARREADY       = (present_state_rd == STATE_RUN_RD ) ? ARREADY_REG      : M3_ARREADY   ; 
       assign RID           = (present_state_rd == STATE_WAIT_RD) ? RID_REG          : M3_RID       ;
       assign RDATA         = (present_state_rd == STATE_WAIT_RD) ? {WIDTH_DA{1'b0}} : M3_RDATA     ;
       assign RRESP         = (present_state_rd == STATE_WAIT_RD) ? RRESP_REG        : M3_RRESP     ;
       assign RLAST         = (present_state_rd == STATE_WAIT_RD) ? RLAST_REG        : M3_RLAST     ;
       assign RVALID        = (present_state_rd == STATE_WAIT_RD) ? RVALID_REG       : M3_RVALID    ;       
       /////////////////////////////////////////////////////////////////////////////////////////////////////////////
     
endmodule       
