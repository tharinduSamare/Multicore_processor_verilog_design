module uart_encoder_decoder 
#(
    parameter data_width = 12 // width of memory word
)
(
    input [data_width-1:0]dataFromMem,
    input clk,rst,txStart,
    output txReady,rxDone,
    output [data_width-1:0]dataToMem,
    output new_rx_data_indicate,

    //////////////////////// inputs outputs for the UART system
    input txByteReady,
    output txByteStart,
    output [7:0]byteForTx,

    input [7:0]byteFromRx,
    input rxByteReady,new_rx_byte_indicate
);


localparam  extra = ((data_width % 8) == 0)?0:1;
localparam count = (data_width/8) + extra;
localparam bufferWidth = count * 8;
localparam counterLength = (count<=4)? 2:
                            (count <= 8)? 3:
                            (count <= 16)? 4:
                            5;     // maximum dataWord width = (2**5)*8 = 160 (= 12 * 13 {13 cores can be used maximumly})

localparam [2:0]
            idle = 3'd0,
            transmit_1 = 3'd1,
            transmit_2 = 3'd2,
            receive_0 = 3'd3,
            receive_1 = 3'd4,
            receive_2 = 3'd5,
            receive_3 = 3'd6;

reg [2:0]currentState, nextState;
reg [bufferWidth-1:0]currentTxBuffer, nextTxBuffer;
reg [bufferWidth-1:0]currentRxBuffer, nextRxBuffer;
reg [counterLength-1:0]currentTxCount, nextTxCount;
reg [counterLength-1:0]currentRxCount, nextRxCount;

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        currentTxBuffer <= {bufferWidth{1'b0}};
        currentRxBuffer <= {bufferWidth{1'b0}};
        currentTxCount <= {counterLength{1'b0}};
        currentRxCount <= {counterLength{1'b0}};
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
            nextTxCount = {counterLength{1'b0}};
            nextRxCount = {counterLength{1'b0}};
            if (new_rx_byte_indicate) begin  //receiver indicates a arrival of new byte
                nextState = receive_1;
                nextRxBuffer = {bufferWidth{1'b0}};
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
                nextTxCount = currentTxCount + 1'b1;
                if ((currentTxCount == count-1 ) || (bufferWidth == 8))  
                    nextState = idle;
                else begin
                    nextTxBuffer = {8'b0,currentTxBuffer[bufferWidth-1:8]};
                    nextState = transmit_1;
                end
                    
            end
        end

        receive_0: begin           // to give a extra time to make rxByteReady to become 1'b0
            nextState = receive_1;
        end

        receive_1 : begin
            if(rxByteReady) begin
                nextRxCount = currentRxCount + 1'b1;
                if (bufferWidth == 8) begin
                    nextRxBuffer = byteFromRx;
                    nextState = idle;
                end
                else begin
                    nextRxBuffer = {byteFromRx,currentRxBuffer[bufferWidth-1:8]};
                    if (currentRxCount == (count-1))
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
		  
        receive_3: begin              // to give a extra time to make rxByteReady to become 1'b0
            nextState = receive_1;
        end
        
    endcase
end


assign txByteStart = (currentState == transmit_1)? 1'b0: 1'b1;
assign txReady = (currentState == idle)? 1'b1 : 1'b0;
assign byteForTx = currentTxBuffer[7:0];
assign rxDone = ((currentState == receive_1) && (rxByteReady == 1'b1) && (currentRxCount == count-1 ))? 1'b1 : 1'b0;
assign dataToMem = currentRxBuffer[data_width-1:0];
assign new_rx_data_indicate = ((currentState == idle) && (new_rx_byte_indicate))? 1'b1: 1'b0; //arrival of new data set


endmodule //uart_encoder_decoder