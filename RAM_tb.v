`timescale 1ns/1ps

module RAM_tb();

localparam CLK_PERIOD = 20;
reg clk;
initial begin
    clk <= 0;
    forever begin
        #(CLK_PERIOD/2);
        clk <= ~clk;
    end
end

localparam DATA_WIDTH = 12;
localparam DEPTH = 8;
localparam ADDR_WIDTH = $clog2(DEPTH);

reg wrEn;
reg [DATA_WIDTH-1:0] dataIn; 
wire [DATA_WIDTH-1:0] dataOut;
reg [ADDR_WIDTH-1:0] address;

RAM #(.DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH), .ADDR_WIDTH(ADDR_WIDTH)) dut(.clk(clk), .wrEn(wrEn), .dataIn(dataIn), .address(address),
                                                                .dataOut(dataOut));

initial begin
    @(posedge clk);
    #(CLK_PERIOD*4/5);
    wrEn <= 1'b1;
    address <= 3;
    dataIn <= 100;

    @(posedge clk);
    #(CLK_PERIOD*4/5);
    wrEn <= 1'b0;
    address <= 2;
    dataIn <=30;

    repeat (20) begin
        @(posedge clk);
        #(CLK_PERIOD*4/5);    // to give data litte bit earlier to the posedge of the clk
        dataIn = $random();
        address = $random();
        wrEn = $random();

    end    

    $stop;
end

reg [DATA_WIDTH-1:0]test_memory[0:DEPTH-1];
reg temp_val;

function  test_memory_write (input wrEn, [ADDR_WIDTH-1:0] address, [DATA_WIDTH-1:0] dataIn); begin
  
    if (wrEn) begin
        test_memory[address] = dataIn;
    end

    test_memory_write = 1'b0;

end
  
endfunction

function check (input [DATA_WIDTH-1:0] dataOut, [ADDR_WIDTH-1:0] address); begin

        if (dataOut != test_memory[address]) begin
            $display("dataOut = %h, memory_value = %h, address = %h", dataOut, test_memory[address], address);
        end

        check = 1'b0;

end
  
endfunction

initial begin
    forever begin
        @(posedge clk);
        temp_val = test_memory_write (wrEn, address, dataIn);

        @(negedge clk);
        #(CLK_PERIOD*1/10);
        temp_val = check (dataOut, address);
    end
end

endmodule //RAM_tb
