// module insMem (
//     input [7:0]addr,
//     output [7:0]dataOut
// );

// reg [7:0]IMem[127:0];

// assign dataOut = IMem[addr];

// initial begin
//     IMem[8'd0] = 8'd2;
//     IMem[8'd1] = 8'd3;
//     IMem[8'd2] = 8'd1; // address of b
//     IMem[8'd3] = {4'd1,4'd15};
//     IMem[8'd4] = 8'd3;
//     IMem[8'd5] = 8'd3; // address of start P
//     IMem[8'd6] = {4'd2,4'd15};
//     IMem[8'd7] = 8'd3;
//     IMem[8'd8] = 8'd4; //start address of Q
//     IMem[8'd9] = {4'd3,4'd15};
//     IMem[8'd10] = 8'd3;
//     IMem[8'd11] = 8'd3; // start address of P
//     IMem[8'd12] = {4'd5,4'd15};
//     IMem[8'd13] = 8'd6;
//     IMem[8'd14] = 8'd8; // current address of P
//     IMem[8'd15] = 8'd3;
//     IMem[8'd16] = 8'd4; // start address of Q
//     IMem[8'd17] = {4'd5,4'd15};
//     IMem[8'd18] = 8'd6;
//     IMem[8'd19] = 8'd9; // current address of Q
//     IMem[8'd20] = 8'd3;
//     IMem[8'd21] = 8'd5; // Start address of R
//     IMem[8'd22] = {4'd5,4'd15};
//     IMem[8'd23] = 8'd6;
//     IMem[8'd24] = 8'd10; // current address of R
//     IMem[8'd25] = 8'd2;
//     IMem[8'd26] = {4'd4,4'd15};
//     IMem[8'd27] = {4'd7,4'd15}; //loop start
//     IMem[8'd28] = 8'd4;
//     IMem[8'd29] = {4'd6,4'd15};
//     IMem[8'd30] = {4'd8,4'd15};
//     IMem[8'd31] = 8'd4;
//     IMem[8'd32] = 8'd10;
//     IMem[8'd33] = 8'd11;
//     IMem[8'd34] = {4'd5,4'd15};
//     IMem[8'd35] = {4'd9,4'd15};
//     IMem[8'd36] = 8'd12;
//     IMem[8'd37] = 8'd8;
//     IMem[8'd38] = 8'd27;  // loop again
//     IMem[8'd39] = 8'd3;
//     IMem[8'd40] = 8'd10; // current address of R
//     IMem[8'd41] = 8'd5;
//     IMem[8'd42] = 8'd13;
//     IMem[8'd43] = {4'd5,4'd15};
//     IMem[8'd44] = 8'd6;
//     IMem[8'd45] = 8'd10; // current address of R
//     IMem[8'd46] = {4'd8,4'd15};
//     IMem[8'd47] = {4'd4,4'd15};
//     IMem[8'd48] = 8'd3; 
//     IMem[8'd49] = 8'd9; // current address of Q
//     IMem[8'd50] = 8'd12;
//     IMem[8'd51] = 8'd8;
//     IMem[8'd52] = 8'd55; // b != end
//     IMem[8'd53] = 8'd7;
//     IMem[8'd54] = 8'd60; // b == end
//     IMem[8'd55] = 8'd3;  // b!= end starts here
//     IMem[8'd56] = 8'd8; //current address of P
//     IMem[8'd57] = {4'd2,4'd15};
//     IMem[8'd58] = 8'd7;
//     IMem[8'd59] = 8'd25; // jump to CLAC (before loop)
//     IMem[8'd60] = {4'd7,4'd15}; // b== end starts here
//     IMem[8'd61] = {4'd4,4'd15};
//     IMem[8'd62] = 8'd3;
//     IMem[8'd63] = 8'd6; //end address P
//     IMem[8'd64] = 8'd12;
//     IMem[8'd65] = 8'd8;
//     IMem[8'd66] = 8'd69; //jump to a!= end
//     IMem[8'd67] = 8'd7;
//     IMem[8'd68] = 8'd74; //jump to a== end
//     IMem[8'd69] = 8'd3; //a!=end starts here
//     IMem[8'd70] = 8'd4;  // start address of Q
//     IMem[8'd71] = {4'd3,4'd15};
//     IMem[8'd72] = 8'd7;
//     IMem[8'd73] = 8'd25; //jump to CLAC (before loop)
//     IMem[8'd74] = 8'd1; //a==end starts here

// end

// endmodule //insMem

module insMem 
#(
    parameter data_width = 8,
    parameter address_width = 8  // 256 locations
)

