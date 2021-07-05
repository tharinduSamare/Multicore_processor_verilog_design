module RAM 
#(
    parameter DATA_WIDTH = 12,
    parameter DEPTH = 256,
    parameter ADDR_WIDTH = $clog2(DEPTH)  // 4096 locations
)

(
    input clk,wrEn,
    input [DATA_WIDTH-1:0]dataIn,
    input [ADDR_WIDTH-1:0]address,
    output [DATA_WIDTH-1:0]dataOut
);

reg [DATA_WIDTH-1:0] memory [0:DEPTH-1];
reg [ADDR_WIDTH-1:0] addr_reg;

always @(posedge clk) begin
    addr_reg <= address;
    if (wrEn) begin
        memory[address] <= dataIn;
    end
end

assign  dataOut = memory[addr_reg];

endmodule //RAM