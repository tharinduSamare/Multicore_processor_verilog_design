module timeCounter (
    input clk, rstN, startN, stop,
    output [25:0]timeDuration
);
localparam  idle = 2'b0,
            counting = 2'b1,
            countEnd = 2'd2;

reg [25:0]currentTime, nextTime;
reg [1:0]currentState, nextState;

always @(posedge clk or negedge rstN) begin
    if (~rstN) begin
        currentTime <= 26'b0;
        currentState <= idle;
    end
    else begin
        currentTime <= nextTime;
        currentState <= nextState;
    end
end

always @( *) begin
    nextTime = currentTime;
    nextState = currentState;

    case (currentState)
        idle: begin
            nextTime = 26'b0;
            if (~startN) begin
                nextState = counting;
            end
        end

        counting: begin
            if (stop)begin
                nextState = countEnd;
            end
            else begin
                nextTime = currentTime + 26'b1;
            end
        end

        countEnd: begin
            //wait until reset (keep the same count)
        end

    endcase
end

assign  timeDuration = currentTime;

endmodule //timeCounter