module processor 
#(
    parameter REG_WIDTH = 12,
    parameter INS_WIDTH = 8,
    parameter DATA_MEM_ADDR_WIDTH = 12,
    parameter INS_MEM_ADDR_WIDTH = 8
)
(
    input clk,rstN,startN,
    input [REG_WIDTH-1:0]ProcessorDataIn,
    input [INS_WIDTH-1:0]InsMemOut,
    output [REG_WIDTH-1:0]ProcessorDataOut,
    output [DATA_MEM_ADDR_WIDTH-1:0]dataMemAddr,
    output [INS_MEM_ADDR_WIDTH-1:0]insMemAddr,
    output DataMemWrEn,
    output done,ready
);

wire [REG_WIDTH-1:0]alu_a, alu_b, alu_out;
wire [2:0]select_alu_op;
wire [3:0]busSel;
wire [REG_WIDTH-1:0]busOut;
wire [INS_WIDTH-1:0]IRout;
wire [REG_WIDTH-1:0] Rout, RLout, RCout, RPout, RQout, R1out, ACout;
wire Zout, ZWrEn;
wire [3:0]incReg;    // {PC, RC, RP, RQ}
wire [9:0]wrEnReg;   // {AR, R, PC, IR, RL, RC, RP, RQ, R1, AC}

//instantiation of each module within the processor are as follows.

controlUnit #(.INS_WIDTH(INS_WIDTH)) CU(.clk(clk), .rstN(rstN), .startN(startN), .Zout(Zout), .ins(IRout), 
                .aluOp(select_alu_op), .incReg(incReg), .wrEnReg(wrEnReg), .busSel(busSel), 
                .DataMemWrEn(DataMemWrEn), .ZWrEn(ZWrEn), .done(done), .ready(ready));

ALU #(.WIDTH(REG_WIDTH)) alu(.a(alu_a), .b(alu_b), .selectOp(select_alu_op), .dataOut(alu_out));

multiplexer #(.REG_WIDTH(REG_WIDTH), .INS_WIDTH(INS_WIDTH)) mux(.selectIn(busSel), .DMem(ProcessorDataIn), 
                .R(Rout), .RL(RLout), .RC(RCout), .RP(RPout), .RQ(RQout), .R1(R1out), .AC(ACout), 
                .IR(IRout), .busOut(busOut));

register #(.WIDTH(REG_WIDTH)) AR(.dataIn(busOut), .wrEn(wrEnReg[9]), .rstN(rstN), .clk(clk), 
                .dataOut(dataMemAddr));

register #(.WIDTH(REG_WIDTH)) R(.dataIn(busOut), .wrEn(wrEnReg[8]), .rstN(rstN), .clk(clk), .dataOut(Rout));

incRegister #(.WIDTH(INS_WIDTH)) PC(.dataIn(IRout), .wrEn(wrEnReg[7]), .rstN(rstN), .clk(clk), 
                .incEn(incReg[3]), .dataOut(insMemAddr));

register #(.WIDTH(INS_WIDTH)) IR(.dataIn(InsMemOut), .wrEn(wrEnReg[6]), .rstN(rstN), 
                .clk(clk), .dataOut(IRout));    

register #(.WIDTH(REG_WIDTH)) RL(.dataIn(busOut), .wrEn(wrEnReg[5]), .rstN(rstN), .clk(clk), .dataOut(RLout));

incRegister #(.WIDTH(REG_WIDTH)) RC(.dataIn(busOut), .wrEn(wrEnReg[4]), .rstN(rstN), 
                .clk(clk), .incEn(incReg[2]), .dataOut(RCout));

incRegister #(.WIDTH(REG_WIDTH)) RP(.dataIn(busOut), .wrEn(wrEnReg[3]), .rstN(rstN), 
                .clk(clk), .incEn(incReg[1]), .dataOut(RPout));

incRegister #(.WIDTH(REG_WIDTH)) RQ(.dataIn(busOut), .wrEn(wrEnReg[2]), .rstN(rstN), 
                .clk(clk), .incEn(incReg[0]), .dataOut(RQout));

register #(.WIDTH(REG_WIDTH)) R1(.dataIn(busOut), .wrEn(wrEnReg[1]), .rstN(rstN), .clk(clk), .dataOut(R1out));

register #(.WIDTH(REG_WIDTH)) AC(.dataIn(alu_out), .wrEn(wrEnReg[0]), .rstN(rstN), .clk(clk), .dataOut(ACout));

zReg #(.WIDTH(REG_WIDTH)) Z(.dataIn(alu_out), .clk(clk), .rstN(rstN), .wrEn(ZWrEn), .Zout(Zout));

// necessary wires are routed as follows among modules as below.
assign ProcessorDataOut = Rout;
assign alu_a = ACout;
assign alu_b = busOut;

endmodule //processor