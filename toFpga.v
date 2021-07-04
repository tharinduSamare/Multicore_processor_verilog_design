module toFpga (
    input CLOCK_50,
    input [1:0]KEY,
    input UART_RXD,
	output UART_TXD,
    output [1:0]LEDG,
    output [6:0]HEX0,HEX1,HEX2, HEX3, HEX4,HEX5, HEX6, HEX7 
);

localparam CORE_COUNT = 2;
localparam REG_WIDTH = 12;
localparam DATA_MEM_WIDTH = CORE_COUNT * REG_WIDTH;
localparam INS_WIDTH = 8;
localparam INS_MEM_DEPTH = 256;
localparam DATA_MEM_DEPTH = 4096;
localparam DATA_MEM_ADDR_WIDTH = $clog2(DATA_MEM_DEPTH);
localparam INS_MEM_ADDR_WIDTH = $clog2(INS_MEM_DEPTH);

localparam BAUD_RATE = 115200;
localparam UART_WIDTH = 8;

localparam  idle = 3'd0,
            uart_receive_Imem = 3'd1,
            uart_receive_dmem = 3'd2,
            process_ready = 3'd3,
            process_exicute = 3'd4,
            uart_transmit_dmem = 3'd5,
            finish = 3'd6;

////// logic related to data memory //////////
wire [DATA_MEM_WIDTH-1:0]DataMemOut,DataMemIn, processor_DataOut, uart_DataOut;
wire [DATA_MEM_ADDR_WIDTH-1:0]dataMemAddr, uart_dataMemAddr, processor_dataMemAddr;

////// logic related to instruction memory ///////////
wire [INS_WIDTH-1:0]InsMemOut, InsMemIn;
wire [INS_MEM_ADDR_WIDTH-1:0]insMemAddr,uart_InsMemAddr, processor_InsMemAddr;

////// other logics ////////////
wire dataMemWrEn,processor_DataMemWrEn, uart_dataMemWrEn;
wire uart_InsMemWrEn;
wire rstN, clk, start;
wire processStartN, processDone, processor_ready;

wire txReady, rxReady;
wire new_byte_indicate, new_ins_byte_indicate, new_data_byte_indicate;
wire txByteStart;

wire [UART_WIDTH-1:0]byteForTx, byteFromRx;

wire uart_DataMem_transmitted, uart_DataMem_received, uart_InsMem_received;
wire uart_dmem_start_transmit;

//////////////////////////////////////
assign LEDG[1] = processDone;
assign LEDG[0] = processor_ready;

reg [2:0]currentState, nextState; 

always @(posedge clk) begin
    if (~rstN) begin
        currentState <= idle;
    end
    else begin
        currentState <= nextState;
    end
end

always @(*) begin
    nextState = currentState;

    case (currentState)
        idle: begin     // start state
            if (~start) begin
                nextState = uart_receive_Imem;
            end
        end

        uart_receive_Imem: begin  // send the instructions (machine_code) from PC through UART
            if (uart_InsMem_received) begin
                nextState = uart_receive_dmem;
            end
        end
    
        uart_receive_dmem: begin  //send the data memory values from PC through UART
            if (uart_DataMem_received) begin
                nextState = process_exicute;
            end
        end

        process_exicute: begin  // processor exicute program (matrix multiplication)
            if (processDone) begin
                nextState = uart_transmit_dmem;
            end
        end

        uart_transmit_dmem: begin   // send the answer matrix to PC through UART
            if (uart_DataMem_transmitted) begin
                nextState = finish;
            end
        end

        finish: begin  //End of the process
            
        end

        default : nextState = idle;            
        
    endcase
end

assign clk = CLOCK_50;
assign rstN = KEY[0];
assign start = KEY[1];
assign processStartN = ((currentState == uart_receive_dmem) && (uart_DataMem_received))? 1'b0: 1'b1;
assign uart_dmem_start_transmit = ((currentState == process_exicute) && (processDone))? 1'b0: 1'b1;

assign dataMemWrEn = ((currentState == uart_receive_dmem) || (currentState == uart_transmit_dmem) )? uart_dataMemWrEn:
                    (currentState == process_exicute)? processor_DataMemWrEn:
                    1'b0;

