module hex_display (
    input clk, rst, 
    input [2:0]state,
    input start_timeValue_convetion, 
    input [25:0]timeValue,
    output [6:0]out0, out1,out2,out3,out4,out5,out6,out7
);

localparam  //lettes needed to be shown on seven segments
            a = 5'd10,
            b = 5'd11,
            c = 5'd12,
            d = 5'd13,
            e = 5'd14,
            f = 5'd15,
            i = 5'd18,
            n = 5'd19,
            o = 5'd20,
            p = 5'd21,
            r = 5'd22,
            s = 5'd23,
            t = 5'd24,
            u = 5'd25,
            y = 5'd26,
            off = 5'd27;

localparam  uart_ready = 3'd0,
            uart_receive_Imem = 3'd1,
            uart_receive_dmem = 3'd2,
            process_ready = 3'd3,
            process_exicute = 3'd4,
            uart_transmit_dmem = 3'd5,
            finish = 3'd6;

reg [2:0]currentState, nextState;

wire done1;
wire [4:0]x0,x1,x2,x3,x4,x5,x6,x7;
wire [3:0]y0,y1,y2,y3,y4,y5,y6,y7;

assign {x7,x6,x5,x4,x3,x2,x1,x0} =      
        (state == uart_ready)?          {off,off,off,r,e,a,d,y}:
        (state == uart_receive_Imem)?   {u,a,r,t,off,i,n,s}:
        (state == uart_receive_dmem)?   {u,a,r,t,d,a,t,a}:
        (state == process_exicute)?     {off,p,r,o,c,e,s,s}:
        (state == uart_transmit_dmem)?  {u,a,r,t,off,a,n,s}:
        (state == finish)?              {1'b0,y7,1'b0,y6,1'b0,y5,1'b0,y4,1'b0,y3,1'b0,y2,1'b0,y1,1'b0,y0}:
        {off,off,off,off,off,off,off,off};

BCDtoHEX BtH(.in0(x0), .in1(x1), .in2(x2),.in3(x3),.in4(x4),.in5(x5),.in6(x6),.in7(x7),
            .out0(out0), .out1(out1), .out2(out2),.out3(out3),.out4(out4),.out5(out5),
            .out6(out6),.out7(out7));

binaryToBCD timeConverter(.binaryValue(timeValue),.clk(clk),.rst(rst),
                        .start(start_timeValue_convetion), .done(),.ready(), 
                        .digit7(y7),.digit6(y6),.digit5(y5),.digit4(y4),
                        .digit3(y3),.digit2(y2),.digit1(y1),.digit0(y0));

endmodule //hex_display