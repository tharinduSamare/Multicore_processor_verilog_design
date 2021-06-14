// module BCDtoHEX(
//     input [3:0]in0,in1,in2,in3,in4,in5,in6,in7,
//     input start,rst,clk,
//     output [6:0]out0,out1,out2,out3,out4,out5,out6,out7
// );
// localparam 
//     idle = 1'b0,
//     process = 1'b1;

// reg currentState, nextState;
// reg [31:0]currentSsIn,nextSsIn;

// always @(posedge clk , negedge rst) begin
//     if (!rst) begin
//         currentState <= idle;
//         currentSsIn <= 32'b0;
//     end
//     else begin
//         currentState <= nextState;
//         currentSsIn <= nextSsIn;
//     end
// end

// always @(*) begin
//     nextState = currentState;
//     nextSsIn = currentSsIn;
//     case (currentState )
//         idle: begin
//             nextSsIn = {32{1'b1}};           // show nothing
//             if (!start)                 // start is push button work at negedge
//                 nextState = process; 
//         end
//         process: 
//             nextSsIn = {in7,in6,in5,in4,in3,in2,in1,in0};
//     endcase
// end



// SSeg  s0(.in(currentSsIn[3:0]),.out(out0));
// SSeg  s1(.in(currentSsIn[7:4]),.out(out1));
// SSeg  s2(.in(currentSsIn[11:8]),.out(out2));
// SSeg  s3(.in(currentSsIn[15:12]),.out(out3));
// SSeg  s4(.in(currentSsIn[19:16]),.out(out4));
// SSeg  s5(.in(currentSsIn[23:20]),.out(out5));
// SSeg  s6(.in(currentSsIn[27:24]),.out(out6));
// SSeg  s7(.in(currentSsIn[31:28]),.out(out7));


// endmodule // BCDtoHEX

module BCDtoHEX(
    input [4:0]in0,in1,in2,in3,in4,in5,in6,in7,
    output [6:0]out0,out1,out2,out3,out4,out5,out6,out7
);

SSeg  s0(.in(in0),.out(out0));
SSeg  s1(.in(in1),.out(out1));
SSeg  s2(.in(in2),.out(out2));
SSeg  s3(.in(in3),.out(out3));
SSeg  s4(.in(in4),.out(out4));
SSeg  s5(.in(in5),.out(out5));
SSeg  s6(.in(in6),.out(out6));
SSeg  s7(.in(in7),.out(out7));


endmodule // BCDtoHEX