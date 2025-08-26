module tt_um_fifo #(parameter DSIZE=8, parameter ASIZE=4)
(
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire   ena,
    input  wire   clk,
    input  wire   rst_n  
  
);
  assign uo_out = rdata;
  wire [DSIZE-1:0] rdata;
  wire  wfull, rempty;
  assign uio_oe = 8'b00100111;
  assign uio_out[0] = rempty;
  assign uio_out[1] = wfull;
  
  wire  [DSIZE-1:0] wdata = ui_in;
  wire winc = uio_in[7];
  wire rinc = uio_in[6];
  wire rrst_n = uio_in[3];
  wire wrst_n = uio_in[4];
    assign uio_out[7:6] = 0;
    assign uio_out[4:3] = 0;
    
    assign uio_out[5] = wclk;
    assign uio_out[2] = rclk;
  // Internal divided clocks
  wire wclk, rclk;

  // Clock divider instance
  clk_div clk_div_inst (
    .clk   (clk),
    .r_rst (rrst_n),   // active-high reset for divider
    .w_rst (wrst_n),
    .wclk  (wclk),
    .rclk  (rclk)
  );

  // Address & pointers
  wire [ASIZE-1:0] waddr, raddr;
  wire [ASIZE:0]   rptr, wptr, WSR2_ptr, RSW2_ptr;
  wire             wclken = (winc && !wfull);
  wire             rclken = (rinc && !rempty);

  // Synchronizers
  sync_R2W sync_r2w (
    .RSW2_ptr(RSW2_ptr), .rptr(rptr),
    .wclk(wclk), .wrst_n(wrst_n)
  );

  sync_W2R sync_w2r (
    .WSR2_ptr(WSR2_ptr), .wptr(wptr),
    .rclk(rclk), .rrst_n(rrst_n)
  );

  // FIFO memory
  fifomem #(DSIZE, ASIZE) fifomem_inst (
    .rdata(rdata),
    .wdata(wdata),
    .raddr(raddr),
    .waddr(waddr),
    .wclken(wclken),
    .wclk(wclk),
    .rclken(rclken),  
    .rclk(rclk)        
  );

  // Empty / full logic
  rptr_empty #(.ASIZE(ASIZE)) rptr_empty_inst (
    .rempty(rempty), .raddr(raddr), .rptr(rptr),
    .WSR2_ptr(WSR2_ptr), .rinc(rinc),
    .rclk(rclk), .rrst_n(rrst_n)
  );

  wptr_full #(.ASIZE(ASIZE)) wptr_full_inst (
    .wfull(wfull), .waddr(waddr), .wptr(wptr),
    .RSW2_ptr(RSW2_ptr), .winc(winc),
    .wclk(wclk), .wrst_n(wrst_n)
  );
    wire _unused = &{ena,uio_in[5],uio_in[2:0],rst_n};
endmodule
