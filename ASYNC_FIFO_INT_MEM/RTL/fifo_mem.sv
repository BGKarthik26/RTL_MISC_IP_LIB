`timescale 1ns/1ps

module fifomem #(parameter DATA_WIDTH = 0, ADDRESS_WIDTH = 0, DEPTH= 0 , RESET_MEM = 0, PIPE_WRITE  = 0, PIPE_READ = 0,STICKY_ERROR=0,SOFT_RESET=0)
		(
		 output   logic [DATA_WIDTH-1 :0]   rdata     ,
              	 input    logic [DATA_WIDTH-1 :0]   wdata     ,
		 input    logic [ADDRESS_WIDTH  :0] waddr     ,
                 input    logic [ADDRESS_WIDTH  :0] raddr     ,
		 input    logic                             wclk      ,
                 input    logic                             sw_rst   ,  //soft reset   // mem_rst changed to sw_rst
                 input    logic                             rclk      ,
                 input    logic                             wr_en     ,
                 input    logic                             rd_en     ,
                 input    logic                             wfull     ,  
                 input    logic                             hw_rst_n     , //hard reset
                 input    logic                             empty     ,
		 input    logic                             mem_rst   ,  //memory reset
                 input    logic                             wr_overflow,  //Overflow
                 input    logic                             rd_underflow   //Underflow
				 );


logic [DATA_WIDTH-1 :0] rdata_r,rdata_r2 ;
logic [DATA_WIDTH-1 :0] mem [DEPTH-1:0]  ;
logic [DATA_WIDTH-1 :0] wdata_r          ;
integer k;
logic wr_en_r, rd_en_r;	


//--------------------------------LOGIC TO WRITE DATA INTO FIFO------------------------------------------------------------//


always_ff @(posedge wclk or negedge hw_rst_n)
begin
    if(!hw_rst_n)     
    begin
        wdata_r <= {DATA_WIDTH{1'b0}};
    end
    else 
    if(sw_rst  && (SOFT_RESET==2 || SOFT_RESET ==3) )
    begin
        wdata_r <= {DATA_WIDTH{1'b0}};
    end
    else
    begin
        wdata_r <= wdata;
    end

end



always_ff@(posedge wclk or negedge hw_rst_n)
begin
	if(!hw_rst_n)
	begin
		wr_en_r <= 1'b0;
	end
	else
	begin
		wr_en_r <= wr_en;
	end
end


always_ff@(posedge wclk or posedge mem_rst)
begin
     if(mem_rst && RESET_MEM==1 /* && SOFT_RESET==3 */ )
     begin
        for (k = 0 ; k < DEPTH  ; k = k+1)
        begin
            mem[k] <= ({DATA_WIDTH{1'b0}});
        end
    end 	
     else if (!wr_overflow) 
     begin
	if(!wfull && wr_en_r && PIPE_WRITE == 1) 
		begin
       			mem[waddr] <= wdata_r;
       		end
       else
       	if (!wfull && wr_en && PIPE_WRITE == 0)
    	begin
        	mem[waddr] <= wdata;
    	end 
    end
end

  
//----------------------------------LOGIC TO READ DATA FROM FIFO------------------------------------------------//

always_ff@(posedge rclk or negedge hw_rst_n )
begin
    if(!hw_rst_n)
    begin
        rd_en_r <= 1'b0;
    end
    else if(sw_rst && (SOFT_RESET == 1 || SOFT_RESET ==3))
    begin
        rd_en_r <= 1'b0;
    end
    else
	rd_en_r <= rd_en;
end


always_ff@(posedge rclk or negedge hw_rst_n )
begin
    if(!hw_rst_n)
    begin
        rdata_r <= {DATA_WIDTH{1'b0}};
        //rdata   <= {DATA_WIDTH{1'b0}};
    end
    else if(sw_rst && (SOFT_RESET == 1 || SOFT_RESET ==3))
        begin
        rdata_r <= {DATA_WIDTH{1'b0}};
        //rdata   <= {DATA_WIDTH{1'b0}};
        end

    else if (!rd_underflow)
    begin
    	if(!empty && rd_en && PIPE_READ == 0)
    	begin
        	rdata_r <= mem[raddr];
        	//rdata   <= rdata_r   ;
    	end
    	else
        	if(!empty && rd_en && PIPE_READ == 1 )
    		begin
        		//rdata <=rdata_r2;
			rdata_r <= {DATA_WIDTH{1'b0}}; 
    		end
    end
 end

assign rdata = (PIPE_READ==0) ? rdata_r : ((PIPE_READ==1 && !empty && rd_en_r) ? rdata_r2 : {DATA_WIDTH{1'b0}});  

assign  rdata_r2 = (!empty && PIPE_READ == 1) ? mem[raddr] : 0  ;




endmodule



