module uart_boudRateGen (
    input clk,rst,
    output boudTick
);

reg [7:0]count;

always @(posedge clk or negedge rst) begin
    if (~rst)
        count <= 8'b0;
    else if (count < 162)
        count <= count+8'b1;
    else
        count <= 8'b0;
end

assign  boudTick = (count==8'd162)? 1'b1:1'b0;


endmodule //uart_boudRateGen