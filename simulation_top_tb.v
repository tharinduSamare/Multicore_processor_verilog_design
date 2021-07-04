module simulation_top_tb();

timeunit 1ns;
timeprecision 1ps;
localparam CLK_PERIOD = 10;

logic clk;
initial begin
    clk <= 0;
    forever begin
        #(CLK_PERIOD/2);
        clk <= ~clk;
    end
end

localparam CORE_COUNT = 1;

logic rstN, startN;
logic processor_ready, processDone;

simulation_top #(.CORE_COUNT(CORE_COUNT)) simulation_top(.*);

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