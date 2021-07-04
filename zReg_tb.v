`timescale 1ns/1ps
module zReg_tb();

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
wire Zout;

zReg #(.WIDTH(WIDTH)) dut(.dataIn(dataIn), .clk(clk), .rstN(rstN), .wrEn(wrEn), .Zout(Zout));

initial begin
    @(posedge clk);
    #(CLK_PERIOD*4/5);
    rstN <= 0;

    @(posedge clk);
    #(CLK_PERIOD*4/5);
    rstN <= 1;
    dataIn <= 0;
    wrEn <= 0;

    @(posedge clk);
    #(CLK_PERIOD*4/5);
    dataIn <= 0;
    wrEn <= 1;

    @(posedge clk);
    #(CLK_PERIOD*4/5);
    dataIn <= 4;
    wrEn <= 1;

    repeat(10) begin
        @(posedge clk);
        #(CLK_PERIOD*4/5);
        dataIn = $random();
        wrEn = $urandom();
        rstN = $urandom();
    end
    
    $stop;
end

endmodule// zReg_tb