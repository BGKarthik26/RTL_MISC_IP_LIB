`timescale 1ns/1ps

module rptr_empty #(parameter ADDRESS_WIDTH = 0, DEPTH= 0, DATA_WIDTH = 0, SOFT_RESET = 0, STICKY_ERROR = 0, RESET_MEM =0, PIPE_READ=0)
					(   output  logic                         rdempty      ,
                        //output  logic                         a_empty      ,
                        output  logic      [ADDRESS_WIDTH   :0]   rdaddr       ,
					    output  logic      [ADDRESS_WIDTH     :0]   rptr         ,
                        output  logic      [ADDRESS_WIDTH:0]   rd_count     ,
                        output  logic                         rd_underflow , 
					    input   logic      [ADDRESS_WIDTH     :0]   rq2_wptr     ,
					    input   logic                         rinc         ,
                        input   logic                         winc         ,
                        input   logic                         rclk         ,
                        input   logic                         hw_rst       ,    // rd_rst changed to hw_rst                     
                        input   logic                         soft_rst  ,    //soft_rd_rst changed to soft_rst
                        //input   logic      [4:0]              aempty_val,
			input logic                           mem_rst
                    );

logic [ADDRESS_WIDTH     :0] rbin          ;
logic [ADDRESS_WIDTH:0] rd_count_r    ;
logic [ADDRESS_WIDTH     :0] rgray_nxt     ;
logic [ADDRESS_WIDTH     :0] rbin_nxt      ;
logic                  rd_underflow_w;
logic enable;

logic rinc_r, rinc_switch;
logic [ADDRESS_WIDTH:0]rbin_reg, rgray_nxt_reg, rq2_wptr_reg, rbin_nxt_r ;


always_ff @(posedge rclk or negedge hw_rst)
begin
	if (!hw_rst)
		begin
		    rbin <= {ADDRESS_WIDTH{1'b0}};
		    rptr <= {ADDRESS_WIDTH{1'b0}};
		    rbin_reg <= {ADDRESS_WIDTH{1'b0}};
		end
    else 
        if (soft_rst && (SOFT_RESET == 1 ||SOFT_RESET == 3) )
		begin
		    rbin <= {ADDRESS_WIDTH{1'b0}};
		    rptr <= {ADDRESS_WIDTH{1'b0}};
		    rbin_reg <= {ADDRESS_WIDTH{1'b0}};
		end	
	else if(!rd_underflow)
		begin
		    rbin <= rbin_nxt ;
		    rbin_reg <= rbin_nxt_r;
		    rptr <= rgray_nxt;
		end
end

assign enable = (PIPE_READ==0) ? 1'b1:1'b0;
assign rdaddr    = (PIPE_READ==0) ? rbin[ADDRESS_WIDTH-1:0] : rbin_reg[ADDRESS_WIDTH-1:0]         ;    // addressing binary number to memory 
assign rbin_nxt  = rbin + (rinc & ~rdempty)  ;    // binary count increment
assign rbin_nxt_r = (rbin_reg + (rinc_r & ~rdempty));
assign rgray_nxt = (PIPE_READ==0) ? ((rbin_nxt >>1) ^ rbin_nxt) : (((rbin_nxt_r >>1) ^ rbin_nxt_r) ) ;    // binary to gray conversion
//assign rgray_nxt = ((rbin_nxt >>1) ^ rbin_nxt); 
//..............................empty condition check...................................................................//

assign rdempty_val = (rgray_nxt == rq2_wptr)           ; // read pointer(rgray_nxt) equal to write pointer(wgray_nxt)
//assign a_empty     = (rdaddr == (DEPTH-1) - aempty_val); 
//assign a_empty = (!hw_rst)? 0 : (rdaddr <= aempty_val);

always @(posedge rclk or negedge hw_rst)
begin
	if(!hw_rst)
	begin
		rgray_nxt_reg <= 0;
		rq2_wptr_reg <=0;
		rinc_r <= 0;
	end
	else if (soft_rst && (SOFT_RESET ==1 || SOFT_RESET == 3))
	begin
		rgray_nxt_reg <= 0;
		rq2_wptr_reg <=0;
		rinc_r <= 0;
	end
	else
	begin
		rgray_nxt_reg <= rgray_nxt;
		rq2_wptr_reg <= rq2_wptr;
		rinc_r <= rinc;
	end
end	

//...............................Logic to enable the read empty flag...................................................//

always_ff @(posedge rclk or negedge hw_rst)
begin 
	if (!hw_rst)
	 begin
	    rdempty <=1'b1;
     end
    else
        if (soft_rst && (SOFT_RESET == 1 || SOFT_RESET ==3))
    begin
	   rdempty <=1'b1;
	end
	else
	 begin 
	    rdempty <= rdempty_val;
	end
end

always_ff @(posedge rclk or negedge hw_rst)
begin
    if(!hw_rst)
    begin
        rd_underflow<=0;
    end
 
    else if (STICKY_ERROR==1)
    begin
        if (rd_underflow || ((rdempty && rinc_switch && !winc)))
	begin	
		rd_underflow = 1'b1;
	end
    end

    else
        if(rdempty && rinc_switch && !winc)        
    	begin
        	rd_underflow<= rd_underflow_w ;
    	end
	else
	begin
		rd_underflow <= 1'b0;
	end
   
end    

assign rd_underflow_w = (PIPE_READ==0) ? ((rdempty && rinc )  ?    1'b1    :   1'b0) : ((rdempty && rinc_r) ? 1'b1:1'b0)    ;
//assign rd_underflow_w = ((rdempty && rinc )  ?    1'b1    :   1'b0) ;
assign rinc_switch = (PIPE_READ==0) ? rinc : rinc_r;


//.........................................................................................................................//

always_ff @(posedge rclk or negedge  hw_rst)
begin
    if(!hw_rst)
    begin
        rd_count_r <= {DATA_WIDTH{1'b0}} ;
    end
    else
        if (soft_rst && (SOFT_RESET == 1 || SOFT_RESET ==3))
    begin
	    rd_count_r <= {DATA_WIDTH{1'b0}} ;
	end
    else if (!rd_underflow)
    begin
        if(rinc && !rdempty)
        begin
            rd_count_r <= rd_count_r +1;
        end
        else
        begin
            rd_count_r <= rd_count_r;
        end
    end
end

assign rd_count = rd_count_r;


endmodule


