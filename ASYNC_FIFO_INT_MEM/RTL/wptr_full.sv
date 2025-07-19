`timescale 1ns/1ps

module wptr_full #(parameter ADDRESS_WIDTH = 0, DEPTH= 0, SOFT_RESET = 0,DATA_WIDTH=0,STICKY_ERROR=0, RESET_MEM=0, PIPE_WRITE = 0)
		( 
	  output logic                       wfull       ,
          //output logic                     a_full      ,          
	  output logic [ADDRESS_WIDTH :0]    waddr       ,
	  output logic [ADDRESS_WIDTH :0]    wptr        ,
          output logic [ADDRESS_WIDTH :0]    wr_count    ,
          output logic                       wr_overflow ,          
	  input  logic [ADDRESS_WIDTH :0]    wq2_rptr    ,
	  input  logic                       winc        ,
          input  logic                       rinc        ,
          input  logic                       wclk        ,
          input  logic                       hw_rst_n      ,    //w_rst changed to hw_rst_n
          input  logic                       sw_rst     ,
          //input  logic       [4:0]         afull_vl    ,
	  input logic                        mem_rst
          
      );
	
logic  [ADDRESS_WIDTH     :0] wbin              ;
logic  [ADDRESS_WIDTH:0] wr_count_r        ; 
logic  [ADDRESS_WIDTH     :0] wgray_nxt         ;
logic  [ADDRESS_WIDTH     :0] wbin_nxt          ;
logic  [ADDRESS_WIDTH     :0] wbin_nxt_r          ;
logic                   wr_overflow_w     ;
logic [ADDRESS_WIDTH:0] wbin_reg;
logic [ADDRESS_WIDTH:0]wgray_nxt_reg;
logic [ADDRESS_WIDTH:0] wq2_rptr_reg;
logic winc_r;
logic winc_switch;
logic wr_enable;



//.............................................gray style 2 pointer...........................................................//
//............................................................................................................................//
assign wr_enable = (PIPE_WRITE==0) ? 1'b1: 1'b0;

always@(posedge wclk or negedge hw_rst_n)
begin
if (!hw_rst_n)                 //hardware reset
    begin 
        wptr <= {ADDRESS_WIDTH{1'b0}};
        wbin <= {ADDRESS_WIDTH{1'b0}};
	wbin_reg <= {ADDRESS_WIDTH{1'b0}};
    end
    else 
        if (sw_rst && (SOFT_RESET ==2 || SOFT_RESET == 3) )//software reset
    begin 
        wptr <= {ADDRESS_WIDTH{1'b0}};
        wbin <= {ADDRESS_WIDTH{1'b0}};
	wbin_reg <= {ADDRESS_WIDTH{1'b0}};
    end
	/*else if (mem_rst && RESET_MEM==1)
	begin
		wptr <= {ADDRESS_WIDTH{1'b0}};
        	wbin <= {ADDRESS_WIDTH{1'b0}};
	end*/
    else if(!wr_overflow)
    begin 
        wbin <= wbin_nxt  ;
	wbin_reg <= wbin_nxt_r;
        wptr <=  wgray_nxt;
    end
end


//......................................write address pointer...............................................................//
//..........................................................................................................................//
    
assign waddr    = (PIPE_WRITE==0) ? wbin[ADDRESS_WIDTH-1:0] : wbin_reg[ADDRESS_WIDTH-1:0]       ;

//assign wbin_nxt = ( STICKY_ERROR == 1 ) ? (wbin + (winc & ~wfull)) : (wbin + (winc && wfull)  ) ;
assign wbin_nxt = (wbin + (winc & ~wfull))    ;
assign wbin_nxt_r = (wbin_reg + (winc_r & ~wfull))    ;


assign wgray_nxt= (PIPE_WRITE==0) ? ((wbin_nxt >> 1) ^ wbin_nxt) : ((wbin_nxt_r >> 1) ^ wbin_nxt_r) ;

always @(posedge wclk or negedge hw_rst_n)
begin
	if(!hw_rst_n)
	begin
		wgray_nxt_reg <= 0;
		wq2_rptr_reg <= 0;
		winc_r <=0;
	end
	else if (sw_rst && (SOFT_RESET==2 || SOFT_RESET==3))
	begin
		wgray_nxt_reg <= 0;
		wq2_rptr_reg <= 0;
		winc_r <=0;
	end
	else 
	begin
		wgray_nxt_reg <= wgray_nxt;
		wq2_rptr_reg <= wq2_rptr;
		winc_r <= winc;
	end
end

assign wfull_val= (wgray_nxt == {~wq2_rptr[ADDRESS_WIDTH:ADDRESS_WIDTH-1],wq2_rptr[ADDRESS_WIDTH-2 : 0]});
//assign a_full   = (waddr == (DEPTH-1) - afull_vl);
//assign a_full   =(waddr == (DEPTH - afull_vl));
//assign a_full = (!hw_rst_n) ? 0 : (waddr >= afull_vl);




always_ff @( posedge wclk or negedge hw_rst_n)
begin
	if(!hw_rst_n)
	begin
		wfull <= 1'b0;
	   	//wfull_reg <= 1'b0;
	end
    	else if (sw_rst && (SOFT_RESET ==2 || SOFT_RESET ==3))
    		begin 
	    		wfull <= 1'b0;
	    		//wfull_reg <= 1'b0;
		end
	else
	begin
	    	wfull <= wfull_val;
	    	//wfull_reg <= wfull;
	end
end

assign wr_overflow_w  = (PIPE_WRITE==0) ? ((wfull   && winc ) ?    1'b1    :   1'b0) : ((wfull   && winc_r ) ?    1'b1    :   1'b0)    ;
assign winc_switch = (PIPE_WRITE ==0) ? winc : winc_r;


always_ff @(posedge wclk or negedge hw_rst_n) begin
    if (!hw_rst_n) begin
        wr_overflow <= 0;
    end 
    else if (STICKY_ERROR==1) begin
        if (wr_overflow || (wfull && winc_switch && !rinc))  
    		wr_overflow <= 1'b1;  // Latch overflow when STICKY_ERROR is enabled
    end 
    else if (STICKY_ERROR == 0) 
        if(wfull && winc_switch && !rinc)        
        begin
        	wr_overflow <= wr_overflow_w ;
    	end
	else begin
		wr_overflow <= 1'b0;
	end
end


//-------------------------------------------------------------------------------------------------------------------//

always_ff @(posedge wclk or negedge  hw_rst_n)
begin
    if(!hw_rst_n)
    begin
        wr_count_r  <= {DATA_WIDTH{1'b0}} ;
    end
    else 
        if (sw_rst && (SOFT_RESET ==2 || SOFT_RESET == 3))
    begin 
	    wr_count_r  <= {DATA_WIDTH{1'b0}} ;
	end
/*
    else
	if (mem_rst && RESET_MEM ==1)
	begin
		wr_count_r <= {DATA_WIDTH{1'b0}};
	end
*/
    else if (!wr_overflow)
    begin
        if(winc && !wfull)
        begin
            wr_count_r  <= wr_count_r  +1 ; 
        end
        else
        begin
            wr_count_r  <= wr_count_r    ;
        end
    end
end

assign wr_count = wr_count_r ;



endmodule


