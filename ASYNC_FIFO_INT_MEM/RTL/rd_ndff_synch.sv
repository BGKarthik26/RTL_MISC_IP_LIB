`timescale 1ns/1ps

module rd_cdc_sync #(parameter ADDRESS_WIDTH = 0, SYNC_STAGE = 0, SOFT_RESET = 0 )
	(output    logic  [ADDRESS_WIDTH:0] sync_out,
     input     logic  [ADDRESS_WIDTH:0] din     ,
	 input     logic              clk     ,
     input     logic              h_rst   ,
     input     logic              s_rst
    );
	 
	 	

logic [ADDRESS_WIDTH:0] q1,q2;

always_ff @( posedge clk or negedge h_rst)
begin
	if (!h_rst)
	begin
	    q1          <= ({ADDRESS_WIDTH{1'b0}});
        q2          <= ({ADDRESS_WIDTH{1'b0}});
	    sync_out    <= ({ADDRESS_WIDTH{1'b0}});
    end
    else 
        if (s_rst && (SOFT_RESET == 1 || SOFT_RESET == 3) )
    begin
	    q1          <= ({ADDRESS_WIDTH{1'b0}});
        q2          <= ({ADDRESS_WIDTH{1'b0}});
   	    sync_out    <= ({ADDRESS_WIDTH{1'b0}});
    end

	else 
        if (SYNC_STAGE == 2)
	begin
    	q1          <= din;
	    sync_out    <= q1 ;
    end
    else 
        if (SYNC_STAGE == 3)
	begin
	    q1          <= din;
        q2          <= q1 ;
	    sync_out    <= q2 ;
    end
end

endmodule


