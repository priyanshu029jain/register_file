module register_file(
input [7:0] data_in,
input [3:0] addr_rd, addr_wr,
input clk, wr,rd,
output reg [7:0] data_out
    );
    
    // declaring the register bank
    reg [7:0] register_bank [0:15];
    
    always @(posedge clk) begin
        if(wr && !rd)
            register_bank[addr_wr] <= data_in;
        else if(rd && !wr)
            data_out <= register_bank[addr_rd];
    end
    
endmodule