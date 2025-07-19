//////////////////////////////////////////////////////////////////////////////////
// Company          :   Pravegasemi Pvt Limited
// Engineer         :   Gowthami 	
// 
// Create Date      :   19-07-2023	 
// Design Name      : 	Asynchronous FIFO with internal memory
// Module Name      :     
// Project Name     : 	Asynchronous FIFO with internal memory
// Target Devices   : 
// Tool versions    : 
// Description      : 
//
// Dependencies     : 
//
// Revision         :   1st revision
// Revision             1.1 - File Created
//
// Additional Comments: 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps
module async_fifo_int_mem
#(parameter DATA_WIDTH      =   32  , //  DATA WIDTH 
            ADDRESS_WIDTH   =   5   , //  ADDRESS WIDTH 
            SYNC_STAGE      =   2   , //   Synchronise stage 2 or 3 
            RESET_MEM       =   1   , //    1 - Enable memory reset; 0 - disable memory reset
            SOFT_RESET      =   3   , //   0 - Disable  soft reset, 1 - Based on read clock, 2- Based on write clock, 3 - Dependent on clock asynchronous to write and read clock
            POWER_SAVE      =   1   , //    0 - Disable power save, 1- enable power save 
            STICKY_ERROR    =   0   , //    1 - Expicitly drives overflow & underflow to 1; 0 - Does not drive overflow and underflow
            PIPE_WRITE      =   0   , //    0 - Disable pipe_write,  1- Enable  Pipe_write            
            DEBUG_ENABLE    =   1   , //    0 - Disable, 1- Info, 2 - Warning, 3- Error, 4 - Fatal
            PIPE_READ       =   0     //    0 - Disable pipe_read,  1- Enable pipe_read
            )

(  
output  logic    [DATA_WIDTH-1:0]           read_data           , //    read data from memory
output  logic                               wfull               , //    fifo full
output  logic                               rdempty             , //    fifo empty
output  logic                               wr_almost_ful       , //    fifo almost full check 
output  logic                               rd_almost_empty     , //    fifo almost empty check
output  logic                               overflow            ,
output  logic                               underflow           ,
output  logic     [ADDRESS_WIDTH:0]          fifo_write_count    ,
output  logic     [ADDRESS_WIDTH:0]          fifo_read_count     ,
output  logic     [ADDRESS_WIDTH :0]      wr_level            ,
output  logic     [ADDRESS_WIDTH :0]      rd_level            ,
input   logic                               sw_rst              ,
input   logic     [DATA_WIDTH-1 :0]         wdata               ,
input   logic                               write_enable        ,   
input   logic                               wclk                , 
input   logic                               hw_rst_n              ,
input   logic                               read_enable         ,   
input   logic                               rclk                ,               
input   logic     [ADDRESS_WIDTH-1:0]       afull_value         ,
input   logic     [ADDRESS_WIDTH-1:0]       aempty_value        ,
input   logic                               mem_rst
 
 );

localparam DEPTH = 1 << ADDRESS_WIDTH;

logic [ADDRESS_WIDTH:0]    waddr,raddr                ;
logic [ADDRESS_WIDTH:0]      wptr,rptr,wq2_rptr,rq2_wptr;

logic                        write_clock                ;
logic                        read_clock                 ;
logic                         gate_enable                ;
logic                         wr_overflow_wire;
logic                         rd_underflow_wire;


logic write_mem_en, we_r ;
assign overflow = wr_overflow_wire;
assign underflow = rd_underflow_wire;

assign write_mem_en = write_enable;

/*
always_comb
begin
    if(STICKY_ERROR==1 )
    begin
        write_mem_en = write_enable ; 
    end
  else if(STICKY_ERROR==0)
    begin
        write_mem_en =write_enable;// 
    end
end
*/


always @(posedge wclk or negedge hw_rst_n)
begin
	if(!hw_rst_n)
	begin
		we_r <= 1'b0;
	end
	else
		we_r <= write_enable;
end

//.............................................clock gating w.r.t w_en and r_en.........................................//

always_comb
begin
    if(write_enable==0 && read_enable==0 && POWER_SAVE==1 && PIPE_WRITE==0 && PIPE_READ==0 )
    begin
        gate_enable = 1'b1;
    end
    else if (we_r==0 && read_enable==0 && POWER_SAVE==1 && PIPE_WRITE==1 && PIPE_READ==0 )
    begin
        gate_enable = 1'b1;
    end
    else
    begin
	gate_enable = 1'b0;
    end
end


assign write_clock = gate_enable ? 1'b0 : wclk ;
assign read_clock  = gate_enable ? 1'b0 : rclk ;

