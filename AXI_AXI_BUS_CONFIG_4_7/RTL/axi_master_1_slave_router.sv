`define AMBA_AXI_PROT
`define AMBA_QOS

module axi_master_1_slave_router
          #(
            parameter  WIDTH_ID = 4     ,
                       WIDTH_DA = 32    ,
                       WIDTH_AD = 32    ,
                       WIDTH_DS = 4     
           )
           (
            input   logic                      axi_master_1_slave_router_clk    ,
            input   logic                      axi_master_1_slave_router_rstn   ,

            //         MASTER_1 SIGNALS 
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

            //         MASTER_1 SIGNALS OUTPUT
            output  logic  [WIDTH_ID-1:0]      M1_AWID                          ,                               
            output  logic  [WIDTH_AD-1:0]      M1_AWADDR                        ,  
            output  logic  [ 7:0]              M1_AWLEN                         ,
            output  logic                      M1_AWLOCK                        ,
            output  logic  [ 2:0]              M1_AWSIZE                        ,
            output  logic  [ 1:0]              M1_AWBURST                       ,
           `ifdef AMBA_AXI_PROT
            output  logic  [ 2:0]              M1_AWPROT                        ,   
           `endif
            output  logic                      M1_AWVALID                       ,
            input   logic                      M1_AWREADY                       ,
           `ifdef AMBA_QOS  
            output  logic  [ 3:0]              M1_AWQOS                         ,
            output  logic  [ 3:0]              M1_AWREGION                      ,
           `endif
            output  logic   [WIDTH_DA-1:0]     M1_WDATA                         ,     
            output  logic   [WIDTH_DS-1:0]     M1_WSTRB                         ,
            output  logic                      M1_WLAST                         ,
            output  logic                      M1_WVALID                        , 
            input   logic                      M1_WREADY                        , 

            input   logic   [WIDTH_ID-1:0]     M1_BID                           ,
            input   logic   [ 1:0]             M1_BRESP                         ,    
            input   logic                      M1_BVALID                        ,
            output  logic                      M1_BREADY                        ,

            output  logic   [WIDTH_ID-1:0]     M1_ARID                          ,    
            output  logic   [WIDTH_AD-1:0]     M1_ARADDR                        ,  
            output  logic   [ 7:0]             M1_ARLEN                         ,
            output  logic                      M1_ARLOCK                        ,
            output  logic   [ 2:0]             M1_ARSIZE                        ,
            output  logic   [ 1:0]             M1_ARBURST                       ,
           `ifdef AMBA_AXI_PROT
            output  logic   [ 2:0]             M1_ARPROT                        ,
           `endif
            output  logic                      M1_ARVALID                       ,
            input   logic                      M1_ARREADY                       ,
           `ifdef AMBA_QOS
            output  logic   [ 3:0]             M1_ARQOS                         ,
            output  logic   [ 3:0]             M1_ARREGION                      ,
           `endif
            input   logic   [WIDTH_ID-1:0]     M1_RID                           ,
            input   logic   [WIDTH_DA-1:0]     M1_RDATA                         ,
            input   logic   [ 1:0]             M1_RRESP                         ,
            input   logic                      M1_RLAST                         ,
            input   logic                      M1_RVALID                        ,
            output  logic                      M1_RREADY                        
          );

           //   WRITE TRANSATION INTERNAL DECLERATIONS        
           localparam   [1:0]     STATE_IDLE_WR = 2'd0     ,
                                  STATE_RUN  = 2'd1     ,
                                  STATE_WAIT = 2'd2     ,
                                  STATE_RESP = 2'd3     ;
    
           logic  [1:0]   present_state_wr              ;
           logic          slave_0_wr                    ;
           logic          slave_2_wr                    ;
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
           logic          slave_2_rd                    ;
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
                    
           //                   MASTER 1 WRITE ACCESS LOGIC                            //    
           //  MASTER_1 CAN'T ACCESS THESE SLAVES 
           assign slave_0_wr = ((AWADDR>=32'h0000_0000) && (AWADDR<=32'h0000_0FFF))        ;
           assign slave_2_wr = ((AWADDR>=32'h0000_4000) && (AWADDR<=32'h0000_4FFF))        ;
           assign slave_5_wr = ((AWADDR>=32'h0000_A000) && (AWADDR<=32'h0000_AFFF))        ;
           assign slave_6_wr = ((AWADDR>=32'h0000_C000) && (AWADDR<=32'h0000_CFFF))        ;
           
           always_ff@(posedge axi_master_1_slave_router_clk or negedge axi_master_1_slave_router_rstn) 
           begin

           if(!axi_master_1_slave_router_rstn)
               begin
               present_state_wr <= STATE_IDLE_WR    ;
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
                            if((AWVALID == 1'b1) && (slave_0_wr || slave_2_wr || slave_5_wr || slave_6_wr))
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
                                if((AWVALID == 1'b1) && (slave_0_wr || slave_2_wr || slave_5_wr || slave_6_wr))
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

       //   ASSIGNING ALL THE MASTER_1 WRITE TRANSACTION SIGNALS
       assign M1_AWID       = ((~slave_0_wr || ~slave_2_wr || ~slave_5_wr || ~slave_6_wr) && AWVALID) ? AWID        : 4'd0                ;    
       assign M1_AWADDR     = ((~slave_0_wr || ~slave_2_wr || ~slave_5_wr || ~slave_6_wr) && AWVALID) ? AWADDR      : {WIDTH_AD{1'b0}}    ;       
       assign M1_AWLEN      = ((~slave_0_wr || ~slave_2_wr || ~slave_5_wr || ~slave_6_wr) && AWVALID) ? AWLEN       : 8'd0                ;       
       assign M1_AWLOCK     = ((~slave_0_wr || ~slave_2_wr || ~slave_5_wr || ~slave_6_wr) && AWVALID) ? AWLOCK      : 1'b0                ;
       assign M1_AWSIZE     = ((~slave_0_wr || ~slave_2_wr || ~slave_5_wr || ~slave_6_wr) && AWVALID) ? AWSIZE      : 3'd0                ; 
       assign M1_AWBURST    = ((~slave_0_wr || ~slave_2_wr || ~slave_5_wr || ~slave_6_wr) && AWVALID) ? AWBURST     : 2'd0                ;  
       assign M1_AWPROT     = ((~slave_0_wr || ~slave_2_wr || ~slave_5_wr || ~slave_6_wr) && AWVALID) ? AWPROT      : 3'd0                ; 
       assign M1_AWVALID    = ((~slave_0_wr || ~slave_2_wr || ~slave_5_wr || ~slave_6_wr) && AWVALID) ? AWVALID     : 1'b0                ;
       assign M1_AWQOS      = ((~slave_0_wr || ~slave_2_wr || ~slave_5_wr || ~slave_6_wr) && AWVALID) ? AWQOS       : 4'd0                ;
       assign M1_AWREGION   = ((~slave_0_wr || ~slave_2_wr || ~slave_5_wr || ~slave_6_wr) && AWVALID) ? AWREGION    : 4'd0                ; 
       assign M1_WDATA      =  WDATA          ;
       assign M1_WSTRB      =  WSTRB          ;
       assign M1_WLAST      =  WLAST          ;
       assign M1_WVALID     =  WVALID         ;
       assign M1_BREADY     =  BVALID_REG                      ? 1'b0        : BREADY             ;        
       assign AWREADY       = (present_state_wr == STATE_RUN ) ? AWREADY_REG : M1_AWREADY         ; 
       assign WREADY        = (present_state_wr == STATE_WAIT) ? WREADY_REG  : M1_WREADY          ;    
       assign BID           = (present_state_wr == STATE_RUN ) ? BID_REG     : M1_BID             ;   
       assign BRESP         = (present_state_wr == STATE_RUN ) ? BRESP_REG   : M1_BRESP           ;  
       assign BVALID        = (present_state_wr == STATE_RUN ) ? BVALID_REG  : M1_BVALID          ; 
       /////////////////////////////////////////////////////////////////////////////////////////////

       //                   MASTER 1 READ ACCESS LOGIC                            //    
       //  MASTER_1 CAN'T ACCESS THESE SLAVES 
       assign slave_0_rd = ((ARADDR>=32'h0000_0000) && (ARADDR<=32'h0000_0FFF))        ;
       assign slave_2_rd = ((ARADDR>=32'h0000_4000) && (ARADDR<=32'h0000_4FFF))        ;
       assign slave_5_rd = ((ARADDR>=32'h0000_A000) && (ARADDR<=32'h0000_AFFF))        ;
       assign slave_6_rd = ((ARADDR>=32'h0000_C000) && (ARADDR<=32'h0000_CFFF))        ;
       
       always_ff@(posedge axi_master_1_slave_router_clk or negedge axi_master_1_slave_router_rstn)
       begin

       if(!axi_master_1_slave_router_rstn)
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
                          if((ARVALID == 1'b1) && (slave_0_rd || slave_2_rd || slave_5_rd || slave_6_rd))
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
                          if((ARVALID == 1'b1) && (slave_0_rd || slave_2_rd || slave_5_rd || slave_6_rd))
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

       //   ASSIGNING ALL THE MASTER_1 WRITE TRANSACTION SIGNALS
       assign M1_ARID       = ((~slave_0_rd || ~slave_2_rd || ~slave_5_rd || ~slave_6_rd) && ARVALID) ? ARID        : 4'd0             ; 
       assign M1_ARADDR     = ((~slave_0_rd || ~slave_2_rd || ~slave_5_rd || ~slave_6_rd) && ARVALID) ? ARADDR      : {WIDTH_AD{1'b0}} ;
       assign M1_ARLEN      = ((~slave_0_rd || ~slave_2_rd || ~slave_5_rd || ~slave_6_rd) && ARVALID) ? ARLEN       : 8'd0             ;
       assign M1_ARLOCK     = ((~slave_0_rd || ~slave_2_rd || ~slave_5_rd || ~slave_6_rd) && ARVALID) ? ARLOCK      : 1'b0             ;
       assign M1_ARSIZE     = ((~slave_0_rd || ~slave_2_rd || ~slave_5_rd || ~slave_6_rd) && ARVALID) ? ARSIZE      : 3'd0             ;
       assign M1_ARBURST    = ((~slave_0_rd || ~slave_2_rd || ~slave_5_rd || ~slave_6_rd) && ARVALID) ? ARBURST     : 8'd0             ;
       assign M1_ARPROT     = ((~slave_0_rd || ~slave_2_rd || ~slave_5_rd || ~slave_6_rd) && ARVALID) ? ARPROT      : 3'd0             ;
       assign M1_ARVALID    = ((~slave_0_rd || ~slave_2_rd || ~slave_5_rd || ~slave_6_rd) && ARVALID) ? ARVALID     : 1'b0             ;
       assign M1_ARQOS      = ((~slave_0_rd || ~slave_2_rd || ~slave_5_rd || ~slave_6_rd) && ARVALID) ? ARQOS       : 4'd0             ;
       assign M1_ARREGION   = ((~slave_0_rd || ~slave_2_rd || ~slave_5_rd || ~slave_6_rd) && ARVALID) ? ARREGION    : 4'd0             ;
       assign M1_RREADY     = RVALID_REG                          ?  1'b0            : RREADY       ;
       assign ARREADY       = (present_state_rd == STATE_RUN_RD ) ? ARREADY_REG      : M1_ARREADY   ; 
       assign RID           = (present_state_rd == STATE_WAIT_RD) ? RID_REG          : M1_RID       ;
       assign RDATA         = (present_state_rd == STATE_WAIT_RD) ? {WIDTH_DA{1'b0}} : M1_RDATA     ;
       assign RRESP         = (present_state_rd == STATE_WAIT_RD) ? RRESP_REG        : M1_RRESP     ;
       assign RLAST         = (present_state_rd == STATE_WAIT_RD) ? RLAST_REG        : M1_RLAST     ;
       assign RVALID        = (present_state_rd == STATE_WAIT_RD) ? RVALID_REG       : M1_RVALID    ;
       /////////////////////////////////////////////////////////////////////////////////////////////////////////////
     
endmodule       
