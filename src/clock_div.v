
module clk_div(
    input  wire clk,     // 100 MHz input clock
    input  wire r_rst,   // active-high reset for rclk
    input  wire w_rst,   // active-high reset for wclk
    output reg  wclk,    // 50 MHz (÷2)
    output reg  rclk     // ~33.3 MHz (÷3)
);

    
    
    // Divide-by-2 for 50 MHz
    always @(posedge clk or negedge w_rst) begin
        if (!w_rst)
            wclk <= 1'b0;
        else
            wclk <= ~wclk;
    end

    // Divide-by-3 for ~33.3 MHz
    reg [1:0] rcount;
    always @(posedge clk or negedge r_rst) begin
        if (!r_rst) begin
            rcount <= 0;
            rclk   <= 1'b0;
        end else begin
            rcount <= (rcount == 2) ? 0 : rcount + 1;
            rclk   <= (rcount < 1);  // high for 1 cycle, low for 2 cycles
        end
    end

endmodule
