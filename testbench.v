`timescale 1ns/1ps

module testbench;

  // Testbench signal
  reg [7:0] data_w;
  reg [3:0] addr_r1, addr_r2, addr_w;
  reg clk, wr, rst_n;
  wire [7:0] data_r1, data_r2;

  // Instantiate DUT
  register_file uut (
                  .clk(clk),
                  .rst_n(rst_n),

                  //.rd1(rd1),
                  .addr_r1(addr_r1),
                  .data_r1(data_r1),

                  //.rd2(rd2),
                  .addr_r2(addr_r2),
                  .data_r2(data_r2),

                  .data_w(data_w),
                  .wr(wr),
                  .addr_w(addr_w)
                );

  // Clock generation: 10ns period
  always #5 clk = ~clk;


  //dumping the variables
  initial
  begin
    $dumpfile("testbench.vcd");
    $dumpvars(0, testbench);
  end


  initial
  begin
    // Initialize signals
    clk = 0;
    rst_n =0;
    wr = 0;
    addr_w = 0;
    data_w = 0;
    addr_r1 = 0;
    addr_r2 = 0;

    // monitor result
    $monitor("%t \t %b %d\t%h \t  %d\t%h \t %d\t%h", $time,   wr,addr_w,data_w,   addr_r1,data_r1,   addr_r2,data_r2);


 // =========================================================================
    // INITIALIZATION & PRIMING
    // =========================================================================
    #8;
    rst_n = 1'b1;
    wr    = 1'b1; // Keep Write Port Active

    // Cycle 1: Prime the first register
    #10; 
    data_w  = 8'hDE; addr_w  = 4'h2; // Write DE to Addr 2
    addr_r1 = 4'h0;  addr_r2 = 4'h0; // Reading zeroes for now

    // =========================================================================
    // FULL PARALLEL PIPELINE EXECUTION (3 Operations running simultaneously)
    // =========================================================================

    // Cycle 2: Write to Addr 4 WHILE reading the fresh data from Addr 2
    #10; 
    data_w  = 8'hAD; addr_w  = 4'h4; // Write AD to Addr 4
    addr_r1 = 4'h2;                  // data_r1 should instantly display 8'hDE
    addr_r2 = 4'h0; 

    // Cycle 3: Write to Addr A WHILE reading Addr 4 AND checking a back-to-back read on Addr 2
    #10; 
    data_w  = 8'hBE; addr_w  = 4'hA; // Write BE to Addr A
    addr_r1 = 4'h4;                  // data_r1 should instantly display 8'hAD
    addr_r2 = 4'h2;                  // data_r2 continues to display 8'hDE

    // Cycle 4: THE ULTIMATE BYPASS TEST (Write and Read the exact same address simultaneously)
    #10; 
    data_w  = 8'hEF; addr_w  = 4'h3; // Write EF to Addr 3
    addr_r1 = 4'h3;                  // CRITICAL: raddr1 == waddr! data_r1 must show 8'hEF mid-clock via bypass!
    addr_r2 = 4'hA;                  // data_r2 should display 8'hBE (written in previous cycle)

    // Cycle 5: Read the final written value from Addr 3 on a clean cycle
    #10;
    wr      = 1'b0;                  // Disable writing to settle the bus
    addr_r1 = 4'h3;                  // data_r1 displays 8'hEF from the internal matrix now
    addr_r2 = 4'h4;                  // data_r2 displays 8'hAD

    // Finish simulation
    #10 $finish;
  end

endmodule

