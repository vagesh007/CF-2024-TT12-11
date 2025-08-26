
module sync_R2W #(parameter ASIZE = 4)(
  output reg [ASIZE:0] RSW2_ptr,
  input  [ASIZE:0]     rptr,
  input                wclk,
  input                wrst_n
);

  reg [ASIZE:0] RSW1_ptr;

  always @(posedge wclk or negedge wrst_n)
    if (!wrst_n)
      {RSW2_ptr, RSW1_ptr} <= 0;
    else
      {RSW2_ptr, RSW1_ptr} <= {RSW1_ptr, rptr};

endmodule

