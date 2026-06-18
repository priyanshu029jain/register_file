`timescale 1ns/1ps

module testbench;

  // Testbench signal
  reg [7:0] data_in;
  reg [3:0] addr_rd, addr_wr;
  reg clk, wr, rd;
  wire [7:0] data_out;

  // Instantiate DUT
  register_file uut (
                  .data_in(data_in),
                  .addr_rd(addr_rd),
                  .addr_wr(addr_wr),
                  .clk(clk),
                  .wr(wr),
                  .rd(rd),
                  .data_out(data_out)
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
    wr = 0;
    rd = 0;
    data_in = 0;
    addr_wr = 0;
    addr_rd = 0;

     // monitor result
    $monitor("%t \t %b %d\t%h \t &b %d\t%h", $time,   wr,addr_wr,data_in,   rd,addr_rd,data_out);

    // Write operation
    #4 wr = 1;
    rd = 0;

    #10 data_in = 8'hDE;
    addr_wr = 4'h2;

    #10 data_in = 8'hAD;
    addr_wr = 4'h4;

    #10 data_in = 8'hBE;
    addr_wr = 4'hA;

    #10 data_in = 8'hEF;
    addr_wr = 4'h3;

    // Read operation
    #4 wr = 0;
    rd = 1;

    #10 addr_rd = 4'hA;
    #10 addr_rd = 4'h2;
    #10 addr_rd = 4'h3;
    #10 addr_rd = 4'h4;

    // Finish simulation
    #10 $finish;
  end

endmodule

