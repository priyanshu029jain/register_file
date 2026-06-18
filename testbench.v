`timescale 1ns/1ps

module testbench;

  // Testbench signal
  reg [7:0] data_w;
  reg [3:0] addr_r1, addr_r2, addr_w;
  reg clk, wr, rd1, rd2, rst_n;
  wire [7:0] data_r1, data_r2;

  // Instantiate DUT
  register_file uut (
                  .clk(clk),
                  .rst_n(rst_n),

                  .rd1(rd1),
                  .addr_r1(addr_r1),
                  .data_r1(data_r1),

                  .rd2(rd2),
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
    rd1 = 0;
    addr_r1 = 0;
    rd2 = 0;
    addr_r2 = 0;

    // monitor result
    $monitor("%t \t %b %d\t%h \t %b %d\t%h \t %b %d\t%h", $time,   wr,addr_w,data_w,   rd1,addr_r1,data_r1,   rd2,addr_r2,data_r2);

   // =========================================================================
    // 1. Write Operations (1W Port Active)
    // =========================================================================
    #8;
    wr  = 1'b1;
    rd1 = 1'b0;
    rd2 = 1'b0;
    rst_n = 1'b1;

    #10; data_w = 8'hDE; addr_w = 4'h2; // Write DE to Addr 2
    #10; data_w = 8'hAD; addr_w = 4'h4; // Write AD to Addr 4
    #10; data_w = 8'hBE; addr_w = 4'hA; // Write BE to Addr A
    #10; data_w = 8'hEF; addr_w = 4'h3; // Write EF to Addr 3

    // =========================================================================
    // 2. Dual Read Operations (Parallel 2R Ports Active)
    // =========================================================================
    #4;
    wr  = 1'b0; // Disable writing
    rd1 = 1'b1; // Activate Read Port 1
    rd2 = 1'b1; // Activate Read Port 2

    // Parallel Cycle 1: Read Addr A on Port 1 AND Addr 2 on Port 2 simultaneously
    #10; 
    addr_r1 = 4'hA;  // data_r1 will display 8'hBE
    addr_r2 = 4'h2;  // data_r2 will display 8'hDE

    // Parallel Cycle 2: Read Addr 3 on Port 1 AND Addr 4 on Port 2 simultaneously
    #10; 
    addr_r1 = 4'h3;  // data_r1 will display 8'hEF
    addr_r2 = 4'h4;  // data_r2 will display 8'hAD
    
    // End of test sequence
    #10;
    rd1 = 1'b0;
    rd2 = 1'b0;

    // Finish simulation
    #10 $finish;
  end

endmodule

