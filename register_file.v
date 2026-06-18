
module register_file # (
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
  ) (
    input wire clk,
    input wire rst_n,

    // Read Port 1 (Combinational)
    input  wire [ADDR_WIDTH -1:0]   addr_r1,
    output reg [DATA_WIDTH -1:0]   data_r1,

    // Read Port 2 (Combinational)
    input  wire [ADDR_WIDTH -1:0]   addr_r2,
    output reg [DATA_WIDTH -1:0]   data_r2,

    // Write Port 1 (Synchronous)
    input  wire wr,
    input  wire [ADDR_WIDTH -1:0]   addr_w,
    input  wire [DATA_WIDTH -1:0]   data_w
  );

  //number of registers in bank
  localparam registers = 2**ADDR_WIDTH;

  // declaring the register bank
  reg [DATA_WIDTH:0] register_bank [0:registers -1];


  integer i;
  //sequential logic for write operation 
  //as it is destructive signal need to be write only on wr signal
  always @(posedge clk)
  begin :write
    if(!rst_n)
    begin
      for(i =0; i < registers -1; i= i+1)
        register_bank[i] <= {DATA_WIDTH{1'b0}};
    end
    else if(wr & |addr_w)
    begin
      // |data_w avoid writing in R[0] as it is save for contant ZERO
      register_bank[addr_w] <= data_w;
    end

  end

  //cobinational logic for READ-1 port
  always @(*)
  begin :read_1
      if(!rst_n)
        data_r1 = {DATA_WIDTH{1'b0}};
      else if (addr_r1 == addr_w)
        // write first operation
        data_r1 = data_w;
      else
        data_r1 = register_bank[addr_r1];
  end

  //cobinational logic for READ-2 port
  always @(*)
  begin : read_2
      if(!rst_n)
        data_r2 = {DATA_WIDTH{1'b0}};
      else if (addr_r2 == addr_w)
        //write first operation
        data_r2 = data_w;
      else
        data_r2 = register_bank[addr_r2];
  end

endmodule
