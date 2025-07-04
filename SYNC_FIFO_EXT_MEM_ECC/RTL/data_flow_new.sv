module DataFlowController #(
    parameter DATA_WIDTH = 0,
    parameter ADDR_WIDTH = 0,
    parameter MEM_CTRL_ADDR_WIDTH = 0,
    parameter EXT_MEM_DEPTH = 0,
    parameter SOFT_RESET = 0
)(
    	input logic clk,
    	input logic hw_rst,
	input logic sw_rst,

    	// Enqueue FIFO Interface (Writing to Memory via ECC-MC)
    	output reg en_fifo_rd_en,
    	input logic [DATA_WIDTH-1:0] en_fifo_rd_data,
    	input logic en_fifo_empty,

    	// ECC Memory Controller Interface (New)
    	output reg ECC_ctrl_wr_en,  
    	output reg [MEM_CTRL_ADDR_WIDTH:0] ECC_ctrl_wr_addr_bus,
    	output reg [DATA_WIDTH-1:0] ECC_ctrl_write_data_bus,
    	//input logic [1:0] wr_resp,

    	output logic mem_full,
    	output logic mem_empty,

    	output reg ECC_ctrl_rd_en,
    	output reg [MEM_CTRL_ADDR_WIDTH:0] ECC_ctrl_rd_addr_bus,
    	input logic [DATA_WIDTH-1:0] ECC_ctrl_data_out,
    	//input logic [1:0] rd_resp,

    	output logic mem_almost_empty,
    	output logic mem_almost_full,
    	input logic [MEM_CTRL_ADDR_WIDTH-1:0] almost_full_val,
    	input logic [MEM_CTRL_ADDR_WIDTH-1:0] almost_emp_val,

    	// Dequeue FIFO Interface (Reading from Memory via ECC-MC)
    	input logic top_rd_en,
    	input logic top_wr_en,     
    	output reg dq_fifo_wr_en, 
    	output reg [DATA_WIDTH-1:0] dq_fifo_wr_data,
    	//input logic dq_fifo_full,
    	input logic dq_fifo_empty,
    	output logic dq_fifo_rd_en,

    	output logic overflow,
    	output logic underflow
);

    logic [ADDR_WIDTH:0] wr_lvl;
    logic [ADDR_WIDTH:0] rd_lvl;

	
   	assign mem_empty = (ECC_ctrl_wr_addr_bus==ECC_ctrl_rd_addr_bus);
	assign mem_full = (({~ECC_ctrl_wr_addr_bus[10],ECC_ctrl_wr_addr_bus[ADDR_WIDTH-1:0]} == ECC_ctrl_rd_addr_bus))                   ;      
	assign en_fifo_rd_en = ~en_fifo_empty;
    	assign ECC_ctrl_write_data_bus = en_fifo_rd_data;
    	assign dq_fifo_rd_en = ~dq_fifo_empty;
    	assign dq_fifo_wr_data = ECC_ctrl_data_out;
    	assign mem_almost_full = (wr_lvl >= almost_full_val); 
    	assign mem_almost_empty = (wr_lvl <= almost_emp_val); 

    	// **Write Enable Signal to ECC Memory Controller**
    	always @(posedge clk or negedge hw_rst) 
	begin
        	if (!hw_rst) 
		begin
            		ECC_ctrl_wr_en <= 1'b0;
	    
        	end 
		else if (!sw_rst && SOFT_RESET==1) 
		begin
            		ECC_ctrl_wr_en <= 1'b0;
	    
        	end 
		else if(!overflow && !mem_full) 
		begin
            		ECC_ctrl_wr_en <= en_fifo_rd_en;  
        	end
	    	else 
	    		ECC_ctrl_wr_en <= 1'b0;
    	end

	// **Read Enable Signal to ECC Memory Controller**
    	always @(posedge clk or negedge hw_rst) begin
        	if (!hw_rst) 
		begin
            		ECC_ctrl_rd_en <= 1'b0;
	    
        	end 
		else if (!sw_rst && SOFT_RESET==1) 
		begin
            		ECC_ctrl_rd_en <= 1'b0;
	    
        	end 
		else if(!underflow && !mem_empty) 
		begin
            		ECC_ctrl_rd_en <= top_rd_en;  
        	end
	    	else 
	    		ECC_ctrl_rd_en <= 1'b0;
    	end

    	// **Write Address Generation**
    	always @(posedge clk or negedge hw_rst) 
	begin
        	if (!hw_rst) 
		begin
            		ECC_ctrl_wr_addr_bus <= 0;
        	end
		else if (!sw_rst && SOFT_RESET==1) 
		begin
            		ECC_ctrl_wr_addr_bus <= 0;
        	end  
		else if (ECC_ctrl_wr_en && !mem_full && !overflow) 
		begin  
            		ECC_ctrl_wr_addr_bus <= ECC_ctrl_wr_addr_bus + 1;
        	end
    	end

    	// Read Address Generation
    	always @(posedge clk or negedge hw_rst) begin
        	if (!hw_rst) 
		begin
            		ECC_ctrl_rd_addr_bus <= 0;
        	end
		else if (!sw_rst && SOFT_RESET==1) 
		begin
            		ECC_ctrl_rd_addr_bus <= 0;
        	end  
		else if (ECC_ctrl_rd_en && !mem_empty && !underflow) 
		begin  
            		ECC_ctrl_rd_addr_bus <= ECC_ctrl_rd_addr_bus + 1;
        	end
    	end

    	// Write Enable for Dequeue FIFO
    	always @(posedge clk or negedge hw_rst) begin
        	if (!hw_rst) 
		begin
            		dq_fifo_wr_en <= 1'b0;
        	end 
		else if (!sw_rst && SOFT_RESET==1) 
		begin
            		dq_fifo_wr_en <= 1'b0;
        	end 
		else 
		begin
            		dq_fifo_wr_en <= ECC_ctrl_rd_en; 
        	end
    	end


	//Overflow logic
	always @(posedge clk or negedge hw_rst) 
	begin
		if(!hw_rst) 
		begin
			overflow <= 1'b0;
		end
		else if(!sw_rst && SOFT_RESET ==1) 
		begin
			overflow <= 1'b0;
		end
		else if (mem_full && top_wr_en) 
		begin
			overflow <= 1'b1;
		end
		else
			overflow <= 1'b0;
	end

	//Underflow logic
	always @(posedge clk or negedge hw_rst) 
	begin
		if(!hw_rst)
		begin
			underflow <= 1'b0;
		end
		else if(!sw_rst && SOFT_RESET==1)
		begin
			underflow <= 1'b0;
		end
		else if(mem_empty && top_rd_en) 
		begin
			underflow <= 1'b1;
			//ECC_ctrl_rd_en <= 1'b0;
		end
		else 
		begin
			underflow <= 1'b0;
			//ECC_ctrl_rd_en <= top_rd_en && (data_count>0); 
		end
	end

	always @(posedge clk or negedge hw_rst )
	begin

    		if(!hw_rst)
    		begin
        		wr_lvl  <= 11'd0                                      ;
        		rd_lvl  <= 11'd1023                      ;
    		end

    		else if(!sw_rst && SOFT_RESET==1)
    		begin
        		wr_lvl  <= 11'd0                                      ;
        		rd_lvl  <= 11'd1023                      ;
    		end    

    		else if( (ECC_ctrl_wr_en && ~mem_full) && (ECC_ctrl_rd_en && ~mem_empty) && (~overflow))
    		begin
        		wr_lvl  <= wr_lvl                                       ;
        		rd_lvl  <= rd_lvl                                       ;
    		end

    		else if(ECC_ctrl_wr_en && ~mem_full && (~overflow))
    		begin
        		rd_lvl <= rd_lvl - 1'b1                              ;
        		wr_lvl <= wr_lvl + 1'b1                              ;    
    		end

    		else if(ECC_ctrl_rd_en && ~mem_empty)
    		begin
        		rd_lvl  <= rd_lvl + 1'b1                                ;
        		wr_lvl  <= wr_lvl - 1'b1                                ; 
    		end
	end

/*
	//Generating write_count & read_count logic
	always @(posedge clk or negedge hw_rst) 
	begin
		if(!hw_rst) 
		begin
			write_count <= 1'b0;
			read_count <= 1'b0;
		end
		else 
		begin
			if(mem_we_r && !mem_full && !overflow) 
			begin
				write_count <= write_count +1;
			end
			if (mem_re_r && mem_empty && !underflow) 
			begin
				read_count <= read_count +1;
			end
		end
	end
*/
endmodule


