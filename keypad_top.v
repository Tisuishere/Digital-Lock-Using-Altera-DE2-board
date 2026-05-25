module keypad_top (
    input wire CLOCK_50,      
    input wire [3:0] COL,      
    output wire [3:0] ROW,     
    output wire [6:0] HEX0     
);

    wire clk_1kHz;
    wire [3:0] key_data;
    wire key_valid;
    
    reg [3:0] display_data = 4'h0; // Mặc định hiển thị 0 khi mới bật nguồn

    clk_divider u_clk_div (
        .clk_in(CLOCK_50),
        .clk_out(clk_1kHz)
    );

    keypad_scanner u_scanner (
        .clk(clk_1kHz),
        .col(COL),
        .row(ROW),
        .data_out(key_data),
        .valid(key_valid)
    );

    always @(posedge clk_1kHz) begin
        if (key_valid) begin
            display_data <= key_data;
        end
    end

    hex_decoder u_hex_dec (
        .hex_in(display_data),
        .seg_out(HEX0)
    );

endmodule