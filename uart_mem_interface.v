module uart_mem_interface 
#(
    parameter memWordLength = 12,
    parameter memAddressLength = 12
)
 (
     //////////////input output with main program
    input clk,rst,txStart,
    output mem_transmitted, mem_received,

    //select start end mem addresses of tx and rx 
    input [memAddressLength-1:0]tx_start_addr_in,tx_end_addr_in,rx_end_addr_in,
    input toggle_addr_range,   // 0 - go untill the last address of the memory, 1 - consider inputted start, end addresses

    /////////////////inputs outputs with memory
    input [memWordLength-1:0]dataFromMem,
    output memWrEn,
    output [memAddressLength-1:0]mem_address,
    output [memWordLength-1:0]dataToMem,
    
    ////////////////////inputs outputs with uart system

    input txByteReady,rxByteReady,new_rx_byte_indicate,
    input [7:0]ByteFromUart,
    output uartTxStart, 
    output [7:0]byteToUart  
);

wire startTranmit,txReady,rxDone;
wire new_rx_data_indicate;

wire [memAddressLength-1:0]tx_start_addr, tx_end_addr, rx_end_addr;

localparam [2:0]
                idle = 3'b0,
                transmit_0 = 3'd1,
                transmit_1 = 3'd2,
                transmit_2 = 3'd3,
                transmit_3 = 3'd4,
                receive_0 = 3'd5,
                receive_1 = 3'd6,
                receive_2 = 3'd7;


reg [memAddressLength-1:0]currentAddress, nextAddress;
reg [2:0]currentState, nextState;
reg currentStartTransmit, nextStartTranmit;


always @(posedge clk or negedge rst) begin
    if (~rst) begin
        currentState <= idle;
        currentAddress <= {memAddressLength{1'b0}};
        currentStartTransmit <= 1'b1; //starts if value is zero
    end
    else begin
        currentState <= nextState;
        currentAddress <= nextAddress;
        currentStartTransmit <= nextStartTranmit;
    end
end

always @(*) begin
    nextState = currentState;
    nextAddress = currentAddress;
    nextStartTranmit = currentStartTransmit;

    case (currentState)
        idle: begin
            nextAddress = {memAddressLength{1'b0}};
            nextStartTranmit = 1'b1;    //to transmit this should be zero
            if (new_rx_data_indicate)
                nextState = receive_0;
            else if (~txStart) begin
                nextState = transmit_0;
                nextAddress = tx_start_addr;
            end
        end
        //transmission process starts here
        transmit_0: begin         // to give the address to memory
            nextState = transmit_1;
        end

        transmit_1: begin       // extra delay for ip core memory
            nextStartTranmit = 1'b0;
            nextState = transmit_2;
        end

        transmit_2: begin         // start uart transmitter
            nextStartTranmit = 1'b0;
            nextState = transmit_3;
        end

        transmit_3: begin        // find end of the uart transmission
            nextStartTranmit = 1'b1;
            if (txReady == 1'b1) begin
                if (currentAddress == tx_end_addr) begin
                    nextState = idle;                    
                end
                else begin
                    nextAddress = currentAddress + {{memAddressLength-1{1'b0}} , 1'b1};
                    nextState = transmit_0;
                end
            end
        end
        //receiving process starts here
        receive_0: begin            // to find the end of the uart receiving
            if (rxDone) begin
                nextState = receive_1;
            end
        end

        receive_1: begin           // store in the memory (no need extra delay as it is explicitly given in receive_0)
            nextState = receive_2;
        end

        receive_2: begin            //to find the end of the receiving process
            if (currentAddress == rx_end_addr) begin
                nextState = idle; 
            end
            else begin
                nextAddress = currentAddress + {{memAddressLength-1{1'b0}} , 1'b1};
                nextState = receive_0;   
            end                           
        end
    endcase
end

assign startTranmit = currentStartTransmit;
assign memWrEn = (currentState == receive_1)? 1'b1: 1'b0;
assign mem_received = ((currentState == receive_2) && (currentAddress == rx_end_addr))? 1'b1: 1'b0;
assign mem_transmitted = ((currentState == transmit_3) && (txReady == 1'b1) && (currentAddress == tx_end_addr))? 1'b1: 1'b0;

assign mem_address = currentAddress;


// encoder_decoder #(.data_width(memWordLength)) US(.dataIn(uartDataIn), .clk(clk), .rst(rst),.txStart(startTranmit), .rx(rx), .tx(tx), 
//                 .txReady(txReady), .rxDone(rxDone), .dataOut(uartDataOut), .uart_state(uart_state), .tx_state(tx_state),
//                 .new_rx_data_indicate(new_rx_data_indicate));

uart_encoder_decoder #(.data_width(memWordLength)) ED(.dataFromMem(dataFromMem), .clk(clk), .rst(rst), .txStart(startTranmit),
                    .txReady(txReady), .rxDone(rxDone), .dataToMem(dataToMem), .new_rx_data_indicate(new_rx_data_indicate),
                    .txByteReady(txByteReady), .txByteStart(uartTxStart), .byteForTx(byteToUart), .byteFromRx(ByteFromUart),
                    .rxByteReady(rxByteReady), .new_rx_byte_indicate(new_rx_byte_indicate));

// memory mem(.address(address), .clock(clk), .data(uartDataOut), .wren(memWrEn), .q(uartDataIn));
//mem_2 mem(.address(address), .clock(clk), .data(uartDataOut), .wren(memWrEn), .q(uartDataIn));

assign tx_start_addr = (toggle_addr_range == 1'b0)? {memAddressLength{1'b0}}: tx_start_addr_in;
assign tx_end_addr = (toggle_addr_range == 1'b0)? {memAddressLength{1'b1}}: tx_end_addr_in;

assign rx_end_addr = (toggle_addr_range == 1'b0)? {memAddressLength{1'b1}}:
                        (rx_end_addr_in == 0)? {{memAddressLength-4{1'b0}}, {4{1'b1}}}: //give 31 as the end rx address if input addr is small
                        rx_end_addr_in;

endmodule //uart_mem_interface