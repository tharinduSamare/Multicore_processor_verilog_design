module uart_system 
#(
    parameter DATA_WIDTH = 8,
    parameter BAUD_RATE = 19200
)
(
    input clk, rstN,txByteStart,rx,
    input [DATA_WIDTH-1:0]byteForTx,
    output tx,txReady,rxReady,new_byte_indicate,
    output [DATA_WIDTH-1:0]byteFromRx
);

wire baudTick;

uart_transmitter #(.DATA_WIDTH(DATA_WIDTH)) Tx(.dataIn(byteForTx), .clk(clk), .baudTick(baudTick), .rstN(rstN), .txStart(txByteStart), .tx(tx),
             .TxReady(txReady));

uart_receiver #(.DATA_WIDTH(DATA_WIDTH)) RX(.rx(rx), .clk(clk), .rstN(rstN), .baudTick(baudTick), .dataOut(byteFromRx), .ready(rxReady),
            .new_byte_indicate(new_byte_indicate));

uart_boudRateGen #(.BAUD_RATE(BAUD_RATE)) BRG(.clk(clk), .rstN(rstN), .baudTick(baudTick));


endmodule //uart_system