module multiplexer 
#(
    REG_WIDTH = 12,
    INS_WIDTH = 8
)
(
    input [3:0]selectIn,  
    input [REG_WIDTH-1:0]DMem, R, RL, RC, RP, RQ, R1, AC,
    input [INS_WIDTH-1:0]IR,
    output [REG_WIDTH-1:0]busOut
);

//control signals to select the bus input 
localparam  [3:0]
    DMem_sel = 4'b0, 
    R_sel    = 4'd1,
    IR_sel   = 4'd2,
    RL_sel   = 4'd3,
    RC_sel   = 4'd4,
    RP_sel   = 4'd5,
    RQ_sel   = 4'd6,
    R1_sel   = 4'd7,
    AC_sel   = 4'd8,
    idle     = 4'd9;


//input of the data-bus is selected as below
assign busOut = (selectIn == DMem_sel)? DMem:
                (selectIn == R_sel) ? R:
                (selectIn == IR_sel)? {{(REG_WIDTH-INS_WIDTH){1'b0}},IR}: //first 3 bits are zero
                (selectIn == RL_sel)? RL:
                (selectIn == RC_sel)? RC:
                (selectIn == RP_sel)? RP:
                (selectIn == RQ_sel)? RQ:
                (selectIn == R1_sel)? R1:
                (selectIn == AC_sel)? AC:
                {REG_WIDTH{1'b0}};

endmodule //multiplexer