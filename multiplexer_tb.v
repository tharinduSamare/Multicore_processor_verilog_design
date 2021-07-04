`timescale 1ns/1ps
module multiplexer_tb();

localparam CLK_PERIOD = 10;

reg clk;
initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk <= ~clk;
end

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

localparam REG_WIDTH = 12;
localparam INS_WIDTH = 8;

reg [3:0] selectIn;
wire [REG_WIDTH-1:0]DMem, R, RL, RC, RP, RQ, R1, AC;
wire [INS_WIDTH-1:0]IR;
wire [REG_WIDTH-1:0]busOut;

assign DMem = 20;
assign R = 21;
assign RL = 22;
assign RC = 23;
assign RP = 24;
assign RQ = 25;
assign R1 = 26;
assign AC = 27;
assign IR = 28;

multiplexer #(.REG_WIDTH(REG_WIDTH), .INS_WIDTH(INS_WIDTH)) mux(.selectIn(selectIn), .DMem(DMem), 
                .R(R), .RL(RL), .RC(RC), .RP(RP), .RQ(RQ), .R1(R1), .AC(AC), 
                .IR(IR), .busOut(busOut));
initial begin
    @(posedge clk);
    selectIn <= R_sel;
    $display("selectIn = %d busOut = %d", selectIn, busOut);

    @(posedge clk);
    selectIn <= RL_sel;
    $display("selectIn = %d busOut = %d", selectIn, busOut);

     @(posedge clk);
    selectIn <= RP_sel;
    $display("selectIn = %d busOut = %d", selectIn, busOut);

    @(posedge clk);
    selectIn <= RQ_sel;
    $display("selectIn = %d busOut = %d", selectIn, busOut);

    @(posedge clk);
    selectIn <= IR_sel;
    $display("selectIn = %d busOut = %d", selectIn, busOut);

    @(posedge clk);
    repeat(10) begin
        @(posedge clk);
        selectIn <= $urandom()%10;
        $display("selectIn = %d busOut = %d", selectIn, busOut);
    end
    $stop;
end

endmodule