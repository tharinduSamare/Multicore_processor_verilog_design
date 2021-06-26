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

localparam WIDTH = 12;
localparam DEPTH = 8;
localparam ADDR_WIDTH = $clog2(DEPTH);

reg wrEn;
reg [WIDTH-1:0] dataIn; 
wire [WIDTH-1:] dataOut;
reg [ADDR_WIDTH-1:0] address;

RAM #(.WIDTH(WIDTH), .DEPTH(DEPTH), .ADDR_WIDTH(ADDR_WIDTH)) dut(.clk(clk), .wrEn(wrEn), .dataIn(dataIn), .address(address)
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
    address <= 20;
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

reg [WIDTH-1:0]test_memory[0:DEPTH-1];

typedef logic [WIDTH-1:0]test_memory_t[0:DEPTH-1];
test_memory_t test_memory;

function test_memory_t update (test_memory_t test_memory, logic wrEn, wire [ADDR_WIDTH-1:0] address, wire [WIDTH-1:0] dataIn, wire [WIDTH-1:0] dataOut);
  
  if (wrEn) begin
      test_memory[address] = dataIn;
  end
  
  return test_memory;
  
endfunction

function void check (test_memory_t test_memory, wire [WIDTH-1:0] dataOut, wire [ADDR_WIDTH-1:0] address);

    if (dataOut != test_memory[address]) begin
        $display("dataOut = %p, memory_value = %p, address = %p", dataOut, test_memory[address], address);
    end
  
endfunction

initial begin
    forever begin
        @(posedge clk);
        test_memory = update (test_memory, wrEn, address, dataIn, dataOut);

        @(negedge clk);
        #(CLK_PERIOD*1/10);
        check (test_memory, dataOut, address);
    end
end

endmodule //RAM_tb