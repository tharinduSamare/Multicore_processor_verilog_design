module multiplexer (
    input [3:0]selectIn,  
    input [11:0]DMem, R, RL, RC, RP, RQ, R1, AC,
    input [7:0]IR,
    output [11:0]busOut
);

//control signals to select the bus input 
localparam  DMem_sel = 4'b0, 
            R_sel = 4'd1,
            IR_sel = 4'd2,
            RL_sel = 4'd3,
            RC_sel = 4'd4,
            RP_sel = 4'd5,
            RQ_sel = 4'd6,
            R1_sel = 4'd7,
            AC_sel = 4'd8,
            idle = 4'd9;

//input of the data-bus is selected as below
assign busOut = (selectIn == DMem_sel)? DMem:
                (selectIn == R_sel)? R:
                (selectIn == IR_sel)? {3'b0,IR}: //first 3 bits are zero
                (selectIn == RL_sel)? RL:
                (selectIn == RC_sel)? RC:
                (selectIn == RP_sel)? RP:
                (selectIn == RQ_sel)? RQ:
                (selectIn == R1_sel)? R1:
                (selectIn == AC_sel)? AC:
                12'd0;

endmodule //multiplexer