module DATA_RAM
#( 
    parameter mem_init = 0, 
    parameter WIDTH = 12,
    parameter DEPTH = 4096,
    parameter ADDR_WIDTH = $clog2(DEPTH)
)
(
    input wire clk, wrEn,
    input wire [WIDTH-1:0]dataIn,
    input wire [ADDR_WIDTH-1:0]addr,
    output wire [WIDTH-1:0]dataOut,

    input wire processDone   // need only for simulation (to get the memory at the end)
);


reg [ADDR_WIDTH-1:0]addr_reg;

reg [WIDTH-1:0]memory[0:DEPTH-1] ;

/// initialize memory for simulation  /////////
initial begin
    if (mem_init == 1) begin
        $readmemb("../../4_data_mem_tb.txt", memory);
    end
end

always @(processDone) begin
    if (processDone) begin
        $writememb("../../11_data_mem_out.txt", memory);
    end
end

///////////////////////////////////////////////

always @(posedge clk) begin
    addr_reg <= addr;
    if (wrEn) begin
        memory[addr] <= dataIn;   // write requires only 1 clk cyle. 
    end
end
assign dataOut = memory[addr_reg];   // address is registered. Need 2 clk cycles to read.

endmodule // DATA_RAM
