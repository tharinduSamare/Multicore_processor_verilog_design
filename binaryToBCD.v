module binaryToBCD(
    input [25:0]binaryValue,                    // to get 8 digit output need 26.57 input bits (26) {can not exeed 26.57}
    input clk,rst,start,
    output reg ready, done,
    output reg [3:0]digit7,digit6,digit5,digit4,digit3,digit2,digit1,digit0
);

localparam [1:0]
    idle = 2'b00,
    subtract = 2'b01,
    shift = 2'b10,
    over = 2'b11;

reg [4:0]currentCount,nextCount;           //count upto 26
reg [31:0]currentValue,nextValue;
reg [1:0]currentState,nextState;
reg [25:0]currentInput,nextInput;

always @(posedge clk,negedge rst) begin
    if (!rst) begin
        currentCount <= 5'b0;
        currentValue <= 32'b0;
        currentState <= idle;
        currentInput <= 26'b0;
    end else begin
        currentValue <= nextValue;
        currentCount <= nextCount;
        currentState <= nextState;
        currentInput <= nextInput;
    end
end

always @(*) begin
    nextCount = currentCount;
    nextValue = currentValue;
    nextState = currentState;
    nextInput = currentInput;
    {digit7,digit6,digit5,digit4,digit3,digit2,digit1,digit0} = 32'b0;
    ready = 1'b0;
    done = 1'b1;     // actives the BCDtoHEX by the negedge
    
    case (currentState)
        idle: begin
            {digit7,digit6,digit5,digit4,digit3,digit2,digit1,digit0} = currentValue;
            ready = 1'b1;
            if (!start) begin        // KEY is push button stay at 1 normally
                nextState = subtract;
                ready = 1'b0;
                nextCount = 5'b0;
                nextInput = binaryValue;
				nextValue = 32'b0;
            end
        end

        subtract: begin
            if (currentValue[3:0]>4)
                nextValue[3:0] = currentValue[3:0]+4'b0011;
            if (currentValue[7:4]>4)
                nextValue[7:4] = currentValue[7:4]+4'b0011;
            if (currentValue[11:8]>4)
                nextValue[11:8] = currentValue[11:8]+4'b0011;
            if (currentValue[15:12]>4)
                nextValue[15:12] = currentValue[15:12]+4'b0011;
            if (currentValue[19:16]>4)
                nextValue[19:16] = currentValue[19:16]+4'b0011;
            if (currentValue[23:20]>4)
                nextValue[23:20] = currentValue[23:20]+4'b0011;
            if (currentValue[27:24]>4)
                nextValue[27:24] = currentValue[27:24]+4'b0011;
            if (currentValue[31:28]>4)
                nextValue[31:28] = currentValue[31:28]+4'b0011;

            nextState = shift;
        end

        shift: begin
            nextInput[25:1] = currentInput[24:0];
            nextValue = {currentValue[30:0],currentInput[25]};
            nextCount = currentCount+5'b1;

            if (currentCount<5'd25)
                nextState = subtract;
            else
                nextState = over;
        end

        over: begin
            nextState = idle;
            done = 1'b0;
				{digit7,digit6,digit5,digit4,digit3,digit2,digit1,digit0} = currentValue;
        end   
    endcase
end

endmodule // binaryToBCD