(
    input clock,wren,
    input [data_width-1:0]data,
    input [address_width-1:0]address,
    output reg [data_width-1:0]q
);

localparam mem_depth = 2**address_width;

reg [data_width-1:0] memory [mem_depth-1:0];

always @(posedge clock ) begin
    if (wren)
        memory[address] <= data;
    q <= memory[address];
end

// initial begin
//     IMem[8'd0] = 8'd2;
//     IMem[8'd1] = 8'd3;
//     IMem[8'd2] = 8'd1; // address of b
//     IMem[8'd3] = {4'd1,4'd15};
//     IMem[8'd4] = 8'd3;
//     IMem[8'd5] = 8'd3; // address of start P
//     IMem[8'd6] = {4'd2,4'd15};
//     IMem[8'd7] = 8'd3;
//     IMem[8'd8] = 8'd4; //start address of Q
//     IMem[8'd9] = {4'd3,4'd15};
//     IMem[8'd10] = 8'd3;
//     IMem[8'd11] = 8'd3; // start address of P
//     IMem[8'd12] = {4'd5,4'd15};
//     IMem[8'd13] = 8'd6;
//     IMem[8'd14] = 8'd8; // current address of P
//     IMem[8'd15] = 8'd3;
//     IMem[8'd16] = 8'd4; // start address of Q
//     IMem[8'd17] = {4'd5,4'd15};
//     IMem[8'd18] = 8'd6;
//     IMem[8'd19] = 8'd9; // current address of Q
//     IMem[8'd20] = 8'd3;
//     IMem[8'd21] = 8'd5; // Start address of R
//     IMem[8'd22] = {4'd5,4'd15};
//     IMem[8'd23] = 8'd6;
//     IMem[8'd24] = 8'd10; // current address of R
//     IMem[8'd25] = 8'd2;
//     IMem[8'd26] = {4'd4,4'd15};
//     IMem[8'd27] = {4'd7,4'd15}; //loop start
//     IMem[8'd28] = 8'd4;
//     IMem[8'd29] = {4'd6,4'd15};
//     IMem[8'd30] = {4'd8,4'd15};
//     IMem[8'd31] = 8'd4;
//     IMem[8'd32] = 8'd10;
//     IMem[8'd33] = 8'd11;
//     IMem[8'd34] = {4'd5,4'd15};
//     IMem[8'd35] = {4'd9,4'd15};
//     IMem[8'd36] = 8'd12;
//     IMem[8'd37] = 8'd8;
//     IMem[8'd38] = 8'd27;  // loop again
//     IMem[8'd39] = 8'd3;
//     IMem[8'd40] = 8'd10; // current address of R
//     IMem[8'd41] = 8'd5;
//     IMem[8'd42] = 8'd13;
//     IMem[8'd43] = {4'd5,4'd15};
//     IMem[8'd44] = 8'd6;
//     IMem[8'd45] = 8'd10; // current address of R
//     IMem[8'd46] = {4'd8,4'd15};
//     IMem[8'd47] = {4'd4,4'd15};
//     IMem[8'd48] = 8'd3; 
//     IMem[8'd49] = 8'd9; // current address of Q
//     IMem[8'd50] = 8'd12;
//     IMem[8'd51] = 8'd8;
//     IMem[8'd52] = 8'd55; // b != end
//     IMem[8'd53] = 8'd7;
//     IMem[8'd54] = 8'd60; // b == end
//     IMem[8'd55] = 8'd3;  // b!= end starts here
//     IMem[8'd56] = 8'd8; //current address of P
//     IMem[8'd57] = {4'd2,4'd15};
//     IMem[8'd58] = 8'd7;
//     IMem[8'd59] = 8'd25; // jump to CLAC (before loop)
//     IMem[8'd60] = {4'd7,4'd15}; // b== end starts here
//     IMem[8'd61] = {4'd4,4'd15};
//     IMem[8'd62] = 8'd3;
//     IMem[8'd63] = 8'd6; //end address P
//     IMem[8'd64] = 8'd12;
//     IMem[8'd65] = 8'd8;
//     IMem[8'd66] = 8'd69; //jump to a!= end
//     IMem[8'd67] = 8'd7;
//     IMem[8'd68] = 8'd74; //jump to a== end
//     IMem[8'd69] = 8'd3; //a!=end starts here
//     IMem[8'd70] = 8'd4;  // start address of Q
//     IMem[8'd71] = {4'd3,4'd15};
//     IMem[8'd72] = 8'd7;
//     IMem[8'd73] = 8'd25; //jump to CLAC (before loop)
//     IMem[8'd74] = 8'd1; //a==end starts here
// end

endmodule //insMem