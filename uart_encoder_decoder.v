module uart_encoder_decoder 
#(
    parameter DATA_WIDTH = 12, // width of memory word
    parameter UART_WIDTH = 8
)
(
    input [DATA_WIDTH-1:0]dataFromMem,
    input clk,rstN,txStart,
    output txReady,rxDone,
    output [DATA_WIDTH-1:0]dataToMem,
    output new_rx_data_indicate,

    //////////////////////// inputs outputs for the UART system
    input txByteReady,
    output txByteStart,
    output [UART_WIDTH-1:0]byteForTx,

    input [UART_WIDTH-1:0]byteFromRx,
    input rxByteReady,new_rx_byte_indicate
);

localparam EXTRA = ((DATA_WIDTH % UART_WIDTH) == 0)?0:1;
localparam COUNT = (DATA_WIDTH/UART_WIDTH) + EXTRA;
localparam BUFFER_WIDTH = COUNT * UART_WIDTH;
localparam COUNTER_LENGTH = (COUNT == 1)? 1:$clog2(COUNT);

localparam [2:0]
            idle = 3'd0,
            transmit_1 = 3'd1,
            transmit_2 = 3'd2,
            receive_0 = 3'd3,
            receive_1 = 3'd4,
            receive_2 = 3'd5,
            receive_3 = 3'd6;

reg [2:0]currentState, nextState;
reg [BUFFER_WIDTH-1:0]currentTxBuffer, nextTxBuffer;
reg [BUFFER_WIDTH-1:0]currentRxBuffer, nextRxBuffer;
reg [COUNTER_LENGTH-1:0]currentTxCount, nextTxCount;
reg [COUNTER_LENGTH-1:0]currentRxCount, nextRxCount;

always @(posedge clk or negedge rstN) begin
    if (!rstN) begin
        currentTxBuffer <= {BUFFER_WIDTH{1'b0}};
        currentRxBuffer <= {BUFFER_WIDTH{1'b0}};
        currentTxCount <= {COUNTER_LENGTH{1'b0}};
        currentRxCount <= {COUNTER_LENGTH{1'b0}};
        currentState <= idle;
    end
    else begin
        currentTxBuffer <= nextTxBuffer;
        currentRxBuffer <= nextRxBuffer;
        currentTxCount <= nextTxCount;
        currentRxCount <= nextRxCount;
        currentState <= nextState;        
    end
end

always @(*) begin
    nextState = currentState;
    nextTxCount = currentTxCount;
    nextRxCount = currentRxCount;
    nextTxBuffer = currentTxBuffer;
    nextRxBuffer = currentRxBuffer;

    case (currentState)
        idle: begin
            nextTxCount = {COUNTER_LENGTH{1'b0}};
            nextRxCount = {COUNTER_LENGTH{1'b0}};
            if (new_rx_byte_indicate) begin  //receiver indicates a arrival of new byte
                nextState = receive_1;
                nextRxBuffer = {BUFFER_WIDTH{1'b0}};
            end
            else if (txStart == 1'b0) begin
                nextState = transmit_1;
                nextTxBuffer = dataFromMem;
            end
        end

        transmit_1: begin           //start byte transmission
            nextState = transmit_2;
        end


        transmit_2: begin           // end of the byte transmission
            if (txByteReady) begin
                if (BUFFER_WIDTH == UART_WIDTH) begin
                    nextState = idle;
                end    
                else begin
                    nextTxCount = currentTxCount + 1'b1;
                    if (currentTxCount == COUNT-1 )   
                        nextState = idle;
                    else begin
                        nextTxBuffer = currentTxBuffer >> UART_WIDTH;
                        nextState = transmit_1;
                    end
                end
            end
        end

        receive_0: begin           // to give a EXTRA time to make rxByteReady to become 1'b0
            nextState = receive_1;
        end

        receive_1 : begin
            if(rxByteReady) begin
                nextRxCount = currentRxCount + 1'b1;
                if (BUFFER_WIDTH == 8) begin
                    nextRxBuffer = byteFromRx;
                    nextState = idle;
                end
                else begin
                    nextRxBuffer = {byteFromRx,currentRxBuffer[BUFFER_WIDTH-1:8]};
                    if (currentRxCount == (COUNT-1))
                        nextState = idle;
                    else
                        nextState = receive_2;
                end                
            end
        end

        receive_2: begin
            if(new_rx_byte_indicate)  //receiver indicates a arrival of new byte
                nextState = receive_3;
        end
		  
        receive_3: begin              // to give a EXTRA time to make rxByteReady to become 1'b0
            nextState = receive_1;
        end
        
    endcase
end


assign txByteStart = (currentState == transmit_1)? 1'b0: 1'b1;
assign txReady = (currentState == idle)? 1'b1 : 1'b0;
assign byteForTx = currentTxBuffer[UART_WIDTH-1:0];
assign rxDone = ((currentState == receive_1) && (rxByteReady == 1'b1) && (currentRxCount == COUNT-1 ))? 1'b1 : 1'b0;
assign dataToMem = currentRxBuffer[DATA_WIDTH-1:0];
assign new_rx_data_indicate = ((currentState == idle) && (new_rx_byte_indicate))? 1'b1: 1'b0; //arrival of new data set


endmodule //uart_encoder_decoder