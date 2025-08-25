`timescale 1ns / 1ps
module fifo_tb;

  // Parameters
  parameter DSIZE = 8;
  parameter ASIZE = 4;

  // Signals
  reg                  clk;
  reg                  wrst_n, rrst_n;
  reg  [DSIZE-1:0]     wdata;
  reg                  winc, rinc;
  wire [DSIZE-1:0]     rdata;
  wire                 wfull, rempty;

  // DUT instantiation
  fifo #(DSIZE, ASIZE) dut (
    .rdata(rdata),
    .wfull(wfull),
    .rempty(rempty),
    .wdata(wdata),
    .winc(winc),
    .rinc(rinc),
    .rrst_n(rrst_n),
    .wrst_n(wrst_n),
    .clk(clk)         // board/system clock
  );

  // Clock generation (100 MHz board clock = 10 ns period)
  initial clk = 0;
  always #5 clk = ~clk; // 10ns period

  // VCD dump
  initial begin
    $dumpfile("fifo.vcd");   
    $dumpvars(0, fifo_tb);        // dump tb + DUT
    $dumpvars(0, fifo_tb.dut.wclk); // explicitly dump divided write clock
    $dumpvars(0, fifo_tb.dut.rclk); // explicitly dump divided read clock
  end

  // Test logic
  integer write_count;
  integer read_count;

  initial begin
    // Initialize
    wrst_n = 0; rrst_n = 0;
    winc = 0; rinc = 0;
    wdata = 0;
    write_count = 0;
    read_count  = 0;

    // Release reset after 20ns
    #20;
    wrst_n = 1;
    rrst_n = 1;

    // Step 1: Write until FIFO is full
    $display("Starting writes...");
    fork
      begin
        while (!wfull) begin
          @(posedge clk);
          winc  <= 1;
          wdata <= write_count;
          write_count = write_count + 1;
          $display($time, " ns -- Writing: %0d", wdata);
        end
        @(posedge clk);
        winc <= 0;
        $display("FIFO is FULL at time %0t, total writes = %0d", $time, write_count);
      end
    join

    // Step 2: Read until FIFO is empty
    $display("Starting reads...");
    fork
      begin
        while (!rempty) begin
          @(posedge clk);
          rinc <= 1;
          $display($time, " ns -- Reading: %0d", rdata);
          read_count = read_count + 1;
        end
        @(posedge clk);
        rinc <= 0;
        $display("FIFO is EMPTY at time %0t, total reads = %0d", $time, read_count);
      end
    join

    // Finish
    #50;
    $display("Simulation completed successfully.");
    $stop;
  end

endmodule
