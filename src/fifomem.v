
module fifomem  #(parameter DSIZE = 8,parameter ASIZE =4)
(output reg [DSIZE-1:0] rdata,
 input [DSIZE-1:0] wdata,
 input [ASIZE-1:0] raddr,waddr,
 input wclken,wclk,rclken,rclk
 );
 
 localparam DEPTH = 1<<ASIZE;
 reg [DSIZE-1:0] mem [0:DEPTH-1];
 
 always@(posedge wclk)
 if(wclken)
    mem[waddr]<=wdata;
  
 always@(posedge rclk)
   if(rclken)
     rdata <= mem[raddr];
 
 endmodule
