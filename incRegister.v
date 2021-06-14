module incRegister 
#(parameter width = 12 )  //default size of a register is 12
(
    input [width-1:0]dataIn,
    input wrEn,rst,clk,incEn,
    output [width-1:0]dataOut
);

reg [width-1:0]value;

always @(posedge clk or negedge rst) begin
    if (~rst)
        value <= 0;
    else if (wrEn)
        value <= dataIn;
    else if (incEn)
        value <= value + 1'b1;
end

assign dataOut = value;

endmodule //incRegister