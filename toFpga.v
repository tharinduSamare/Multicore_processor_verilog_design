module toFpga (
    input CLOCK_50,
    input [1:0]KEY,
    input UART_RXD,
	output UART_TXD,
    output [7:0]LEDG,
    output [6:0]HEX0,HEX1,HEX2, HEX3, HEX4,HEX5, HEX6, HEX7 
);

localparam dataMemAddrLength = 12; //4096 locations
localparam dataMemWordLength = 48; // 1_core -> 12 | 2_core -> 24 | 3_core -> 36 | 4_core -> 48 etc. 
localparam insMemAddrLength = 8; //256 locations
localparam insMemWordLength = 8;

localparam  idle = 3'd0,
            uart_receive_Imem = 3'd1,
            uart_receive_dmem = 3'd2,
            process_ready = 3'd3,
            process_exicute = 3'd4,
            uart_transmit_dmem = 3'd5,
            finish = 3'd6;

wire rst, clk;
wire  processStart, processDone;

wire [dataMemWordLength-1:0]fromDataMem,toDataMem, processorDataOut, uartDataOut;
wire [dataMemAddrLength-1:0]dataMemAddr, uart_dataMemAddr, processor_dataMemAddr;

wire [insMemWordLength-1:0]instructions, uartInsOut;
wire [insMemAddrLength-1:0]insMemAddr,uart_InsMemAddr, processor_InsMemAddr;

wire dMemWrEn,processor_dMemWrEn, uart_dMemWrEn;
wire uart_InsMemWrEn;

wire txReady, rxReady;
wire new_byte_indicate, new_ins_byte_indicate, new_data_byte_indicate;
wire txByteStart;

wire [7:0]byteForTx, byteFromRx;

wire uart_DataMem_transmitted, uart_DataMem_received, uart_InsMem_received;
wire uart_dmem_start_transmit;

reg [2:0]currentState, nextState; 

always @(posedge clk or negedge rst) begin
    if (~rst) begin
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
            if (~KEY[1]) begin
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
assign rst = KEY[0];
assign processStart = ((currentState == uart_receive_dmem) && (uart_DataMem_received))? 1'b0: 1'b1;
assign uart_dmem_start_transmit = ((currentState == process_exicute) && (processDone))? 1'b0: 1'b1;

assign dMemWrEn = ((currentState == uart_receive_dmem) || (currentState == uart_transmit_dmem) )? uart_dMemWrEn:
                    (currentState == process_exicute)? processor_dMemWrEn:
                    1'b0;

