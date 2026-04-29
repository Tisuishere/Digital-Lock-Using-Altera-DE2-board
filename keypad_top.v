module keypad_top (
    input wire CLOCK_50,       // Xung 50MHz từ PIN_N2
    input wire [3:0] COL,      // 4 chân Cột nối với GPIO (Cần bật Weak Pull-Up)
    output wire [3:0] ROW,     // 4 chân Hàng nối với GPIO
    output wire [6:0] HEX0     // 7 chân nối với LED HEX0
);

    // Các dây nối nội bộ (Internal Wires)
    wire clk_1kHz;
    wire [3:0] key_data;
    wire key_valid;
    
    // Thanh ghi lưu trạng thái phím cuối cùng được nhấn
    reg [3:0] display_data = 4'h0; // Mặc định hiển thị 0 khi mới bật nguồn

    // 1. Gọi module chia xung
    clk_divider u_clk_div (
        .clk_in(CLOCK_50),
        .clk_out(clk_1kHz)
    );

    // 2. Gọi module quét phím
    keypad_scanner u_scanner (
        .clk(clk_1kHz),
        .col(COL),
        .row(ROW),
        .data_out(key_data),
        .valid(key_valid)
    );

    // Latch dữ liệu: Cập nhật giá trị hiển thị khi valid lên 1
    always @(posedge clk_1kHz) begin
        if (key_valid) begin
            display_data <= key_data;
        end
    end

    // 3. Gọi module giải mã LED
    hex_decoder u_hex_dec (
        .hex_in(display_data),
        .seg_out(HEX0)
    );

endmodule