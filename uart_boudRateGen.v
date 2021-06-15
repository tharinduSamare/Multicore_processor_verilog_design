module uart_boudRateGen
#(
    parameter BAUD_RATE = 19200
)
(
    input clk,rstN,
    output baudTick
);

localparam CLK_RATE = 50*(10**6);
localparam RESOLUTION = 16;  // samples per 1 baud
localparam MAX_COUNT = (CLK_RATE/BAUD_RATE/RESOLUTION); //round to smaller integer
localparam WIDTH = $clog2(MAX_COUNT);

reg [WIDTH-1:0]count;

always @(posedge clk) begin
    if (~rstN)
        count <= 1'b0;
    else if (count < MAX_COUNT)
        count <= count + 1'b1;
    else
        count <= 1'b0;
end

assign  baudTick = (count==MAX_COUNT)? 1'b1:1'b0;


endmodule //uart_boudRateGen