`timescale 1ns/1ps

module simulation_top_tb();

localparam CLK_PERIOD = 20;

reg clk;
initial begin
    clk <= 0;
    forever begin
        #(CLK_PERIOD/2);
        clk <= ~clk;
    end
end

localparam CORE_COUNT = 8;

reg rstN, startN;
wire processor_ready, processDone;

simulation_top #(.CORE_COUNT(CORE_COUNT)) simulation_top(.clk(clk), .rstN(rstN), .startN(startN),
                .processor_ready(processor_ready), .processDone(processDone));

initial begin
    @(posedge clk);
    rstN = 1'b0;
    startN = 1'b1;

    @(posedge clk);
    rstN = 1'b1;
    startN = 1'b0;

    @(posedge clk);
    startN = 1'b1;

    wait(processDone);
    
    repeat(10) @(posedge clk);
    $stop;
end

endmodule // simulation_top_tb