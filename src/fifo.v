`timescale 1ns / 1ps
module fifo #(parameter DSIZE=8, parameter ASIZE=4)
(
  output [DSIZE-1:0] rdata,
  output             wfull, rempty,
  input  [DSIZE-1:0] wdata,
  input              winc, rinc,
  input              rrst_n, wrst_n,
  input              clk        // board/system clock (100 MHz for example)
);

  // Internal divided clocks
  wire wclk, rclk;

  // Clock divider instance
  clk_div clk_div_inst (
    .clk   (clk),
    .r_rst (~rrst_n),   // active-high reset for divider
    .w_rst (~wrst_n),
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

endmodule
