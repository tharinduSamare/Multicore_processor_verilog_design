`timescale 1ns/1ps
module ALU_tb();

localparam CLK_PERIOD = 10;

reg clk;
initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk <= ~clk;
end

localparam [2:0]
            clr  =  3'd0,  // ALU operations and their control signals
            pass =  3'd1,
            add  =  3'd2,
            sub  =  3'd3,
            mul  =  3'd4,
            inc  =  3'd5,
            idle =  3'd6;

localparam WIDTH = 12;

reg signed [WIDTH-1:0]a,b;
reg [2:0] selectOp;
wire signed [WIDTH-1:0] dataOut;


ALU #(.WIDTH(WIDTH))dut(.a(a), .b(b), .selectOp(selectOp), .dataOut(dataOut));

initial begin
    @(posedge clk);
    a <= 10;
    b <= 3;
    selectOp <= clr;

    @(posedge clk);
    selectOp <= pass;

    @(posedge clk);
    selectOp <= add;

    @(posedge clk);
    selectOp <= sub;

    @(posedge clk);
    selectOp <= mul;

    @(posedge clk);
    selectOp <= inc;

    @(posedge clk);
    selectOp <= idle;

    @(posedge clk);
    a <= 20;
    b <= -30;
    selectOp <= clr;

    @(posedge clk);
    selectOp <= pass;

    @(posedge clk);
    selectOp <= add;

    @(posedge clk);
    selectOp <= sub;

    @(posedge clk);
    selectOp <= mul;

    @(posedge clk);
    selectOp <= inc;

    @(posedge clk);
    selectOp <= idle;

    @(posedge clk);
    repeat(10) begin
        @(posedge clk);
        a = $random();
        b = $random();
        selectOp = $random();
    end
    $stop;
end
endmodule //ALU_tb