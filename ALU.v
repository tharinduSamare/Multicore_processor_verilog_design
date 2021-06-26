module ALU 
#(parameter WIDTH = 12)
(
    input signed [WIDTH-1:0]a,b,  // a - from Accumulator, b - from data-bus
    input [2:0]selectOp, 
    output signed [WIDTH-1:0]dataOut
);

localparam [2:0]
            clr  =  3'd0,  // ALU operations and their control signals
            pass =  3'd1,
            add  =  3'd2,
            sub  =  3'd3,
            mul  =  3'd4,
            inc  =  3'd5,
            idle =  3'd6;

//output of the ALU is decided as below
assign dataOut =    (selectOp == clr)? {WIDTH{1'b0}}: 
                    (selectOp == pass)? b:
                    (selectOp == add)? a+b:
                    (selectOp == sub)? a-b:
                    (selectOp == mul)? a*b:
                    (selectOp == inc)? a+1'b1:
                    (selectOp == idle)? {WIDTH{1'b0}}:
                    {WIDTH{1'b0}};  // default value is ZERO

endmodule //ALU