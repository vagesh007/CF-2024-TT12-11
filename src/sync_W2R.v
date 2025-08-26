
module sync_W2R #(parameter ASIZE = 4)(
  output reg [ASIZE:0] WSR2_ptr,
  input  [ASIZE:0]     wptr,
  input                rclk,
  input                rrst_n
);

  reg [ASIZE:0] WSR1_ptr;

  always @(posedge rclk or negedge rrst_n)
    if (!rrst_n)
      {WSR2_ptr, WSR1_ptr} <= 0;
    else
      {WSR2_ptr, WSR1_ptr} <= {WSR1_ptr, wptr};

endmodule

