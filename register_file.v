
module register_file # (
    parameter data_width = 8,
    parameter addr_width = 4
) (
input [data_width -1 :0] data_in,
input [addr_width -1:0] addr_rd, addr_wr,
input clk, wr,rd,
output reg [data_width -1:0] data_out
    );
    
    //number of registers in bank
    localparam registers = 2**addr_width;

    // declaring the register bank
    reg [data_width:0] register_bank [0:registers -1];
    
    always @(posedge clk) begin
        if(wr && !rd)
            register_bank[addr_wr] <= data_in;
        else if(rd && !wr)
            data_out <= register_bank[addr_rd];
    end
    
endmodule