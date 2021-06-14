module uart_receiver (
    input rx, clk, rst, boudTick,
    output ready, 
    output [7:0]dataOut,
    output new_byte_indicate
);

localparam [1:0]
            idle = 2'b0,
            start = 2'b1,
            data = 2'd2,
            stop = 2'd3;

reg [1:0]currentState, nextState;
reg [2:0]currentCount,nextCount;
reg [3:0]currentTick, nextTick;
reg [7:0]currentData, nextData;

always @(posedge clk or negedge rst) begin
    if(~rst) begin
        currentState <= idle;
        currentCount <= 3'b0;
        currentTick <= 4'b0;
        currentData <= 8'b0;
    end
    else begin
        currentState <= nextState;
        currentCount <= nextCount;
        currentTick <= nextTick;
        currentData <= nextData;
    end
end

always @(*) begin
    nextState = currentState;
    nextCount = currentCount;
    nextTick = currentTick;
    nextData = currentData;

    case (currentState )
        idle: begin
            nextTick = 4'b0;
            nextCount = 3'b0;
            if (rx == 1'b0) begin
                nextState = start;
            end
        end

        start: begin
           if (boudTick) begin
               nextTick = currentTick + 4'b1;
               if (currentTick == 4'd7) begin
                   if (~rx) begin
                        nextState = data;
                        nextCount = 3'b0;
                        nextTick = 4'b0;
                        nextData = 8'b0;
                   end
                   else begin
                       nextState = idle;

                   end
                   
               end
           end 
        end

        data: begin
            if (boudTick) begin
                nextTick = currentTick + 4'b1;
                if (currentTick == 4'd15) begin
                    nextData[currentCount] = rx;
                    nextCount = currentCount + 3'b1;
                    if (currentCount == 3'd7) begin
                        // nextTick = 4'b0;  //////////////////////////
                        nextState = stop;
                    end
                end
            end
        end

        stop: begin
            if (boudTick) begin
                nextTick = currentTick + 4'b1;
                if (currentTick == 4'd15) begin
                    nextState = idle;
                end
            end
        end

    endcase
end

assign dataOut = currentData;
assign ready = (currentState == idle)? 1'b1: 1'b0;
assign new_byte_indicate = ((currentState == start) && (boudTick) && (currentTick == 4'd7) && (~rx))? 1'b1:1'b0; //start of new data byte

endmodule //uart_receiver