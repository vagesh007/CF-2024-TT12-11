module rptr_empty #(parameter ASIZE = 4)(
  output reg [ASIZE:0] rptr,
  output     [ASIZE-1:0] raddr,
  output reg rempty,
  input  [ASIZE:0] WSR2_ptr,
  input  rclk,
  input  rrst_n,
  input  rinc
);

  reg  [ASIZE:0] rbin;
  wire [ASIZE:0] rgraynext, rbinnext;
  wire rempty_val;

  // Binary and Gray pointer update
  always @(posedge rclk or negedge rrst_n)
    if (!rrst_n)
      {rbin, rptr} <= 0;
    else
      {rbin, rptr} <= {rbinnext, rgraynext};

//memory 
  assign raddr     = rbin[ASIZE-1:0];
  assign rbinnext  = rbin + {4'h0,(rinc & ~rempty)};
  assign rgraynext = (rbinnext >> 1) ^ rbinnext;

//empty cond
  assign rempty_val = (rgraynext == WSR2_ptr);

  // rempty update
  always @(posedge rclk or negedge rrst_n)
    if (!rrst_n)
      rempty <= 1'b1;  // FIFO is empty after reset
    else
      rempty <= rempty_val;

endmodule

