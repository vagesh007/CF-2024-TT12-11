
module wptr_full #(parameter ASIZE = 4)(
  output reg [ASIZE:0] wptr,
  output     [ASIZE-1:0] waddr,
  output reg wfull,
  input  [ASIZE:0] RSW2_ptr,
  input  wclk,
  input  wrst_n,
  input  winc
  
);

  reg  [ASIZE:0] wbin;
  wire [ASIZE:0] wgraynext, wbinnext;
  wire wfull_val;

  // Binary and Gray pointer update
  always @(posedge wclk or negedge wrst_n)
    if (!wrst_n)
      {wbin, wptr} <= 0;
    else
      {wbin, wptr} <= {wbinnext, wgraynext};

  // Write address for memory access
  assign waddr     = wbin[ASIZE-1:0];
  assign wbinnext  = wbin + {4'h0,(winc & ~wfull)};
  assign wgraynext = (wbinnext >> 1) ^ wbinnext;

  // Full condition (Cummings method)
  assign wfull_val = (wgraynext == {~RSW2_ptr[ASIZE:ASIZE-1], RSW2_ptr[ASIZE-2:0]});

  // wfull update
  always @(posedge wclk or negedge wrst_n)
    if (!wrst_n)
      wfull <= 1'b0;
    else
      wfull <= wfull_val;

endmodule
