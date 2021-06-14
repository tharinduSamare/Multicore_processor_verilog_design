module register 
#(parameter WIDTH = 12)  //default size of a register is 12
(   
    input [WIDTH-1:0]dataIn,
    input wrEn,rstN,clk,
    output [WIDTH-1:0]dataOut
);

reg [WIDTH-1:0]value;

always @(posedge clk) begin
    if (~rstN)
        value <= 0;
    else if (wrEn)
        value <= dataIn;
end

assign dataOut = value;  

endmodule //register