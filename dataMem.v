// module dataMem (
//     input clk,wrEn,
//     input [47:0]dataIn,
//     input [11:0]addr,
//     output [47:0]dataOut
// );

// reg [47:0] dMem [4095:0];

// always @(posedge clk ) begin
//     if (wrEn)
//         dMem[addr] <= dataIn;
// end

// assign dataOut = dMem[addr];

// initial begin
//     dMem[ 48'd0] =  48'd2;   //a
//     dMem[ 48'd1] =  48'd2;   //b
//     dMem[ 48'd2] =  48'd2;   //c

//     dMem[ 48'd3] =  48'd13;   //start_addr_P
//     dMem[ 48'd4] =  48'd25;   //start_addr_Q
//     dMem[ 48'd5] =  48'd35;   //start_addr_R
//     dMem[ 48'd6] =  48'd16;   //end_addr_P
//     dMem[ 48'd7] =  48'd28;   //end_addr_Q

//     dMem[ 48'd13] =  48'd1;    //matrix P
//     dMem[ 48'd14] =  48'd1;
//     dMem[ 48'd15] =  48'd1;
//     dMem[ 48'd16] =  48'd1;

//     dMem[ 48'd25] =  48'd2;   //matrix Q
//     dMem[ 48'd26] =  48'd2;
//     dMem[ 48'd27] =  48'd2;
//     dMem[ 48'd28] =  48'd2;
    
// end

// endmodule //dataMem

// module dataMem 
// #(
//     parameter data_width = 12,
//     parameter address_width = 12  // 4096 locations
// )

// (
//     input clock,wren,
//     input [data_width-1:0]data,
//     input [address_width-1:0]address,
//     output [data_width-1:0]q
// );

// localparam mem_depth = 2**address_width;

// reg [data_width-1:0] memory [mem_depth-1:0];

// always @(posedge clock ) begin
//     if (wren)
//         memory[address] <= data;
// end

// assign q = memory[address];

// // initial begin
// //     memory[ 48'd0] =  48'd2;   //a
// //     memory[ 48'd1] =  48'd2;   //b
// //     memory[ 48'd2] =  48'd2;   //c

// //     memory[ 48'd3] =  48'd13;   //start_addr_P
// //     memory[ 48'd4] =  48'd25;   //start_addr_Q
// //     memory[ 48'd5] =  48'd35;   //start_addr_R
// //     memory[ 48'd6] =  48'd16;   //end_addr_P
// //     memory[ 48'd7] =  48'd28;   //end_addr_Q

// //     memory[ 48'd13] =  48'd1;    //matrix P
// //     memory[ 48'd14] =  48'd1;
// //     memory[ 48'd15] =  48'd1;
// //     memory[ 48'd16] =  48'd1;

// //     memory[ 48'd25] =  48'd2;   //matrix Q
// //     memory[ 48'd26] =  48'd2;
// //     memory[ 48'd27] =  48'd2;
// //     memory[ 48'd28] =  48'd2;
    
// // end

// endmodule //dataMem

module dataMem 
#(
    parameter data_width = 12,
    parameter address_width = 12  // 4096 locations
)

(
    input clock,wren,
    input [data_width-1:0]data,
    input [address_width-1:0]address,
    output reg [data_width-1:0]q
);

localparam mem_depth = 2**address_width;

reg [data_width-1:0] memory [mem_depth-1:0];

always @(posedge clock) begin
    if (wren) begin
        memory[address] <= data;
    end
    q <= memory[address];
end

endmodule //dataMem