module ALU (
    input [11:0]a,b,  // a - from Accumulator, b - from data-bus
    input [2:0]selectOp, 
    output [11:0]dataOut
);

localparam  clr = 3'd0,  // ALU operations and their control signals
            pass = 3'd1,
            add =  3'd2,
            sub =  3'd3,
            mul =  3'd4,
            inc =  3'd5,
            idle = 3'dx;

//output of the ALU is decided as below
assign dataOut =    (selectOp == clr)? 12'd0: 
                    (selectOp == pass)? b:
                    (selectOp == add)? a+b:
                    (selectOp == sub)? a-b:
                    (selectOp == mul)? a*b:
                    (selectOp == inc)? a+12'd1:
                    11'dx;  // default value is undefined

endmodule //ALU