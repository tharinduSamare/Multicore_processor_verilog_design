module processor (
    input clk,rst,start,
    input [11:0]fromDataMem,
    input [7:0]fromInsMem,
    output [11:0]dataMemAddr,toDataMem,
    output [7:0]insMemAddr,
    output dMemWrEn,
    output done,ready
);

wire [11:0]alu_a, alu_b, alu_out;
wire [2:0]select_alu_op;
wire [3:0]busSel;
wire [11:0]busOut;
wire [7:0]IRout;
wire [11:0] Rout, RLout, RCout, RPout, RQout, R1out, ACout;
wire Zout, ZWrEn;
wire [3:0]incReg;    // {PC, RC, RP, RQ}
wire [9:0]wrEnReg;   // {AR, R, PC, IR, RL, RC, RP, RQ, R1, AC}

//instantiation of each module within the processor are as follows.

controlUnit CU(.clk(clk), .rst(rst), .start(start), .Zout(Zout), .ins(IRout), 
                .aluOp(select_alu_op), .incReg(incReg), .wrEnReg(wrEnReg), .busSel(busSel), 
                .dMemWrEn(dMemWrEn), .ZWrEn(ZWrEn), .done(done), .ready(ready));

ALU alu(.a(alu_a), .b(alu_b), .selectOp(select_alu_op), .dataOut(alu_out));

multiplexer mux(.selectIn(busSel), .DMem(fromDataMem), .R(Rout), .RL(RLout), .RC(RCout), 
                .RP(RPout), .RQ(RQout), .R1(R1out), .AC(ACout), .IR(IRout), .busOut(busOut));

register #(.width(12)) AR(.dataIn(busOut), .wrEn(wrEnReg[9]), .rst(rst), .clk(clk), 
                .dataOut(dataMemAddr));

register #(.width(12)) R(.dataIn(busOut), .wrEn(wrEnReg[8]), .rst(rst), .clk(clk), .dataOut(Rout));

incRegister #(.width(8)) PC(.dataIn(IRout), .wrEn(wrEnReg[7]), .rst(rst), .clk(clk), 
                .incEn(incReg[3]), .dataOut(insMemAddr));

register #(.width(8)) IR(.dataIn(fromInsMem), .wrEn(wrEnReg[6]), .rst(rst), 
                .clk(clk), .dataOut(IRout));    

register #(.width(12)) RL(.dataIn(busOut), .wrEn(wrEnReg[5]), .rst(rst), .clk(clk), .dataOut(RLout));

incRegister #(.width(12)) RC(.dataIn(busOut), .wrEn(wrEnReg[4]), .rst(rst), 
                .clk(clk), .incEn(incReg[2]), .dataOut(RCout));

incRegister #(.width(12)) RP(.dataIn(busOut), .wrEn(wrEnReg[3]), .rst(rst), 
                .clk(clk), .incEn(incReg[1]), .dataOut(RPout));

incRegister #(.width(12)) RQ(.dataIn(busOut), .wrEn(wrEnReg[2]), .rst(rst), 
                .clk(clk), .incEn(incReg[0]), .dataOut(RQout));

register #(.width(12)) R1(.dataIn(busOut), .wrEn(wrEnReg[1]), .rst(rst), .clk(clk), .dataOut(R1out));

register #(.width(12)) AC(.dataIn(alu_out), .wrEn(wrEnReg[0]), .rst(rst), .clk(clk), .dataOut(ACout));

zReg Z(.dataIn(alu_out), .clk(clk), .rst(rst), .wrEn(ZWrEn), .Zout(Zout));

// necessary wires are routed as follows among modules as below.
assign toDataMem = Rout;
assign alu_a = ACout;
assign alu_b = busOut;

endmodule //processor