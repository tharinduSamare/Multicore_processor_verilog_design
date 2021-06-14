module register 
#(parameter width = 12)  //default size of a register is 12
(   
    input [width-1:0]dataIn,
    input wrEn,rst,clk,
    output [width-1:0]dataOut
);

reg [width-1:0]value;

always @(posedge clk or negedge rst) begin
    if (~rst)
        value <= 0;
    else if (wrEn)
        value <= dataIn;
end

assign dataOut = value;  

endmodule //register