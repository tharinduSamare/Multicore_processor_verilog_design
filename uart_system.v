module uart_system 
(
    input clk, rst,txByteStart,rx,
    input [7:0]byteForTx,
    output tx,txReady,rxReady,new_byte_indicate,
    output [7:0]byteFromRx
);

wire boudTick;

uart_transmitter Tx(.dataIn(byteForTx), .clk(clk), .boudTick(boudTick), .rst(rst), .txStart(txByteStart), .tx(tx),
             .TxReady(txReady));

uart_receiver RX(.rx(rx), .clk(clk), .rst(rst), .boudTick(boudTick), .dataOut(byteFromRx), .ready(rxReady),
            .new_byte_indicate(new_byte_indicate));

uart_boudRateGen BRG(.clk(clk), .rst(rst), .boudTick(boudTick));


endmodule //uart_system