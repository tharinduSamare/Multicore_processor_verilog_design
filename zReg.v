module zReg (
    input [11:0]dataIn,
    input clk,rst,wrEn,
    output Zout
);

reg value;

always @(posedge clk or negedge rst) begin
    if (~rst)
        value <= 1'b0;
    else if (wrEn)
        if (dataIn == 12'b0)
            value <= 1'b1;
        else
            value <= 1'b0;
end

assign  Zout = value;

endmodule //zReg