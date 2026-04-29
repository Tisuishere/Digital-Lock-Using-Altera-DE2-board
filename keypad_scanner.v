module keypad_scanner (
    input wire clk,             // Xung clock 1kHz
    input wire [3:0] col,       // Tín hiệu từ 4 cột của Keypad (Cần pull-up)
    output reg [3:0] row,       // Tín hiệu kích cho 4 hàng của Keypad
    output reg [3:0] data_out,  // Mã phím bấm (0-F)
    output reg valid            // Cờ xác nhận có phím hợp lệ đang được nhấn
);
    reg [1:0] state = 0;

    always @(posedge clk) begin
        case (state)
            // QUÉT HÀNG 0 (FPGA tưởng là hàng 0, nhưng thực tế dây Hàng 3 đang cắm ở đây)
            2'b00: begin
                row <= 4'b1110; 
                if (col != 4'b1111) begin
                    valid <= 1;
                    case (col)
                        4'b1110: data_out <= 4'hE; // Nhấn * ra 1 -> Sửa thành E (Mã của *)
                        4'b1101: data_out <= 4'h0; // Nhấn 0 ra 2 -> Sửa thành 0
                        4'b1011: data_out <= 4'hF; // Nhấn # ra 3 -> Sửa thành F (Mã của #)
                        4'b0111: data_out <= 4'hD; // Nhấn D ra A -> Sửa thành D
                        default: data_out <= data_out;
                    endcase
                end else begin
                    valid <= 0;
                    state <= 2'b01; 
                end
            end
            
            // QUÉT HÀNG 1 (FPGA tưởng là hàng 1, nhưng thực tế dây Hàng 0 đang cắm ở đây)
            2'b01: begin
                row <= 4'b1101; 
                if (col != 4'b1111) begin
                    valid <= 1;
                    case (col)
                        4'b1110: data_out <= 4'h1; // Nhấn 1 ra 4 -> Sửa thành 1
                        4'b1101: data_out <= 4'h2; // Nhấn 2 ra 5 -> Sửa thành 2
                        4'b1011: data_out <= 4'h3; // Nhấn 3 ra 6 -> Sửa thành 3
                        4'b0111: data_out <= 4'hA; // Nhấn A ra B -> Sửa thành A
                        default: data_out <= data_out;
                    endcase
                end else begin
                    valid <= 0;
                    state <= 2'b10;
                end
            end
            
            // QUÉT HÀNG 2 (FPGA tưởng là hàng 2, nhưng thực tế dây Hàng 1 đang cắm ở đây)
            2'b10: begin
                row <= 4'b1011; 
                if (col != 4'b1111) begin
                    valid <= 1;
                    case (col)
                        4'b1110: data_out <= 4'h4; // Nhấn 4 ra 7 -> Sửa thành 4
                        4'b1101: data_out <= 4'h5; // Nhấn 5 ra 8 -> Sửa thành 5
                        4'b1011: data_out <= 4'h6; // Nhấn 6 ra 9 -> Sửa thành 6
                        4'b0111: data_out <= 4'hB; // Nhấn B ra C -> Sửa thành B
                        default: data_out <= data_out;
                    endcase
                end else begin
                    valid <= 0;
                    state <= 2'b11;
                end
            end
            
            // QUÉT HÀNG 3 (FPGA tưởng là hàng 3, nhưng thực tế dây Hàng 2 đang cắm ở đây)
            2'b11: begin
                row <= 4'b0111; 
                if (col != 4'b1111) begin
                    valid <= 1;
                    case (col)
                        4'b1110: data_out <= 4'h7; // Nhấn 7 ra E -> Sửa thành 7
                        4'b1101: data_out <= 4'h8; // Nhấn 8 ra 0 -> Sửa thành 8
                        4'b1011: data_out <= 4'h9; // Nhấn 9 ra F -> Sửa thành 9
                        4'b0111: data_out <= 4'hC; // Nhấn C ra D -> Sửa thành C
                        default: data_out <= data_out;
                    endcase
                end else begin
                    valid <= 0;
                    state <= 2'b00; 
                end
            end
            
            default: state <= 2'b00;
        endcase
    end
endmodule