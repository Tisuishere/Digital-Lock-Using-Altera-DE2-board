module hex_decoder (
    input wire [3:0] hex_in,   // Mã phím (0-F)
    output reg [6:0] seg_out   // Tín hiệu ra LED 7 đoạn (Active Low)
);
    // seg_out thứ tự các bit: [g f e d c b a]
    always @(*) begin
        case (hex_in)
            4'h0: seg_out = 7'b1000000; // Hiển thị '0'
            4'h1: seg_out = 7'b1111001; // Hiển thị '1'
            4'h2: seg_out = 7'b0100100; // Hiển thị '2'
            4'h3: seg_out = 7'b0110000; // Hiển thị '3'
            4'h4: seg_out = 7'b0011001; // Hiển thị '4'
            4'h5: seg_out = 7'b0010010; // Hiển thị '5'
            4'h6: seg_out = 7'b0000010; // Hiển thị '6'
            4'h7: seg_out = 7'b1111000; // Hiển thị '7'
            4'h8: seg_out = 7'b0000000; // Hiển thị '8'
            4'h9: seg_out = 7'b0010000; // Hiển thị '9'
            4'hA: seg_out = 7'b0001000; // Hiển thị 'A'
            4'hB: seg_out = 7'b0000011; // Hiển thị 'b'
            4'hC: seg_out = 7'b1000110; // Hiển thị 'C'
            4'hD: seg_out = 7'b0100001; // Hiển thị 'd'
            4'hE: seg_out = 7'b0000110; // Hiển thị 'E'
            4'hF: seg_out = 7'b0001110; // Hiển thị 'F'
            default: seg_out = 7'b1111111; // Tắt tất cả các nét
        endcase
    end
endmodule