//---------------------------------------------------------------------------------------------------------------------------//
//---------------------------------------READ TO WRITE SYNCHRONISER-------------------------------------------------------//
rd_cdc_sync	
#(.ADDRESS_WIDTH(ADDRESS_WIDTH),.SYNC_STAGE(SYNC_STAGE))    

r2w_sync
(    
.sync_out   (wq2_rptr       )   ,
.din        (rptr           )   ,
.clk        (wclk           )   ,
.hw_rst_n   (hw_rst_n       )   ,
.sw_rst     (sw_rst         )
                                                   
 );

//---------------------------------------------------------------------------------------------------------------------------//
//--------------------------------------- WRITE TO READ SYNCHRONISER-------------------------------------------------------//



wr_cdc_sync	
#(.ADDRESS_WIDTH(ADDRESS_WIDTH),.SYNC_STAGE(SYNC_STAGE))    

w2r_sync
(    
.sync_out   (rq2_wptr   )   ,
.din        (wptr       )   ,
.clk        (rclk       )   ,
.hw_rst_n   (hw_rst_n   )   ,
.sw_rst     (sw_rst     )

 );

//---------------------------------------------------------------------------------------------------------------------------//
//--------------------------------------FIFO MEMORY----------------------------------------------------------------//

fifomem 
#(.DATA_WIDTH(DATA_WIDTH),.ADDRESS_WIDTH(ADDRESS_WIDTH),.DEPTH(DEPTH),.RESET_MEM(RESET_MEM),.PIPE_WRITE(PIPE_WRITE),.PIPE_READ(PIPE_READ),.STICKY_ERROR(STICKY_ERROR),.SOFT_RESET(SOFT_RESET))  

fifo_mem
(  
.rdata      (read_data          ),
.wdata      (wdata              ),
.raddr      (raddr              ),
.waddr      (waddr              ),
.wfull      (wfull              ),
.wclk       (write_clock        ),
.rclk       (read_clock         ),
.wr_en      (write_mem_en       ),
.empty      (rdempty            ),
.sw_rst     (sw_rst             ),
.rd_en      (read_enable        ),
.hw_rst_n   ( hw_rst_n          ),
.mem_rst    (mem_rst            ),
.wr_overflow(wr_overflow_wire   ),
.rd_underflow(rd_underflow_wire)										
);

                                        
//---------------------------------------------------------------------------------------------------------------------------//
//--------------------------------------READ EMPTY CHECK ---------------------------------------------------------------------//

rptr_empty
#(.ADDRESS_WIDTH(ADDRESS_WIDTH),.DEPTH(DEPTH),.DATA_WIDTH(DATA_WIDTH),.RESET_MEM(RESET_MEM),.STICKY_ERROR(STICKY_ERROR),.PIPE_READ(PIPE_READ))	
rptr_empty1
 (
.rdempty        (rdempty            ),
.rdaddr         (raddr              ),
.rptr           (rptr               ),
.rq2_wptr       (rq2_wptr           ),
.rinc           (read_enable        ),
.rclk           (rclk               ),
.hw_rst_n       (hw_rst_n           ),
.sw_rst         (sw_rst             ),
//.a_empty      (rd_almost_empty    ),
//.aempty_val   (aempty_value       ),
.rd_count       (fifo_read_count    ),
.rd_underflow   (rd_underflow_wire  ),
.winc           (write_mem_en       ),
.mem_rst        (mem_rst            )
                                                    
);

//---------------------------------------------------------------------------------------------------------------------------//                                       
//-------------------------------------------------WRITE FULL CHECK ---------------------------------------------------//

wptr_full   
#(.ADDRESS_WIDTH(ADDRESS_WIDTH),.DEPTH(DEPTH),.SOFT_RESET(SOFT_RESET),.DATA_WIDTH(DATA_WIDTH),.STICKY_ERROR(STICKY_ERROR),.RESET_MEM(RESET_MEM), .PIPE_WRITE(PIPE_WRITE))	
wptr_ful 
(  
.wfull          (wfull              ),
.wptr           (wptr               ),
.waddr          (waddr              ),
.wq2_rptr       (wq2_rptr           ),
.wclk           (wclk               ),
.winc           (write_mem_en       ),
.hw_rst_n       (hw_rst_n           ),
.sw_rst         (sw_rst             ),                                                    
//.a_full         (wr_almost_ful      ),
//.afull_vl       (afull_value        ),
.wr_count       (fifo_write_count   ),
.wr_overflow    (wr_overflow_wire   ), 
.rinc           (read_enable        ),
.mem_rst        (mem_rst            )
       
);
							 
	
//---------------------------------------------------------------------------------------------------------------------------//