assign dataMemAddr = ((currentState == uart_receive_dmem) || (currentState == uart_transmit_dmem) )? uart_dataMemAddr:
                    (currentState == process_exicute)? processor_dataMemAddr:
                    {dataMemAddrLength{1'b0}};

assign toDataMem = ((currentState == uart_receive_dmem) || (currentState == uart_transmit_dmem) )? uartDataOut:
                    (currentState == process_exicute)? processorDataOut:
                    {dataMemWordLength{1'b0}};

assign insMemAddr = (currentState == uart_receive_Imem)? uart_InsMemAddr:
                    (currentState == process_exicute)? processor_InsMemAddr:
                    {insMemAddrLength{1'b0}};

assign new_ins_byte_indicate = (currentState == uart_receive_Imem)? new_byte_indicate: 1'b0;
assign new_data_byte_indicate = (currentState == uart_receive_dmem)? new_byte_indicate: 1'b0;

// This is a 4 core processor (No. of cores can be increased)   
//4 cores (instances) are instantiated using processor module

processor CORE_0(.clk(clk), .rst(rst), .start(processStart), .fromDataMem(fromDataMem[11:0]), 
            .fromInsMem(instructions), .dataMemAddr(processor_dataMemAddr), .toDataMem(processorDataOut[11:0]), 
            .insMemAddr(processor_InsMemAddr), .dMemWrEn(processor_dMemWrEn), .done(processDone), .ready());

processor CORE_1(.clk(clk), .rst(rst), .start(processStart), .fromDataMem(fromDataMem[23:12]), 
            .fromInsMem(instructions), .dataMemAddr(), .toDataMem(processorDataOut[23:12]), 
            .insMemAddr(), .dMemWrEn(), .done(), .ready());

processor CORE_2(.clk(clk), .rst(rst), .start(processStart), .fromDataMem(fromDataMem[35:24]), 
            .fromInsMem(instructions), .dataMemAddr(), .toDataMem(processorDataOut[35:24]), 
            .insMemAddr(), .dMemWrEn(), .done(), .ready());

processor CORE_3(.clk(clk), .rst(rst), .start(processStart), .fromDataMem(fromDataMem[47:36]), 
            .fromInsMem(instructions), .dataMemAddr(), .toDataMem(processorDataOut[47:36]), 
            .insMemAddr(), .dMemWrEn(), .done(), .ready());

////////////instantiation of memory modules for data and instruction memory

insMem #(.data_width(insMemWordLength), .address_width(insMemAddrLength))
                IM(.address(insMemAddr), .clock(clk), .data(uartInsOut), .wren(uart_InsMemWrEn), 
                .q(instructions)); // size = (256 x 8)

dataMem #(.data_width(dataMemWordLength), .address_width(dataMemAddrLength)) 
                DM(.address(dataMemAddr), .clock(clk), .data(toDataMem), .wren(dMemWrEn), 
                .q(fromDataMem)); // size = (4096 x 48)


// IP_insMem IP_IM(.address(insMemAddr), .clock(clk), .data(uartInsOut), .wren(uart_InsMemWrEn), 
//                 .q(instructions));  // size = (256 x 8)

// IP_dataMem IP_DM(.address(dataMemAddr), .clock(clk), .data(toDataMem), .wren(dMemWrEn), 
//                 .q(fromDataMem)); // size = (4096 x 48)

uart_mem_interface #(.memWordLength(dataMemWordLength), .memAddressLength(dataMemAddrLength)) 
            dataMemInterface(.clk(clk), .rst(rst), .txStart(uart_dmem_start_transmit), 
            .mem_transmitted(uart_DataMem_transmitted), .mem_received(uart_DataMem_received),
            ///input outputs with memory
            .dataFromMem(fromDataMem), .memWrEn(uart_dMemWrEn), .mem_address(uart_dataMemAddr), 
            .dataToMem(uartDataOut), 
            ///inputs outputs with uart system
            .txByteReady(txReady), .rxByteReady(rxReady), .new_rx_byte_indicate(new_data_byte_indicate), 
            .ByteFromUart(byteFromRx), .uartTxStart(txByteStart), .byteToUart(byteForTx),
            //select start end mem addresses of tx and rx 
            .tx_start_addr_in(uartMemory[1]), .tx_end_addr_in(uartMemory[2]), 
            .rx_end_addr_in(uartMemory[0]), .toggle_addr_range(1'b1));

uart_mem_interface #(.memWordLength(insMemWordLength), .memAddressLength(insMemAddrLength)) 
            ImemInterface(.clk(clk), .rst(rst), .txStart(1'b1), .mem_transmitted(), 
            .mem_received(uart_InsMem_received),
            ///input outputs with memory
            .dataFromMem(), .memWrEn(uart_InsMemWrEn), .mem_address(uart_InsMemAddr), 
            .dataToMem(uartInsOut), 
            ///inputs outputs with uart system
            .txByteReady(txReady), .rxByteReady(rxReady), .new_rx_byte_indicate(new_ins_byte_indicate), 
            .ByteFromUart(byteFromRx), .uartTxStart(), .byteToUart(),
            //select start end mem addresses of tx and rx 
            .tx_start_addr_in(), .tx_end_addr_in(), .rx_end_addr_in(),
            .toggle_addr_range(1'b0));

uart_system US(.clk(clk), .rst(rst),.txByteStart(txByteStart), .rx(UART_RXD), 
                .byteForTx(byteForTx), .tx(UART_TXD), .txReady(txReady) ,.rxReady(rxReady), 
                .new_byte_indicate(new_byte_indicate), .byteFromRx(byteFromRx));

localparam  Q_end_addr_location = 12'd7,
            R_start_addr_location = 12'd5,
            R_end_addr_location = 12'd8;

reg [11:0]uartMemory[2:0]; //0- end address of Q, 1- start address of R, 2- end address of R

always @(posedge clk) begin
    if (uart_dMemWrEn) begin
        if (uart_dataMemAddr == Q_end_addr_location)
            uartMemory[0] <= uartDataOut[11:0];
        else if (uart_dataMemAddr == R_start_addr_location)
            uartMemory[1] <= uartDataOut[11:0];
        else if (uart_dataMemAddr == R_end_addr_location)
            uartMemory[2] <= uartDataOut[11:0];
    end
end

//////////////to count the time taken to the process
wire [25:0]currentTime;
timeCounter TC(.clk(clk), .rst(rst), .start(processStart), .stop(processDone), 
                .timeDuration(currentTime));

/////////////////// to show current state & no. of clock cycles on the 8 seven segments 
hex_display HD(.clk(clk), .rst(rst), .state(currentState), 
            .start_timeValue_convetion(~uart_DataMem_transmitted), .timeValue(currentTime), 
            .out0(HEX0), .out1(HEX1), .out2(HEX2),.out3(HEX3),.out4(HEX4),
            .out5(HEX5), .out6(HEX6), .out7(HEX7));

// reg [47:0]mem_check[4095:0];

// wire [47:0]a;
// assign  a = mem_check[0];
// assign LEDG = a[7:0];
// dataMem #(.data_width(dataMemWordLength), .address_width(dataMemAddrLength))
//                 DM(.address({dataMemAddrLength{1'b0}}), .clock(clk), .data(8'd4), .wren(1'b0), 
//                 .q(a)); // size = (4096 x 48)

endmodule //toFpga

