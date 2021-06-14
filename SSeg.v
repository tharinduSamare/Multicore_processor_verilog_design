// module SSeg(
//     input [3:0]in,
//     output reg [6:0]out
// );

// always @(*) begin
//     case (in)
//         4'd0:out = 7'b1000000;
//         4'd1:out = 7'b1111001;
//         4'd2:out = 7'b0100100;
//         4'd3:out = 7'b0110000; 
//         4'd4:out = 7'b0011001;
//         4'd5:out = 7'b0010010;
//         4'd6:out = 7'b0000010;
//         4'd7:out = 7'b1111000;
//         4'd8:out = 7'b0000000;
//         4'd9:out = 7'b0011000;
//         4'ha:out = 7'b0001000;
//         4'hb:out = 7'b0000011;
//         4'hc:out = 7'b1000110;
//         4'hd:out = 7'b0100001;
//         4'he:out = 7'b0000110;

//         default: out = 7'b1111111;
//     endcase
// end


// endmodule // SSeg

module SSeg(
    input [4:0]in,
    output reg [6:0]out
);

localparam 
            a = 5'd10,
            b = 5'd11,
            c = 5'd12,
            d = 5'd13,
            e = 5'd14,
            f = 5'd15,
            i = 5'd18,
            n = 5'd19,
            o = 5'd20,
            p = 5'd21,
            r = 5'd22,
            s = 5'd23,
            t = 5'd24,
            u = 5'd25,
            y = 5'd26,
            off = 5'd27;


always @(*) begin
    case (in)
        5'd0:out = 7'b1000000;
        5'd1:out = 7'b1111001;
        5'd2:out = 7'b0100100;
        5'd3:out = 7'b0110000; 
        5'd4:out = 7'b0011001;
        5'd5:out = 7'b0010010;
        5'd6:out = 7'b0000010;
        5'd7:out = 7'b1111000;
        5'd8:out = 7'b0000000;
        5'd9:out = 7'b0011000;
        5'ha:out = 7'b0001000;
        5'hb:out = 7'b0000011;
        5'hc:out = 7'b1000110;
        5'hd:out = 7'b0100001;
        5'he:out = 7'b0000110;
        5'hf:out = 7'b0001110;
        i   :out = 7'b1110000;
        n   :out = 7'b0001011;
        o   :out = 7'b1000000;
        p   :out = 7'b0001100;
        r   :out = 7'b1001110;
        s   :out = 7'b0010010;
        t   :out = 7'b0000111;
        u   :out = 7'b1000001;
        y   :out = 7'b0010001;
        off :out = 7'b1111111;

        default: out = 7'b1111111;
    endcase
end


endmodule // SSeg