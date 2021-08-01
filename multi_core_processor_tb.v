`timescale 1ns/1ns
module multi_core_processor_tb ();

localparam CLK_PERIOD = 20;
reg clk;
initial begin
    clk <= 0;
    forever begin
        #(CLK_PERIOD/2);
        clk <= ~clk;
    end
end

localparam CORE_COUNT = 3;
localparam REG_WIDTH = 12;
localparam INS_WIDTH = 8;
localparam INS_MEM_DEPTH = 256;
localparam DATA_MEM_DEPTH = 4096;
localparam DATA_MEM_ADDR_WIDTH = $clog2(DATA_MEM_DEPTH);
localparam INS_MEM_ADDR_WIDTH = $clog2(INS_MEM_DEPTH);
localparam DATA_MEM_WIDTH = REG_WIDTH*CORE_COUNT;

reg rstN,startN;
reg [REG_WIDTH*CORE_COUNT-1:0]ProcessorDataIn;
reg [INS_WIDTH-1:0]InsMemOut;
wire [REG_WIDTH*CORE_COUNT-1:0]ProcessorDataOut;
wire [INS_MEM_ADDR_WIDTH-1:0]insMemAddr;
wire [DATA_MEM_ADDR_WIDTH-1:0]dataMemAddr;
wire DataMemWrEn, done,ready;

multi_core_processor #(.REG_WIDTH(REG_WIDTH), .INS_WIDTH(INS_WIDTH), .CORE_COUNT(CORE_COUNT), 
                .DATA_MEM_ADDR_WIDTH(DATA_MEM_ADDR_WIDTH), .INS_MEM_ADDR_WIDTH(INS_MEM_ADDR_WIDTH))dut(
                .clk(clk), .rstN(rstN), .startN(startN), .ProcessorDataIn(ProcessorDataIn), .InsMemOut(InsMemOut),
                .ProcessorDataOut(ProcessorDataOut), .insMemAddr(insMemAddr), .dataMemAddr(dataMemAddr),
                .DataMemWrEn(DataMemWrEn), .done(done), .ready(ready));

///// initialize instruction and data memory /////////

reg [INS_WIDTH-1:0]ins_mem[0:INS_MEM_DEPTH-1];
reg [DATA_MEM_WIDTH-1:0]data_mem[0:DATA_MEM_DEPTH-1];

initial begin
    $readmemb("D:/ACA/SEM5_TRONIC_ACA/1_EN3030 _Circuits_and_Systems_Design/2020/learnFPGA/learn_processor_design/matrix_multiply/matrix_multiply_git/matrix_generation_for_tb/9_ins_mem_tb.txt", ins_mem);
    $readmemb("D:/ACA/SEM5_TRONIC_ACA/1_EN3030 _Circuits_and_Systems_Design/2020/learnFPGA/learn_processor_design/matrix_multiply/matrix_multiply_git/matrix_generation_for_tb/4_data_mem_tb.txt", data_mem);
end 
///////////// read data and instruction memory /////////
always @(posedge clk) begin
    ProcessorDataIn  <= data_mem[dataMemAddr];
    InsMemOut <= ins_mem[insMemAddr];
end

/////////// write data memory //////////
always @(posedge clk) begin
    if (DataMemWrEn) begin
        data_mem[dataMemAddr] <= ProcessorDataOut;
    end
end


///// start the simulation

initial begin
    @(posedge clk);
    rstN <= 1'b0;
    startN <= 1'b1;
    @(posedge clk);
    rstN <= 1'b1;
    startN <= 1'b0;
    @(posedge clk);
    startN <= 1'b1;
end



////////////// verification of the simulation correctness /////////

localparam  Q_end_addr_location = DATA_MEM_ADDR_WIDTH'(12'd7),
            R_start_addr_location = DATA_MEM_ADDR_WIDTH'(12'd5),
            R_end_addr_location = DATA_MEM_ADDR_WIDTH'(12'd8);
reg [REG_WIDTH-1:0] a, b, c, P_start_addr, Q_start_addr, R_start_addr, P_end_addr, Q_end_addr, R_end_addr;

reg disp_temp;
always @(posedge clk) begin
    if (done) begin
        a = data_mem[12'd0][REG_WIDTH-1:0];  
        b = data_mem[12'd1][REG_WIDTH-1:0];
        c = data_mem[12'd2][REG_WIDTH-1:0];
        P_start_addr = data_mem[12'd3][REG_WIDTH-1:0];
        Q_start_addr = data_mem[12'd4][REG_WIDTH-1:0];
        R_start_addr = data_mem[12'd5][REG_WIDTH-1:0];
        P_end_addr = data_mem[12'd6][REG_WIDTH-1:0];
        Q_end_addr = data_mem[12'd7][REG_WIDTH-1:0];
        R_end_addr = data_mem[12'd8][REG_WIDTH-1:0];

        $writememb("D:/ACA/SEM5_TRONIC_ACA/1_EN3030 _Circuits_and_Systems_Design/2020/learnFPGA/learn_processor_design/matrix_multiply/matrix_multiply_git/matrix_generation_for_tb/11_data_mem_out.txt", data_mem); // write data memory to file

        $display("\nMatrix P\n");
        disp_temp = print_matrix_P(a, b, P_start_addr, P_end_addr, CORE_COUNT);

        $display("\nMatrix Q\n");
        disp_temp = print_matrix_Q(b, c, Q_start_addr, Q_end_addr);

        $display("\nMatrix R\n");
        disp_temp = print_matrix_R(a, c, R_start_addr, R_end_addr, CORE_COUNT);

        repeat(5) @(posedge clk);  // end of the simulation
        $stop;
    end
end


function automatic print_matrix_P (input [REG_WIDTH-1:0]a,b,P_start_addr,P_end_addr, input integer CORE_COUNT);
    integer d = (a%CORE_COUNT == 0)? a/CORE_COUNT : a/CORE_COUNT+1;
    integer x,y,z;
    for (x=0;x<d;x=x+1)  begin
        for (y=CORE_COUNT;y>0;y=y-1) begin :core_count_loop
            if ((x+1)*CORE_COUNT-y>= a) begin
                disable core_count_loop;
            end 
            for (z=0;z<b;z=z+1) begin : print_val_P
                reg [DATA_MEM_WIDTH-1:0]temp_1 = data_mem[(P_start_addr + x*b+z)];
                reg [REG_WIDTH-1:0]temp_2 = temp_1[(y*REG_WIDTH-1) -:REG_WIDTH];
                $write("%h ", temp_2);                
            end
            $write("\n");
        end
    end
endfunction

function automatic print_matrix_Q(input [REG_WIDTH-1:0]b,c,Q_start_addr,Q_end_addr);
    integer i,j;
    for (i=Q_start_addr;i<Q_start_addr+b;i=i+1) begin 
        for (j=i;j<=Q_end_addr;j=j+b) begin :print_val_Q
            reg [DATA_MEM_WIDTH-1:0] temp_1 = data_mem[j];
            $write("%h ", temp_1[REG_WIDTH-1:0]);
        end
        $write("\n");
    end
endfunction

function automatic print_matrix_R(input [REG_WIDTH-1:0]a,c,R_start_addr,R_end_addr, input integer CORE_COUNT);
    integer d = (a%CORE_COUNT == 0)? a/CORE_COUNT : a/CORE_COUNT+1;

    integer x,y,z;
    for (x=0;x<d;x=x+1) begin
        for (y=CORE_COUNT;y>0;y=y-1) begin : core_count_loop
            if ((x+1)*CORE_COUNT-y>= a) begin
                disable core_count_loop;
            end 
            for (z=0;z<c;z=z+1) begin : print_val_R
                reg [DATA_MEM_WIDTH-1:0]temp_1 = data_mem[(R_start_addr + x*c+z)];
                reg [REG_WIDTH-1:0]temp_2 = temp_1[(y*REG_WIDTH-1) -:REG_WIDTH];
                $write("%h ", temp_2);                
            end
            $write("\n");
        end
    end
endfunction




endmodule //multi_core_processor_tb