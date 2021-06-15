module insMem 
#(
    parameter DATA_WIDTH = 12,
    parameter DEPTH = 256,
    parameter ADDR_WIDTH = $clog2(DEPTH)  // 4096 locations
)

(
    input clk,wrEn,
    input [DATA_WIDTH-1:0]dataIn,
    input [ADDR_WIDTH-1:0]address,
    output reg [DATA_WIDTH-1:0]dataOut
);

reg [DATA_WIDTH-1:0] memory [0:DEPTH-1];

always @(posedge clk) begin
    if (wrEn) begin
        memory[address] <= dataIn;
    end
    dataOut <= memory[address];
end

endmodule //insMem