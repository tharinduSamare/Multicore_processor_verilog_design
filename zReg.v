module zReg 
#(parameter WIDTH = 12)
(
    input [11:0]dataIn,
    input clk,rstN,wrEn,
    output Zout
);

reg value;

always @(posedge clk) begin
    if (~rstN)
        value <= 1'b0;
    else if (wrEn)
        if (dataIn == 1'b0)
            value <= 1'b1;
        else
            value <= 1'b0;
end

assign  Zout = value;

endmodule //zReg