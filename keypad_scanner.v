module keypad_scanner (
    input wire clk,             
    input wire [3:0] col,       
    output reg [3:0] row,       
    output reg [3:0] data_out,  
    output reg valid            
);
    reg [1:0] state = 0;

    always @(posedge clk) begin
        case (state)
            // QUÉT HÀNG 0
            2'b00: begin
                row <= 4'b1110; 
                if (col != 4'b1111) begin
                    valid <= 1;
                    case (col)
                        4'b1110: data_out <= 4'hE; // E (Mã của *)
                        4'b1101: data_out <= 4'h0; // 0
                        4'b1011: data_out <= 4'hF; // F (Mã của #)
                        4'b0111: data_out <= 4'hD; // D
                        default: data_out <= data_out;
                    endcase
                end else begin
                    valid <= 0;
                    state <= 2'b01; 
                end
            end
            
            // QUÉT HÀNG 1 
            2'b01: begin
                row <= 4'b1101; 
                if (col != 4'b1111) begin
                    valid <= 1;
                    case (col)
                        4'b1110: data_out <= 4'h1; // 1
                        4'b1101: data_out <= 4'h2; // 2
                        4'b1011: data_out <= 4'h3; // 3
                        4'b0111: data_out <= 4'hA; // A
                        default: data_out <= data_out;
                    endcase
                end else begin
                    valid <= 0;
                    state <= 2'b10;
                end
            end
            
            // QUÉT HÀNG 2 
            2'b10: begin
                row <= 4'b1011; 
                if (col != 4'b1111) begin
                    valid <= 1;
                    case (col)
                        4'b1110: data_out <= 4'h4; // 4
                        4'b1101: data_out <= 4'h5; // 5
                        4'b1011: data_out <= 4'h6; // 6
                        4'b0111: data_out <= 4'hB; // B
                        default: data_out <= data_out;
                    endcase
                end else begin
                    valid <= 0;
                    state <= 2'b11;
                end
            end
            
            // QUÉT HÀNG 3 
            2'b11: begin
                row <= 4'b0111; 
                if (col != 4'b1111) begin
                    valid <= 1;
                    case (col)
                        4'b1110: data_out <= 4'h7; // 7
                        4'b1101: data_out <= 4'h8; // 8
                        4'b1011: data_out <= 4'h9; // 9
                        4'b0111: data_out <= 4'hC; // C
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