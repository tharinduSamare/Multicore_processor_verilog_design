`timescale 1ns/1ps

module register_tb();

localparam CLK_PERIOD = 20;

reg clk;
initial begin
    clk <= 0;
    forever begin
        #(CLK_PERIOD/2);
        clk <= ~clk;
    end
end

localparam WIDTH = 12;
reg [WIDTH-1:0]dataIn;
reg rstN, wrEn;
wire [WIDTH-1:0] dataOut;

register #(.WIDTH(WIDTH)) dut(.clk(clk), .wrEn(wrEn), .rstN(rstN), .dataIn(dataIn), .dataOut(dataOut));

initial begin
    @(posedge clk);
    rstN <= 0;

    @(posedge clk);
    rstN <= 1;
    dataIn <= 20;
    wrEn <= 0;

    @(posedge clk);
    dataIn <= 43;
    wrEn <= 1;

    repeat(10) begin
        @(posedge clk);
        dataIn = $random();
        wrEn = $random();
        rstN = $random();
    end
    
    @(posedge clk);
    $stop;
end

endmodule // register_tb