assign dataMemAddr = ((currentState == uart_receive_dmem) || (currentState == uart_transmit_dmem) )? uart_dataMemAddr:
                    (currentState == process_exicute)? processor_dataMemAddr:
                    {DATA_MEM_ADDR_WIDTH{1'b0}};

assign DataMemIn = ((currentState == uart_receive_dmem) || (currentState == uart_transmit_dmem) )? uart_DataOut:
                    (currentState == process_exicute)? processor_DataOut:
                    {DATA_MEM_WIDTH{1'b0}};

assign insMemAddr = (currentState == uart_receive_Imem)? uart_InsMemAddr:
                    (currentState == process_exicute)? processor_InsMemAddr:
                    {INS_MEM_ADDR_WIDTH{1'b0}};

assign new_ins_byte_indicate = (currentState == uart_receive_Imem)? new_byte_indicate: 1'b0;
assign new_data_byte_indicate = (currentState == uart_receive_dmem)? new_byte_indicate: 1'b0;


multi_core_processor #(.REG_WIDTH(REG_WIDTH), .INS_WIDTH(INS_WIDTH), .CORE_COUNT(CORE_COUNT), .DATA_MEM_ADDR_WIDTH(DATA_MEM_ADDR_WIDTH), .INS_MEM_ADDR_WIDTH(INS_MEM_ADDR_WIDTH))
                    multi_core_processor(.clk(clk),.rstN(rstN),.startN(processStartN), .ProcessorDataIn(DataMemOut), .InsMemOut(InsMemOut), 
                    .ProcessorDataOut(processor_DataOut), .insMemAddr(processor_InsMemAddr), .dataMemAddr(processor_dataMemAddr),
                    .DataMemWrEn(processor_DataMemWrEn), .done(processDone), .ready(processor_ready));


////////////instantiation of memory modules for data and instruction memory

RAM #(.DATA_WIDTH(INS_WIDTH), .ADDR_WIDTH(INS_MEM_ADDR_WIDTH), .DEPTH(INS_MEM_DEPTH))
                IM(.address(insMemAddr), .clk(clk), .dataIn(InsMemIn), .wrEn(uart_InsMemWrEn), 
                .dataOut(InsMemOut)); // size = (256 x 8)

RAM #(.DATA_WIDTH(DATA_MEM_WIDTH), .ADDR_WIDTH(DATA_MEM_ADDR_WIDTH), .DEPTH(DATA_MEM_DEPTH)) 
                DM(.address(dataMemAddr), .clk(clk), .dataIn(DataMemIn), .wrEn(dataMemWrEn), 
                .dataOut(DataMemOut)); // size = (4096 x 48)


// IP_insMem IP_IM(.address(insMemAddr), .clock(clk), .data(InsMemIn), .wren(uart_InsMemWrEn), 
//                 .q(InsMemOut));  // size = (256 x 8)

// IP_dataMem IP_DM(.address(dataMemAddr), .clock(clk), .data(DataMemIn), .wren(dataMemWrEn), 
//                 .q(DataMemOut)); // size = (4096 x 48)

uart_mem_interface #(.MEM_WORD_LENGTH(DATA_MEM_WIDTH), .MEM_ADDR_LENGTH(DATA_MEM_ADDR_WIDTH), .UART_WIDTH(UART_WIDTH)) 
            dataMemInterface(.clk(clk), .rstN(rstN), .txStart(uart_dmem_start_transmit), 
            .mem_transmitted(uart_DataMem_transmitted), .mem_received(uart_DataMem_received),
            ///input outputs with memory
            .dataFromMem(DataMemOut), .memWrEn(uart_dataMemWrEn), .mem_address(uart_dataMemAddr), 
            .dataToMem(uart_DataOut), 
            ///inputs outputs with uart system
            .txByteReady(txReady), .rxByteReady(rxReady), .new_rx_byte_indicate(new_data_byte_indicate), 
            .ByteFromUart(byteFromRx), .uartTxStart(txByteStart), .byteToUart(byteForTx),
            //select start end mem addresses of tx and rx 
            .tx_start_addr_in(uartMemory[1]), .tx_end_addr_in(uartMemory[2]), 
            .rx_end_addr_in(uartMemory[0]), .toggle_addr_range(1'b1));

uart_mem_interface #(.MEM_WORD_LENGTH(INS_WIDTH), .MEM_ADDR_LENGTH(INS_MEM_ADDR_WIDTH), .UART_WIDTH(UART_WIDTH)) 
            ImemInterface(.clk(clk), .rstN(rstN), .txStart(1'b1), .mem_transmitted(), 
            .mem_received(uart_InsMem_received),
            ///input outputs with memory
            .dataFromMem(), .memWrEn(uart_InsMemWrEn), .mem_address(uart_InsMemAddr), 
            .dataToMem(InsMemIn), 
            ///inputs outputs with uart system
            .txByteReady(txReady), .rxByteReady(rxReady), .new_rx_byte_indicate(new_ins_byte_indicate), 
            .ByteFromUart(byteFromRx), .uartTxStart(), .byteToUart(),
            //select start end mem addresses of tx and rx 
            .tx_start_addr_in(), .tx_end_addr_in(), .rx_end_addr_in(),
            .toggle_addr_range(1'b0));

uart_system #(.DATA_WIDTH(UART_WIDTH), .BAUD_RATE(BAUD_RATE)) 
            US(.clk(clk), .rstN(rstN),.txByteStart(txByteStart), .rx(UART_RXD), 
                .byteForTx(byteForTx), .tx(UART_TXD), .txReady(txReady) ,.rxReady(rxReady), 
                .new_byte_indicate(new_byte_indicate), .byteFromRx(byteFromRx));

localparam  Q_end_addr_location = 12'd7,
            R_start_addr_location = 12'd5,
            R_end_addr_location = 12'd8;

reg [REG_WIDTH-1:0]uartMemory[2:0]; //0- end address of Q, 1- start address of R, 2- end address of R

always @(posedge clk) begin
    if (uart_dataMemWrEn) begin
        if (uart_dataMemAddr == Q_end_addr_location)
            uartMemory[0] <= uart_DataOut[REG_WIDTH-1:0];
        else if (uart_dataMemAddr == R_start_addr_location)
            uartMemory[1] <= uart_DataOut[REG_WIDTH-1:0];
        else if (uart_dataMemAddr == R_end_addr_location)
            uartMemory[2] <= uart_DataOut[REG_WIDTH-1:0];
    end
end

//////////////to count the time taken to the process
wire [25:0]currentTime;
timeCounter TC(.clk(clk), .rstN(rstN), .startN(processStartN), .stop(processDone), 
                .timeDuration(currentTime));

/////////////////// to show current state & no. of clock cycles on the 8 seven segments 
hex_display HD(.clk(clk), .rstN(rstN), .state(currentState), 
            .start_timeValue_convetion(~uart_DataMem_transmitted), .timeValue(currentTime), 
            .out0(HEX0), .out1(HEX1), .out2(HEX2),.out3(HEX3),.out4(HEX4),
            .out5(HEX5), .out6(HEX6), .out7(HEX7));

endmodule //toFpga