//.................................. Logic for write level and read level....................................................//

//assign wr_level= ((waddr >= raddr)  )? (waddr - raddr): (waddr+DEPTH-raddr)            ;


//assign rd_level= DEPTH - ((waddr >= raddr) ? ((waddr - raddr)) : (waddr+DEPTH-raddr+1));

//assign rd_level = (waddr == raddr) ? DEPTH : (waddr > raddr)  ? (DEPTH - (waddr - raddr)) : (DEPTH - (waddr + DEPTH - raddr));

assign wr_level = (waddr == raddr) ? (wfull ? DEPTH : 0) :
                 (waddr > raddr)  ? (waddr - raddr) :
                 (DEPTH - raddr + waddr);

// Number of empty locations (0-32)
assign rd_level = DEPTH - wr_level;


//assign a_full= (!hw_rst_n) ? 0 : (wr_level>= (( afull_value))?1'b1:1'b0);
//assign a_empty= (!hw_rst_n) ? 0 : ((wr_level<= aempty_value) ?1'b1:1'b0);
assign wr_almost_ful = (!hw_rst_n) ? 0 : ((wr_level >= afull_value) /*|| (wr_almost_ful)*/);
assign rd_almost_empty = (!hw_rst_n) ? 0 : ((wr_level <= aempty_value) ? 1'b1 : 1'b0);

//-------------------------------------------Debug Message --------------------------------------------------------

/*
property debug_msg;
@(posedge wclk)
disable iff(!hw_rst_n && !overflow)
 (overflow && DEBUG_ENABLE==1);

endproperty
assert property(debug_msg)$info (" INFO : OVERFLOW ",$time);


property debug_msg1;
@(posedge wclk)
disable iff(!hw_rst_n && !overflow)
 (overflow && DEBUG_ENABLE==2);

endproperty
assert property(debug_msg1)$warning (" Warning : OVERFLOW ",$time);

property debug_msg2;
@(posedge wclk)
disable iff(!hw_rst_n && !overflow)
 (overflow && DEBUG_ENABLE==3);

endproperty
assert property(debug_msg2)$error (" ERROR : OVERFLOW ",$time);

property debug_msg3;
@(posedge wclk)
disable iff(!hw_rst_n && !overflow)
 (overflow && DEBUG_ENABLE==4);

endproperty
assert property(debug_msg3)$fatal (" FATAL : OVERFLOW ",$time);

///-----------------------------------debug_underflow_msg---------------------------------------

property debug_underflow_msg1;
@(posedge rclk)
disable iff(!hw_rst_n && !underflow)
 (underflow && DEBUG_ENABLE==1);

endproperty
assert property(debug_underflow_msg1)$info (" INFO : UNDERFLOW ",$time);


property debug_underflow_msg2;
@(posedge rclk)
disable iff(!hw_rst_n && !underflow)
 (underflow && DEBUG_ENABLE==2);

endproperty
assert property(debug_underflow_msg2)$warning (" Warning : UNDERFLOW ",$time);

property debug_underflow_msg3;
@(posedge rclk)
disable iff(!hw_rst_n && !underflow)
 (underflow && DEBUG_ENABLE==3);

endproperty
assert property(debug_underflow_msg3)$error (" ERROR : UNDERFLOW ",$time);

property debug_underflow_msg4;
@(posedge rclk)
disable iff(!hw_rst_n && !underflow)
 (underflow && DEBUG_ENABLE==4);

endproperty
assert property(debug_underflow_msg4)$fatal (" FATAL : UNDERFLOW ",$time);

*/
//------------------------Debug Message--------------------------------------------------------------------

debug_overflow:

assert property (@(posedge wclk) disable iff (hw_rst_n==1'b0) (overflow===1'b0))
else if (DEBUG_ENABLE==1) $info(" INFO : OVERFLOW ",$time);
else if (DEBUG_ENABLE==2) $error(" ERROR : OVERFLOW ",$time);
else if (DEBUG_ENABLE==3) $display(" WARNING : OVERFLOW ",$time);
else if (DEBUG_ENABLE==4) $display(" FATAL : OVERFLOW ",$time);

debug_underflow:

assert property (@(posedge rclk) disable iff (hw_rst_n==1'b0) (underflow===1'b0))
else if (DEBUG_ENABLE==1) $info(" INFO : UNDERFLOW ",$time);
else if (DEBUG_ENABLE==2) $error(" ERROR : UNDERFLOW ",$time);
else if (DEBUG_ENABLE==3) $display(" WARNING : UNDERFLOW ",$time);
else if (DEBUG_ENABLE==4) $display(" FATAL : UNDERFLOW ",$time);




endmodule

