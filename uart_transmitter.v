module uart_transmitter 
#(
    parameter DATA_WIDTH = 8
)
(
    input [DATA_WIDTH-1:0]dataIn,
    input clk, baudTick,rstN,txStart,
    output tx,TxReady
);

localparam [1:0]
                idle = 2'd0,
                start = 2'd1,
                data = 2'd2,
                stop = 2'd3;

reg [1:0]currentState, nextState;
reg [DATA_WIDTH-1:0]currentData, nextData;
reg currentBit, nextBit;
reg [2:0]currentCount, nextCount;
reg [3:0]currentTick, nextTick;


always @(posedge clk or negedge rstN) begin
    if (~rstN) begin
        currentTick <= 4'b0;
        currentCount <= 3'b0;
        currentState <= idle;
        currentData <= 0;
        currentBit <= 1'b1;
    end
    else begin
        currentTick <= nextTick;
        currentCount <= nextCount;
        currentState <= nextState;
        currentData <= nextData;
        currentBit <= nextBit;
    end    
end

always @(*) begin
    nextTick = currentTick;
    nextCount = currentCount;
    nextState = currentState;
    nextData = currentData;
    nextBit = currentBit;

    case (currentState) 
        idle: begin
            if (~txStart) begin
                nextState = start;
                nextTick = 4'b0;
                nextBit = 1'b0;
                nextData = dataIn;
            end
            else
                nextBit = 1'b1;
        end

        start: begin
            if (baudTick) begin
                nextTick = currentTick + 4'b1;
                if (currentTick == 4'd15) begin
                    nextState = data;
                    nextCount = 3'b0;
                    nextBit = currentData[0];
                end
            end
        end

        data: begin
            if (baudTick) begin
                nextTick = currentTick + 4'b1;
                if (currentTick == 15) begin
                    nextCount = currentCount + 3'b1;
                    nextBit = currentData[nextCount];
                    if (currentCount ==3'd7) begin
                        nextState = stop;
                        nextBit = 1'b1;
                    end
                end
            end
        end

        stop: begin
            if (baudTick) begin
                nextTick = currentTick + 4'b1;
                if (currentTick == 4'd15)
                    nextState = idle;
            end
        end
                
    endcase
end

assign tx = currentBit;
assign  TxReady = (currentState == idle)? 1'b1:1'b0;

endmodule //uart_transmitter