`timescale 1ns/1ps

module incRegister_tb();

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
reg wrEn, incEn, rstN;
wire [WIDTH-1:0]dataOut;

incRegister #(.WIDTH(WIDTH)) dut(.dataIn(dataIn), .wrEn(wrEn), .rstN(rstN), .clk(clk), .incEn(incEn), .dataOut(dataOut));

initial begin
    @(posedge clk);
    #(CLK_PERIOD*4/5);
    rstN <= 0;

    @(posedge clk);
    #(CLK_PERIOD*4/5);
    dataIn <= 23;
    wrEn <= 1;

    @(posedge clk);
    #(CLK_PERIOD*4/5);
    dataIn <= 36;
    wrEn <= 1;
    rstN <= 1;

    @(posedge clk);
    #(CLK_PERIOD*4/5);
    dataIn <= 15;
    wrEn <= 0;
    incEn <= 1;

    repeat (10) begin
        @(posedge clk);
        #(CLK_PERIOD*4/5);
        wrEn = $random();
        incEn = $random();
        rstN = $random();
        dataIn = $random();
    end

    $stop;
end

initial begin
    forever begin
       @(posedge clk);
       #(CLK_PERIOD*1/5);
        $display("dataIn = %d   rstN = %b    wrEn = %b   incEn = %b    dataOut = %d", dataIn, rstN, wrEn, incEn, dataOut);  
    end
    
end

endmodule:incRegister_tb